# Guide de Configuration DangR

Ce guide vous aide à configurer tous les services externes nécessaires pour faire fonctionner l'application DangR.

## 1. MapLibre GL

### Étape 1 : Créer un compte
1. Allez sur [MapTiler](https://www.maptiler.com/)
2. Créez un compte gratuit
3. Générez une clé API

### Étape 2 : Configurer
1. Ouvrez `lib/core/config/app_config.dart`
2. Remplacez `YOUR_MAPLIBRE_TOKEN` par votre clé API

```dart
static const String mapLibreToken = 'votre_clé_api_ici';
```

## 2. Firebase

### Étape 1 : Créer un projet
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet
3. Activez l'authentification (Email/Password et Anonymous)
4. Activez Cloud Messaging

### Étape 2 : Configurer l'application
1. Ajoutez votre application Android/iOS
2. Téléchargez le fichier `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS)
3. Placez-le dans le bon dossier :
   - Android : `android/app/google-services.json`
   - iOS : `ios/Runner/GoogleService-Info.plist`

### Étape 3 : Mettre à jour la configuration
1. Ouvrez `lib/core/config/app_config.dart`
2. Remplacez les valeurs Firebase :

```dart
static const String firebaseProjectId = 'votre_project_id';
static const String firebaseMessagingSenderId = 'votre_sender_id';
```

## 3. Supabase

### Étape 1 : Créer un projet
1. Allez sur [Supabase](https://supabase.com/)
2. Créez un nouveau projet
3. Notez l'URL et les clés API

### Étape 2 : Configurer la base de données
1. Dans l'interface Supabase, allez dans SQL Editor
2. Exécutez le script SQL suivant :

```sql
-- Extension PostGIS pour les données géospatiales
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table des utilisateurs (extension de auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des incidents
CREATE TABLE public.hazards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  severity INTEGER NOT NULL CHECK (severity >= 1 AND severity <= 4),
  description TEXT,
  photo_urls TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'expired', 'false_report')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  upvotes INTEGER DEFAULT 0,
  downvotes INTEGER DEFAULT 0,
  reporter_id UUID REFERENCES auth.users(id),
  location GEOMETRY(POINT, 4326)
);

-- Index géospatial
CREATE INDEX hazards_location_idx ON public.hazards USING GIST (location);
CREATE INDEX hazards_created_at_idx ON public.hazards (created_at DESC);
CREATE INDEX hazards_type_idx ON public.hazards (type);
CREATE INDEX hazards_status_idx ON public.hazards (status);

-- Table des votes
CREATE TABLE public.votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  hazard_id UUID REFERENCES public.hazards(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  vote_type TEXT CHECK (vote_type IN ('up', 'down')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(hazard_id, user_id)
);

-- Table des signalements
CREATE TABLE public.reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  hazard_id UUID REFERENCES public.hazards(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES auth.users(id),
  reason TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_hazards_updated_at BEFORE UPDATE ON public.hazards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hazards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Politiques RLS
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Hazards are viewable by everyone" ON public.hazards FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert hazards" ON public.hazards FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update own hazards" ON public.hazards FOR UPDATE USING (auth.uid() = reporter_id);

CREATE POLICY "Votes are viewable by everyone" ON public.votes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert votes" ON public.votes FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Users can update own votes" ON public.votes FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Reports are viewable by everyone" ON public.reports FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert reports" ON public.reports FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### Étape 3 : Configurer l'application
1. Ouvrez `lib/core/config/app_config.dart`
2. Remplacez les valeurs Supabase :

```dart
static const String supabaseUrl = 'votre_url_supabase';
static const String supabaseAnonKey = 'votre_clé_anon';
static const String supabaseServiceRoleKey = 'votre_clé_service_role';
```

## 4. Sentry

### Étape 1 : Créer un projet
1. Allez sur [Sentry](https://sentry.io/)
2. Créez un nouveau projet Flutter
3. Notez le DSN

### Étape 2 : Configurer
1. Ouvrez `lib/core/config/app_config.dart`
2. Remplacez `YOUR_SENTRY_DSN` par votre DSN

```dart
static const String sentryDsn = 'votre_dsn_sentry';
```

## 5. Assets

### Étape 1 : Télécharger les polices
1. Téléchargez la police Inter depuis [Google Fonts](https://fonts.google.com/specimen/Inter)
2. Placez les fichiers TTF dans `assets/fonts/Inter/`

### Étape 2 : Créer les animations Lottie
1. Créez ou téléchargez des animations Lottie
2. Placez-les dans `assets/animations/`

### Étape 3 : Créer les icônes
1. Créez les icônes personnalisées
2. Placez-les dans `assets/images/icons/`

## 6. Configuration Android

### Étape 1 : Permissions
Vérifiez que `android/app/src/main/AndroidManifest.xml` contient :

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### Étape 2 : Services
Ajoutez dans `android/app/src/main/AndroidManifest.xml` :

```xml
<service
    android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
    android:exported="false"
    android:stopWithTask="false" />
```

## 7. Configuration iOS

### Étape 1 : Permissions
Ajoutez dans `ios/Runner/Info.plist` :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DangR a besoin de votre localisation pour vous alerter des dangers à proximité.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>DangR a besoin de votre localisation en arrière-plan pour vous alerter des dangers à proximité.</string>
<key>NSCameraUsageDescription</key>
<string>DangR a besoin d'accéder à votre caméra pour prendre des photos d'incidents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>DangR a besoin d'accéder à votre galerie pour sélectionner des photos d'incidents.</string>
```

## 8. Test de la configuration

### Étape 1 : Générer les fichiers
```bash
flutter pub get
flutter packages pub run build_runner build
```

### Étape 2 : Tester l'application
```bash
flutter run
```

## 9. Déploiement

### Étape 1 : Build de production
```bash
flutter build apk --release
flutter build ios --release
```

### Étape 2 : Distribution
- Android : Publier sur Google Play Store
- iOS : Publier sur App Store Connect

## Support

Si vous rencontrez des problèmes :
1. Vérifiez que tous les services sont correctement configurés
2. Consultez les logs de l'application
3. Vérifiez la documentation des services utilisés
4. Contactez l'équipe de développement
