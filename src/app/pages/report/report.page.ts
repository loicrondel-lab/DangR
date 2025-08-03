import { Component, OnInit } from '@angular/core';
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
  IonSelect,
  IonSelectOption,
  IonTextarea,
  IonButton,
  IonIcon,
  IonToast,
  IonSpinner,
  IonRange,
  IonNote,
  AlertController,
  ToastController
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { 
  locationOutline, 
  alertCircleOutline, 
  checkmarkCircleOutline 
} from 'ionicons/icons';

import { DangerType, DangerSeverity, DangerReport } from '../../models/danger.model';
import { GeolocationService } from '../../services/geolocation.service';
import { DangerService } from '../../services/danger.service';

@Component({
  selector: 'app-report',
  templateUrl: './report.page.html',
  styleUrls: ['./report.page.scss'],
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
    IonSelect,
    IonSelectOption,
    IonTextarea,
    IonButton,
    IonIcon,
    IonToast,
    IonSpinner,
    IonRange,
    IonNote
  ],
})
export class ReportPage implements OnInit {
  dangerTypes = Object.values(DangerType);
  dangerSeverities = Object.values(DangerSeverity);
  
  report: Partial<DangerReport> = {
    type: DangerType.OTHER,
    severity: DangerSeverity.MEDIUM,
    description: '',
    radius: 1000
  };

  isLoading = false;
  isToastOpen = false;
  toastMessage = '';
  toastColor = 'success';

  dangerTypeLabels: Record<DangerType, string> = {
    [DangerType.ACCIDENT]: 'Accident',
    [DangerType.ROAD_WORK]: 'Travaux routiers',
    [DangerType.WEATHER]: 'Conditions météo',
    [DangerType.TRAFFIC_JAM]: 'Embouteillage',
    [DangerType.POLICE]: 'Contrôle police',
    [DangerType.HAZARD]: 'Danger sur la route',
    [DangerType.OTHER]: 'Autre'
  };

  severityLabels: Record<DangerSeverity, string> = {
    [DangerSeverity.LOW]: 'Faible',
    [DangerSeverity.MEDIUM]: 'Modéré',
    [DangerSeverity.HIGH]: 'Élevé',
    [DangerSeverity.CRITICAL]: 'Critique'
  };

  constructor(
    private geolocationService: GeolocationService,
    private dangerService: DangerService,
    private alertController: AlertController,
    private toastController: ToastController
  ) {
    addIcons({ 
      locationOutline, 
      alertCircleOutline, 
      checkmarkCircleOutline 
    });
  }

  ngOnInit() {}

  async submitReport() {
    if (!this.isFormValid()) {
      this.showToast('Veuillez remplir tous les champs requis', 'warning');
      return;
    }

    this.isLoading = true;

    try {
      // Obtenir la position actuelle
      const position = await this.geolocationService.getCurrentPosition();
      
      const dangerReport: DangerReport = {
        type: this.report.type!,
        severity: this.report.severity!,
        position: position,
        description: this.report.description,
        radius: this.report.radius
      };

      // Signaler le danger
      const dangerId = await this.dangerService.reportDanger(dangerReport);
      
      this.showToast('Danger signalé avec succès !', 'success');
      this.resetForm();
      
    } catch (error) {
      console.error('Erreur lors du signalement:', error);
      this.showToast('Erreur lors du signalement. Vérifiez votre géolocalisation.', 'danger');
    } finally {
      this.isLoading = false;
    }
  }

  async showConfirmDialog() {
    const alert = await this.alertController.create({
      header: 'Confirmer le signalement',
      message: `Êtes-vous sûr de vouloir signaler ce danger de type "${this.dangerTypeLabels[this.report.type!]}" ?`,
      buttons: [
        {
          text: 'Annuler',
          role: 'cancel'
        },
        {
          text: 'Confirmer',
          handler: () => {
            this.submitReport();
          }
        }
      ]
    });

    await alert.present();
  }

  private isFormValid(): boolean {
    return !!(this.report.type && this.report.severity);
  }

  private resetForm() {
    this.report = {
      type: DangerType.OTHER,
      severity: DangerSeverity.MEDIUM,
      description: '',
      radius: 1000
    };
  }

  private async showToast(message: string, color: string) {
    const toast = await this.toastController.create({
      message,
      duration: 3000,
      position: 'top',
      color
    });
    await toast.present();
  }

  getRadiusLabel(value: number): string {
    return value >= 1000 ? `${(value / 1000).toFixed(1)} km` : `${value} m`;
  }
}