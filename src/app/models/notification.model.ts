import { DangerType, DangerSeverity } from './danger.model';

export interface NotificationPayload {
  id: string;
  title: string;
  body: string;
  dangerType: DangerType;
  severity: DangerSeverity;
  latitude: number;
  longitude: number;
  distance: number; // Distance en mètres
  timestamp: number;
}

export interface PushNotificationSettings {
  enabled: boolean;
  dangerTypes: DangerType[];
  maxDistance: number; // Distance maximale en mètres
  minSeverity: DangerSeverity;
  soundEnabled: boolean;
  vibrationEnabled: boolean;
}