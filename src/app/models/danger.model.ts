export interface Position {
  latitude: number;
  longitude: number;
  accuracy?: number;
  timestamp?: number;
}

export enum DangerType {
  ACCIDENT = 'accident',
  ROAD_WORK = 'road_work',
  WEATHER = 'weather',
  TRAFFIC_JAM = 'traffic_jam',
  POLICE = 'police',
  HAZARD = 'hazard',
  OTHER = 'other'
}

export enum DangerSeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical'
}

export interface Danger {
  id: string;
  type: DangerType;
  severity: DangerSeverity;
  position: Position;
  description?: string;
  reportedAt: Date;
  expiresAt?: Date;
  isActive: boolean;
  reportCount: number;
  radius: number; // Rayon d'alerte en mètres
}

export interface DangerReport {
  type: DangerType;
  severity: DangerSeverity;
  position: Position;
  description?: string;
  radius?: number;
}