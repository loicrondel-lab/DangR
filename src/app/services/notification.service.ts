import { Injectable } from '@angular/core';
import { 
  PushNotifications, 
  PushNotificationSchema, 
  ActionPerformed,
  Token 
} from '@capacitor/push-notifications';
import { 
  LocalNotifications, 
  LocalNotificationSchema 
} from '@capacitor/local-notifications';
import { BehaviorSubject, Observable } from 'rxjs';
import { NotificationPayload, PushNotificationSettings } from '../models/notification.model';
import { DangerType, DangerSeverity } from '../models/danger.model';

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private settings$ = new BehaviorSubject<PushNotificationSettings>({
    enabled: true,
    dangerTypes: Object.values(DangerType),
    maxDistance: 5000, // 5km par défaut
    minSeverity: DangerSeverity.LOW,
    soundEnabled: true,
    vibrationEnabled: true
  });

  private pushToken: string | null = null;

  constructor() {
    this.initializePushNotifications();
    this.loadSettings();
  }

  /**
   * Initialise les notifications push
   */
  private async initializePushNotifications(): Promise<void> {
    try {
      // Demander les permissions
      const result = await PushNotifications.requestPermissions();
      
      if (result.receive === 'granted') {
        // Enregistrer pour les notifications push
        await PushNotifications.register();

        // Écouter l'enregistrement
        PushNotifications.addListener('registration', (token: Token) => {
          console.log('Push registration success, token: ' + token.value);
          this.pushToken = token.value;
        });

        // Écouter les erreurs d'enregistrement
        PushNotifications.addListener('registrationError', (error: any) => {
          console.error('Error on registration: ' + JSON.stringify(error));
        });

        // Écouter les notifications reçues
        PushNotifications.addListener('pushNotificationReceived', 
          (notification: PushNotificationSchema) => {
            console.log('Push received: ' + JSON.stringify(notification));
            this.handlePushNotification(notification);
          }
        );

        // Écouter les actions sur les notifications
        PushNotifications.addListener('pushNotificationActionPerformed', 
          (notification: ActionPerformed) => {
            console.log('Push action performed: ' + JSON.stringify(notification));
            this.handleNotificationAction(notification);
          }
        );
      }
    } catch (error) {
      console.error('Erreur lors de l\'initialisation des notifications push:', error);
    }
  }

  /**
   * Envoie une notification locale
   */
  async sendLocalNotification(payload: NotificationPayload): Promise<void> {
    const settings = this.settings$.value;
    
    if (!settings.enabled) return;
    if (!settings.dangerTypes.includes(payload.dangerType)) return;
    if (payload.distance > settings.maxDistance) return;
    if (this.getSeverityLevel(payload.severity) < this.getSeverityLevel(settings.minSeverity)) return;

    try {
      const notification: LocalNotificationSchema = {
        title: payload.title,
        body: payload.body,
        id: parseInt(payload.id.replace(/\D/g, '').substring(0, 9)) || Math.floor(Math.random() * 1000000),
        schedule: { at: new Date(Date.now() + 1000) },
        sound: settings.soundEnabled ? 'beep.wav' : undefined,
        attachments: undefined,
        actionTypeId: 'DANGER_ALERT',
        extra: {
          dangerType: payload.dangerType,
          latitude: payload.latitude,
          longitude: payload.longitude,
          distance: payload.distance
        }
      };

      await LocalNotifications.schedule({
        notifications: [notification]
      });
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification locale:', error);
    }
  }

  /**
   * Gère les notifications push reçues
   */
  private handlePushNotification(notification: PushNotificationSchema): void {
    // Traiter la notification push reçue
    console.log('Notification push reçue:', notification);
  }

  /**
   * Gère les actions sur les notifications
   */
  private handleNotificationAction(action: ActionPerformed): void {
    const data = action.notification.data;
    if (data && data.dangerType) {
      // Naviguer vers la carte avec la position du danger
      console.log('Action sur notification:', action);
    }
  }

  /**
   * Met à jour les paramètres de notification
   */
  updateSettings(settings: Partial<PushNotificationSettings>): void {
    const currentSettings = this.settings$.value;
    const newSettings = { ...currentSettings, ...settings };
    this.settings$.next(newSettings);
    this.saveSettings(newSettings);
  }

  /**
   * Retourne les paramètres actuels
   */
  getSettings(): Observable<PushNotificationSettings> {
    return this.settings$.asObservable();
  }

  /**
   * Sauvegarde les paramètres
   */
  private saveSettings(settings: PushNotificationSettings): void {
    localStorage.setItem('notificationSettings', JSON.stringify(settings));
  }

  /**
   * Charge les paramètres sauvegardés
   */
  private loadSettings(): void {
    const saved = localStorage.getItem('notificationSettings');
    if (saved) {
      try {
        const settings = JSON.parse(saved);
        this.settings$.next(settings);
      } catch (error) {
        console.error('Erreur lors du chargement des paramètres:', error);
      }
    }
  }

  /**
   * Convertit le niveau de sévérité en nombre pour comparaison
   */
  private getSeverityLevel(severity: DangerSeverity): number {
    switch (severity) {
      case DangerSeverity.LOW: return 1;
      case DangerSeverity.MEDIUM: return 2;
      case DangerSeverity.HIGH: return 3;
      case DangerSeverity.CRITICAL: return 4;
      default: return 0;
    }
  }

  /**
   * Retourne le token push actuel
   */
  getPushToken(): string | null {
    return this.pushToken;
  }

  /**
   * Formate le titre de la notification selon le type de danger
   */
  formatNotificationTitle(dangerType: DangerType, distance: number): string {
    const distanceStr = distance < 1000 
      ? `${Math.round(distance)}m` 
      : `${(distance / 1000).toFixed(1)}km`;

    const typeLabels: Record<DangerType, string> = {
      [DangerType.ACCIDENT]: 'Accident',
      [DangerType.ROAD_WORK]: 'Travaux',
      [DangerType.WEATHER]: 'Conditions météo',
      [DangerType.TRAFFIC_JAM]: 'Embouteillage',
      [DangerType.POLICE]: 'Contrôle police',
      [DangerType.HAZARD]: 'Danger',
      [DangerType.OTHER]: 'Alerte'
    };

    return `${typeLabels[dangerType]} à ${distanceStr}`;
  }

  /**
   * Formate le corps de la notification
   */
  formatNotificationBody(dangerType: DangerType, severity: DangerSeverity, description?: string): string {
    const severityLabels: Record<DangerSeverity, string> = {
      [DangerSeverity.LOW]: 'Faible',
      [DangerSeverity.MEDIUM]: 'Modéré',
      [DangerSeverity.HIGH]: 'Élevé',
      [DangerSeverity.CRITICAL]: 'Critique'
    };

    let body = `Niveau: ${severityLabels[severity]}`;
    if (description) {
      body += `\n${description}`;
    }
    return body;
  }
}