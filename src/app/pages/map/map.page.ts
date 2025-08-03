import { Component, OnInit, OnDestroy, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonContent,
  IonHeader,
  IonTitle,
  IonToolbar,
  IonFab,
  IonFabButton,
  IonIcon,
  IonCard,
  IonCardContent,
  IonBadge,
  IonItem,
  IonLabel,
  IonButton,
  IonChip
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { 
  locateOutline, 
  refreshOutline,
  alertCircleOutline,
  checkmarkCircleOutline,
  closeCircleOutline
} from 'ionicons/icons';

import * as L from 'leaflet';
import { Subscription } from 'rxjs';

import { GeolocationService } from '../../services/geolocation.service';
import { DangerService } from '../../services/danger.service';
import { Danger, DangerType, DangerSeverity, Position } from '../../models/danger.model';

@Component({
  selector: 'app-map',
  templateUrl: './map.page.html',
  styleUrls: ['./map.page.scss'],
  standalone: true,
  imports: [
    CommonModule,
    IonContent,
    IonHeader,
    IonTitle,
    IonToolbar,
    IonFab,
    IonFabButton,
    IonIcon,
    IonCard,
    IonCardContent,
    IonBadge,
    IonItem,
    IonLabel,
    IonButton,
    IonChip
  ],
})
export class MapPage implements OnInit, OnDestroy {
  @ViewChild('mapContainer', { static: false }) mapContainer!: ElementRef;

  private map!: L.Map;
  private userMarker!: L.Marker;
  private dangerMarkers: L.Marker[] = [];
  private userPosition: Position | null = null;
  
  private subscriptions: Subscription[] = [];
  
  dangers: Danger[] = [];
  selectedDanger: Danger | null = null;
  isMapReady = false;

  dangerTypeLabels: Record<DangerType, string> = {
    [DangerType.ACCIDENT]: 'Accident',
    [DangerType.ROAD_WORK]: 'Travaux',
    [DangerType.WEATHER]: 'Météo',
    [DangerType.TRAFFIC_JAM]: 'Embouteillage',
    [DangerType.POLICE]: 'Police',
    [DangerType.HAZARD]: 'Danger',
    [DangerType.OTHER]: 'Autre'
  };

  severityColors: Record<DangerSeverity, string> = {
    [DangerSeverity.LOW]: '#28a745',
    [DangerSeverity.MEDIUM]: '#ffc107',
    [DangerSeverity.HIGH]: '#fd7e14',
    [DangerSeverity.CRITICAL]: '#dc3545'
  };

  constructor(
    private geolocationService: GeolocationService,
    private dangerService: DangerService
  ) {
    addIcons({ 
      locateOutline, 
      refreshOutline,
      alertCircleOutline,
      checkmarkCircleOutline,
      closeCircleOutline
    });
  }

  async ngOnInit() {
    // Attendre un peu pour que la vue soit initialisée
    setTimeout(() => {
      this.initializeMap();
    }, 100);

    // S'abonner aux changements de position
    const positionSub = this.geolocationService.getCurrentPosition$().subscribe(
      position => {
        if (position) {
          this.userPosition = position;
          this.updateUserLocation(position);
        }
      }
    );
    this.subscriptions.push(positionSub);

    // S'abonner aux changements de dangers
    const dangersSub = this.dangerService.getActiveDangers().subscribe(
      dangers => {
        this.dangers = dangers.filter(d => d.isActive);
        if (this.isMapReady) {
          this.updateDangerMarkers();
        }
      }
    );
    this.subscriptions.push(dangersSub);

    // Obtenir la position initiale
    try {
      const position = await this.geolocationService.getCurrentPosition();
      this.userPosition = position;
    } catch (error) {
      console.error('Erreur lors de l\'obtention de la position:', error);
    }
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
    if (this.map) {
      this.map.remove();
    }
  }

  private initializeMap() {
    if (!this.mapContainer) {
      console.error('Map container not found');
      return;
    }

    // Configuration par défaut (Paris)
    const defaultLat = 48.8566;
    const defaultLng = 2.3522;
    const lat = this.userPosition?.latitude || defaultLat;
    const lng = this.userPosition?.longitude || defaultLng;

    // Initialiser la carte
    this.map = L.map(this.mapContainer.nativeElement).setView([lat, lng], 13);

    // Ajouter les tuiles OpenStreetMap
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(this.map);

    // Ajouter le marqueur utilisateur
    this.addUserMarker(lat, lng);

    this.isMapReady = true;
    this.updateDangerMarkers();

    // Gérer les clics sur la carte
    this.map.on('click', () => {
      this.selectedDanger = null;
    });
  }

  private addUserMarker(lat: number, lng: number) {
    const userIcon = L.divIcon({
      className: 'user-marker',
      html: '<div class="user-marker-inner"></div>',
      iconSize: [20, 20],
      iconAnchor: [10, 10]
    });

    this.userMarker = L.marker([lat, lng], { icon: userIcon })
      .addTo(this.map)
      .bindPopup('Votre position');
  }

  private updateUserLocation(position: Position) {
    if (this.userMarker && this.map) {
      this.userMarker.setLatLng([position.latitude, position.longitude]);
    }
  }

  private updateDangerMarkers() {
    // Supprimer les anciens marqueurs
    this.dangerMarkers.forEach(marker => {
      this.map.removeLayer(marker);
    });
    this.dangerMarkers = [];

    // Ajouter les nouveaux marqueurs
    this.dangers.forEach(danger => {
      const marker = this.createDangerMarker(danger);
      this.dangerMarkers.push(marker);
      marker.addTo(this.map);
    });
  }

  private createDangerMarker(danger: Danger): L.Marker {
    const color = this.severityColors[danger.severity];
    const icon = this.getDangerIcon(danger.type);
    
    const dangerIcon = L.divIcon({
      className: 'danger-marker',
      html: `
        <div class="danger-marker-inner" style="background-color: ${color}">
          <ion-icon name="${icon}"></ion-icon>
          <div class="danger-count">${danger.reportCount}</div>
        </div>
      `,
      iconSize: [40, 40],
      iconAnchor: [20, 20]
    });

    const marker = L.marker([danger.position.latitude, danger.position.longitude], { 
      icon: dangerIcon 
    });

    // Ajouter un cercle pour montrer le rayon
    const circle = L.circle([danger.position.latitude, danger.position.longitude], {
      radius: danger.radius,
      fillColor: color,
      fillOpacity: 0.1,
      color: color,
      weight: 2,
      opacity: 0.5
    }).addTo(this.map);

    // Gérer le clic sur le marqueur
    marker.on('click', (e) => {
      e.originalEvent.stopPropagation();
      this.selectedDanger = danger;
      this.map.setView([danger.position.latitude, danger.position.longitude], 15);
    });

    return marker;
  }

  private getDangerIcon(type: DangerType): string {
    const icons: Record<DangerType, string> = {
      [DangerType.ACCIDENT]: 'car-outline',
      [DangerType.ROAD_WORK]: 'construct-outline',
      [DangerType.WEATHER]: 'rainy-outline',
      [DangerType.TRAFFIC_JAM]: 'stop-outline',
      [DangerType.POLICE]: 'shield-outline',
      [DangerType.HAZARD]: 'warning-outline',
      [DangerType.OTHER]: 'alert-circle-outline'
    };
    return icons[type] || 'alert-circle-outline';
  }

  centerOnUser() {
    if (this.userPosition && this.map) {
      this.map.setView([this.userPosition.latitude, this.userPosition.longitude], 15);
    }
  }

  async refreshLocation() {
    try {
      const position = await this.geolocationService.getCurrentPosition();
      this.userPosition = position;
      this.centerOnUser();
    } catch (error) {
      console.error('Erreur lors du rafraîchissement de la position:', error);
    }
  }

  confirmDanger(danger: Danger) {
    this.dangerService.confirmDanger(danger.id);
    this.selectedDanger = null;
  }

  dismissDanger(danger: Danger) {
    this.dangerService.deactivateDanger(danger.id);
    this.selectedDanger = null;
  }

  getTimeAgo(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'À l\'instant';
    if (diffMins < 60) return `Il y a ${diffMins} min`;
    
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `Il y a ${diffHours}h`;
    
    const diffDays = Math.floor(diffHours / 24);
    return `Il y a ${diffDays}j`;
  }

  getDistanceFromUser(danger: Danger): string {
    if (!this.userPosition) return '';
    
    const distance = this.geolocationService.calculateDistance(
      this.userPosition,
      danger.position
    );
    
    return distance < 1000 
      ? `${Math.round(distance)}m` 
      : `${(distance / 1000).toFixed(1)}km`;
  }
}