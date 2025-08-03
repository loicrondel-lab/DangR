import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import {
  IonContent,
  IonButton,
  IonIcon,
  IonText,
  IonSlides,
  IonSlide,
  IonProgressBar,
  IonCheckbox,
  IonItem,
  IonLabel
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { 
  shieldCheckmarkOutline,
  mapOutline,
  notificationsOutline,
  locationOutline,
  lockClosedOutline,
  arrowForwardOutline,
  checkmarkCircleOutline
} from 'ionicons/icons';
import { GeolocationService } from '../../services/geolocation.service';
import { NotificationService } from '../../services/notification.service';

interface OnboardingSlide {
  title: string;
  subtitle: string;
  description: string;
  icon: string;
  color: string;
}

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.page.html',
  styleUrls: ['./welcome.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    IonContent,
    IonButton,
    IonIcon,
    IonText,
    IonSlides,
    IonSlide,
    IonProgressBar,
    IonCheckbox,
    IonItem,
    IonLabel
  ],
})
export class WelcomePage implements OnInit {
  currentSlide = 0;
  isLastSlide = false;
  acceptTerms = false;
  isLocationPermissionGranted = false;
  isNotificationPermissionGranted = false;

  slides: OnboardingSlide[] = [
    {
      title: 'Bienvenue sur Danger Alert',
      subtitle: 'Restez informé des dangers sur votre route',
      description: 'Une application communautaire pour signaler et recevoir des alertes sur les dangers à proximité.',
      icon: 'shield-checkmark-outline',
      color: 'primary'
    },
    {
      title: 'Signalement Anonyme',
      subtitle: 'Votre vie privée est protégée',
      description: 'Signalez des dangers de manière totalement anonyme. Seule votre position GPS est partagée, aucune donnée personnelle.',
      icon: 'lock-closed-outline',
      color: 'success'
    },
    {
      title: 'Carte Interactive',
      subtitle: 'Visualisez les dangers en temps réel',
      description: 'Consultez une carte interactive avec tous les dangers signalés autour de vous, avec des informations détaillées.',
      icon: 'map-outline',
      color: 'secondary'
    },
    {
      title: 'Notifications Intelligentes',
      subtitle: 'Alertes personnalisées',
      description: 'Recevez des notifications push quand un danger est signalé près de votre position, selon vos préférences.',
      icon: 'notifications-outline',
      color: 'warning'
    },
    {
      title: 'Permissions Requises',
      subtitle: 'Pour un fonctionnement optimal',
      description: 'L\'application a besoin d\'accéder à votre position et d\'envoyer des notifications pour vous alerter efficacement.',
      icon: 'location-outline',
      color: 'danger'
    }
  ];

  constructor(
    private router: Router,
    private geolocationService: GeolocationService,
    private notificationService: NotificationService
  ) {
    addIcons({ 
      shieldCheckmarkOutline,
      mapOutline,
      notificationsOutline,
      locationOutline,
      lockClosedOutline,
      arrowForwardOutline,
      checkmarkCircleOutline
    });
  }

  ngOnInit() {
    // Vérifier si l'utilisateur a déjà vu l'onboarding
    const hasSeenOnboarding = localStorage.getItem('hasSeenOnboarding');
    if (hasSeenOnboarding === 'true') {
      this.router.navigate(['/tabs/map']);
    }
  }

  onSlideChange(event: any) {
    event.target.getActiveIndex().then((index: number) => {
      this.currentSlide = index;
      this.isLastSlide = index === this.slides.length - 1;
    });
  }

  nextSlide() {
    const slides = document.querySelector('ion-slides');
    if (slides) {
      slides.slideNext();
    }
  }

  previousSlide() {
    const slides = document.querySelector('ion-slides');
    if (slides) {
      slides.slidePrev();
    }
  }

  async requestLocationPermission() {
    try {
      const granted = await this.geolocationService.requestPermissions();
      this.isLocationPermissionGranted = granted;
      
      if (granted) {
        // Démarrer le suivi de position
        await this.geolocationService.startWatching();
      }
    } catch (error) {
      console.error('Erreur lors de la demande de permission de géolocalisation:', error);
    }
  }

  async requestNotificationPermission() {
    try {
      // La permission sera demandée lors de l'initialisation du service
      this.isNotificationPermissionGranted = true;
    } catch (error) {
      console.error('Erreur lors de la demande de permission de notification:', error);
    }
  }

  canFinishOnboarding(): boolean {
    return this.acceptTerms && this.isLocationPermissionGranted;
  }

  finishOnboarding() {
    if (this.canFinishOnboarding()) {
      // Marquer l'onboarding comme terminé
      localStorage.setItem('hasSeenOnboarding', 'true');
      
      // Naviguer vers l'application principale
      this.router.navigate(['/tabs/map']);
    }
  }

  skipOnboarding() {
    localStorage.setItem('hasSeenOnboarding', 'true');
    this.router.navigate(['/tabs/map']);
  }

  getProgressValue(): number {
    return (this.currentSlide + 1) / this.slides.length;
  }
}