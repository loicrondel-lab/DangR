import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';

@Component({
  selector: 'app-profile-page',
  standalone: true,
  imports: [IonicModule],
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-title>Profil</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content>
      <p>Gérer le profil utilisateur et les paramètres.</p>
    </ion-content>
  `,
})
export class ProfilePage {}