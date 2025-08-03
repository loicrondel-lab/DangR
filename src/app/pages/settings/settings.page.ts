import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonContent,
  IonHeader,
  IonTitle,
  IonToolbar,
  IonCard,
  IonCardHeader,
  IonCardTitle,
  IonCardContent,
  IonItem,
  IonLabel,
  IonToggle,
  IonSelect,
  IonSelectOption,
  IonRange,
  IonButton,
  IonIcon,
  IonList,
  IonListHeader,
  IonNote,
  IonCheckbox,
  ToastController
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { 
  notificationsOutline,
  locationOutline,
  statsChartOutline,
  trashOutline,
  informationCircleOutline
} from 'ionicons/icons';
import { Subscription } from 'rxjs';

import { NotificationService } from '../../services/notification.service';
import { DangerService } from '../../services/danger.service';
import { GeolocationService } from '../../services/geolocation.service';
import { PushNotificationSettings } from '../../models/notification.model';
import { DangerType, DangerSeverity } from '../../models/danger.model';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.page.html',
  styleUrls: ['./settings.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonContent,
    IonHeader,
    IonTitle,
    IonToolbar,
    IonCard,
    IonCardHeader,
    IonCardTitle,
    IonCardContent,
    IonItem,
    IonLabel,
    IonToggle,
    IonSelect,
    IonSelectOption,
    IonRange,
    IonButton,
    IonIcon,
    IonList,
    IonListHeader,
    IonNote,
    IonCheckbox
  ],
})
export class SettingsPage implements OnInit, OnDestroy {
  settings: PushNotificationSettings = {
    enabled: true,
    dangerTypes: Object.values(DangerType),
    maxDistance: 5000,
    minSeverity: DangerSeverity.LOW,
    soundEnabled: true,
    vibrationEnabled: true
  };

  dangerTypes = Object.values(DangerType);
  severities = Object.values(DangerSeverity);
  stats: any = {};

  dangerTypeLabels: Record<DangerType, string> = {
    [DangerType.ACCIDENT]: 'Accidents',
    [DangerType.ROAD_WORK]: 'Travaux routiers',
    [DangerType.WEATHER]: 'Conditions météo',
    [DangerType.TRAFFIC_JAM]: 'Embouteillages',
    [DangerType.POLICE]: 'Contrôles police',
    [DangerType.HAZARD]: 'Dangers routiers',
    [DangerType.OTHER]: 'Autres'
  };

  severityLabels: Record<DangerSeverity, string> = {
    [DangerSeverity.LOW]: 'Faible',
    [DangerSeverity.MEDIUM]: 'Modéré',
    [DangerSeverity.HIGH]: 'Élevé',
    [DangerSeverity.CRITICAL]: 'Critique'
  };

  private subscription?: Subscription;

  constructor(
    private notificationService: NotificationService,
    private dangerService: DangerService,
    private geolocationService: GeolocationService,
    private toastController: ToastController
  ) {
    addIcons({ 
      notificationsOutline,
      locationOutline,
      statsChartOutline,
      trashOutline,
      informationCircleOutline
    });
  }

  ngOnInit() {
    // Charger les paramètres actuels
    this.subscription = this.notificationService.getSettings().subscribe(
      settings => {
        this.settings = { ...settings };
      }
    );

    // Charger les statistiques
    this.loadStats();
  }

  ngOnDestroy() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  onSettingsChange() {
    this.notificationService.updateSettings(this.settings);
    this.showToast('Paramètres sauvegardés');
  }

  onDangerTypeToggle(dangerType: DangerType, event: any) {
    if (event.detail.checked) {
      if (!this.settings.dangerTypes.includes(dangerType)) {
        this.settings.dangerTypes.push(dangerType);
      }
    } else {
      this.settings.dangerTypes = this.settings.dangerTypes.filter(
        type => type !== dangerType
      );
    }
    this.onSettingsChange();
  }

  isDangerTypeEnabled(dangerType: DangerType): boolean {
    return this.settings.dangerTypes.includes(dangerType);
  }

  getDistanceLabel(distance: number): string {
    return distance >= 1000 
      ? `${(distance / 1000).toFixed(1)} km` 
      : `${distance} m`;
  }

  async clearAllData() {
    this.dangerService.clearAllDangers();
    await this.showToast('Toutes les données ont été effacées');
    this.loadStats();
  }

  async testNotification() {
    try {
      await this.notificationService.sendLocalNotification({
        id: 'test',
        title: 'Test de notification',
        body: 'Ceci est une notification de test pour vérifier que tout fonctionne correctement.',
        dangerType: DangerType.OTHER,
        severity: DangerSeverity.MEDIUM,
        latitude: 0,
        longitude: 0,
        distance: 500,
        timestamp: Date.now()
      });
      await this.showToast('Notification de test envoyée');
    } catch (error) {
      await this.showToast('Erreur lors de l\'envoi de la notification de test');
    }
  }

  async requestLocationPermission() {
    try {
      const granted = await this.geolocationService.requestPermissions();
      if (granted) {
        await this.showToast('Permission de géolocalisation accordée');
      } else {
        await this.showToast('Permission de géolocalisation refusée');
      }
    } catch (error) {
      await this.showToast('Erreur lors de la demande de permission');
    }
  }

  private loadStats() {
    this.stats = this.dangerService.getDangerStats();
  }

  private async showToast(message: string) {
    const toast = await this.toastController.create({
      message,
      duration: 2000,
      position: 'top'
    });
    await toast.present();
  }

  getSeverityIndex(severity: DangerSeverity): number {
    const severities = [DangerSeverity.LOW, DangerSeverity.MEDIUM, DangerSeverity.HIGH, DangerSeverity.CRITICAL];
    return severities.indexOf(severity);
  }

  getSeverityFromIndex(index: number): DangerSeverity {
    const severities = [DangerSeverity.LOW, DangerSeverity.MEDIUM, DangerSeverity.HIGH, DangerSeverity.CRITICAL];
    return severities[index] || DangerSeverity.LOW;
  }

  onSeverityChange(event: any) {
    this.settings.minSeverity = this.getSeverityFromIndex(event.detail.value);
    this.onSettingsChange();
  }
}