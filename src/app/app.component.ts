import { Component, OnInit } from '@angular/core';
import { IonApp, IonRouterOutlet } from '@ionic/angular/standalone';
import { GeolocationService } from './services/geolocation.service';
import { NotificationService } from './services/notification.service';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  standalone: true,
  imports: [IonApp, IonRouterOutlet],
})
export class AppComponent implements OnInit {
  constructor(
    private geolocationService: GeolocationService,
    private notificationService: NotificationService
  ) {}

  async ngOnInit() {
    // Demander les permissions au démarrage
    await this.requestPermissions();
  }

  private async requestPermissions() {
    try {
      // Demander les permissions de géolocalisation
      const locationPermission = await this.geolocationService.requestPermissions();
      if (locationPermission) {
        console.log('Permission de géolocalisation accordée');
        // Démarrer le suivi de position
        await this.geolocationService.startWatching();
      } else {
        console.warn('Permission de géolocalisation refusée');
      }
    } catch (error) {
      console.error('Erreur lors de la demande de permissions:', error);
    }
  }
}