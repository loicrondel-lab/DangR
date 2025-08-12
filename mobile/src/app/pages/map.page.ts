import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';

@Component({
  selector: 'app-map-page',
  standalone: true,
  imports: [IonicModule],
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-title>Carte</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content>
      <div id="map" style="height: 100%; width: 100%"></div>
    </ion-content>
  `,
})
export class MapPage {}