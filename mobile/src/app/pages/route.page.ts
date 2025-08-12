import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';

@Component({
  selector: 'app-route-page',
  standalone: true,
  imports: [IonicModule],
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-title>Itinéraire sûr</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content>
      <p>Calculer un itinéraire évitant les zones chaudes.</p>
    </ion-content>
  `,
})
export class RoutePage {}