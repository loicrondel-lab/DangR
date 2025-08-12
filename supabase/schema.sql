-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Custom types
CREATE TYPE report_status AS ENUM ('pending', 'public', 'rejected', 'archived');
CREATE TYPE report_type AS ENUM ('harcelement', 'agression_verbale', 'groupe_agressif', 'ivresse', 'pillage', 'autre');
CREATE TYPE vote_kind AS ENUM ('confirm', 'contest');
CREATE TYPE mod_action AS ENUM ('approve', 'reject', 'blur', 'ban_user', 'restore');

-- Profiles table
CREATE TABLE public.profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  reputation INTEGER DEFAULT 0,
  city_code TEXT, -- INSEE/arrondissement
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reports table
CREATE TABLE public.reports (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  type report_type NOT NULL,
  geom GEOGRAPHY(POINT, 4326) NOT NULL,
  accuracy_m INTEGER,
  text TEXT,
  media_url TEXT, -- Storage path, EXIF strip côté serveur
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- auto-suppression
  status report_status DEFAULT 'pending',
  reliability NUMERIC DEFAULT 0, -- cache
  contested_count INTEGER DEFAULT 0
);

-- Report votes table
CREATE TABLE public.report_votes (
  report_id BIGINT REFERENCES public.reports(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  kind vote_kind NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (report_id, user_id)
);

-- Moderation actions table
CREATE TABLE public.moderation_actions (
  id BIGSERIAL PRIMARY KEY,
  report_id BIGINT REFERENCES public.reports(id) ON DELETE CASCADE,
  moderator_id UUID REFERENCES auth.users(id),
  action mod_action NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Safe places table
CREATE TABLE public.safe_places (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  geom GEOGRAPHY(POINT, 4326) NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  partner_id UUID REFERENCES auth.users(id)
);

-- Device tokens table
CREATE TABLE public.device_tokens (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT PRIMARY KEY,
  platform TEXT CHECK (platform IN ('ios', 'android')),
  city_code TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- App configuration table
CREATE TABLE public.app_config (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_reports_geom ON public.reports USING GIST (geom);
CREATE INDEX idx_reports_status ON public.reports (status) WHERE status = 'public';
CREATE INDEX idx_reports_created_at ON public.reports (created_at);
CREATE INDEX idx_reports_expires_at ON public.reports (expires_at);
CREATE INDEX idx_safe_places_geom ON public.safe_places USING GIST (geom);
CREATE INDEX idx_device_tokens_user_id ON public.device_tokens (user_id);
CREATE INDEX idx_device_tokens_city_code ON public.device_tokens (city_code);

-- RLS Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.report_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.safe_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Reports policies
CREATE POLICY "Public reports are viewable by all" ON public.reports
  FOR SELECT USING (status = 'public');

CREATE POLICY "Users can view their own reports" ON public.reports
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create reports" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update their own reports" ON public.reports
  FOR UPDATE USING (auth.uid() = user_id);

-- Report votes policies
CREATE POLICY "Users can view votes on public reports" ON public.report_votes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.reports 
      WHERE id = report_id AND status = 'public'
    )
  );

CREATE POLICY "Users can view their own votes" ON public.report_votes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can vote" ON public.report_votes
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND
    auth.uid() != (
      SELECT user_id FROM public.reports WHERE id = report_id
    )
  );

-- Safe places policies
CREATE POLICY "Safe places are viewable by all" ON public.safe_places
  FOR SELECT USING (true);

-- Device tokens policies
CREATE POLICY "Users can manage their own device tokens" ON public.device_tokens
  FOR ALL USING (auth.uid() = user_id);

-- App config policies (admin only)
CREATE POLICY "App config is viewable by authenticated users" ON public.app_config
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Functions
CREATE OR REPLACE FUNCTION public.calculate_reliability_score(report_id BIGINT)
RETURNS NUMERIC AS $$
DECLARE
  time_decay NUMERIC;
  conf_part NUMERIC;
  cont_part NUMERIC;
  rep_part NUMERIC;
  report_record RECORD;
  user_reputation INTEGER;
BEGIN
  -- Get report data
  SELECT r.*, p.reputation INTO report_record, user_reputation
  FROM public.reports r
  LEFT JOIN public.profiles p ON r.user_id = p.user_id
  WHERE r.id = report_id;
  
  IF NOT FOUND THEN
    RETURN 0;
  END IF;
  
  -- Time decay (τ = 3 hours)
  time_decay = EXP(-EXTRACT(EPOCH FROM (NOW() - report_record.created_at)) / (3 * 3600));
  
  -- Confirmation part
  SELECT 1 - EXP(-0.7 * COUNT(*)) INTO conf_part
  FROM public.report_votes
  WHERE report_id = $1 AND kind = 'confirm';
  
  -- Contestation part
  SELECT EXP(-0.5 * COUNT(*)) INTO cont_part
  FROM public.report_votes
  WHERE report_id = $1 AND kind = 'contest';
  
  -- Reputation part
  rep_part = LEAST(GREATEST(COALESCE(user_reputation, 0) / 100.0, 0), 0.3);
  
  -- Calculate final score
  RETURN (0.5 * time_decay) + (0.4 * conf_part) - (0.2 * cont_part) + rep_part;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update reliability score
CREATE OR REPLACE FUNCTION public.update_reliability_score()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.reports 
  SET reliability = public.calculate_reliability_score(NEW.report_id)
  WHERE id = NEW.report_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_reliability_score
  AFTER INSERT OR UPDATE OR DELETE ON public.report_votes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_reliability_score();

-- Function to clean expired reports
CREATE OR REPLACE FUNCTION public.clean_expired_reports()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM public.reports 
  WHERE expires_at < NOW();
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Initial app config
INSERT INTO public.app_config (key, value) VALUES
  ('safe_route_enabled', 'true'),
  ('image_upload_enabled', 'true'),
  ('geo_blur_meters', '30'),
  ('visibility_threshold', '0.6'),
  ('decay_tau_hours', '3');

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;