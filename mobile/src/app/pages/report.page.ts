import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';

@Component({
  selector: 'app-report-page',
  standalone: true,
  imports: [IonicModule],
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-buttons slot="start">
          <ion-back-button defaultHref="/"></ion-back-button>
        </ion-buttons>
        <ion-title>Signaler</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content>
      <p>Formulaire de signalement en 3 étapes.</p>
    </ion-content>
  `,
})
export class ReportPage {}