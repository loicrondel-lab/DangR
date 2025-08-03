import { Injectable } from '@angular/core';
import { Geolocation } from '@capacitor/geolocation';
import { BehaviorSubject, Observable } from 'rxjs';
import { Position } from '../models/danger.model';

@Injectable({
  providedIn: 'root'
})
export class GeolocationService {
  private currentPosition$ = new BehaviorSubject<Position | null>(null);
  private watchId: string | null = null;

  constructor() {}

  /**
   * Obtient la position actuelle
   */
  async getCurrentPosition(): Promise<Position> {
    try {
      const position = await Geolocation.getCurrentPosition({
        enableHighAccuracy: true,
        timeout: 10000
      });

      const pos: Position = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        accuracy: position.coords.accuracy,
        timestamp: position.timestamp
      };

      this.currentPosition$.next(pos);
      return pos;
    } catch (error) {
      console.error('Erreur lors de l\'obtention de la position:', error);
      throw error;
    }
  }

  /**
   * Démarre le suivi de la position
   */
  async startWatching(): Promise<void> {
    try {
      this.watchId = await Geolocation.watchPosition({
        enableHighAccuracy: true,
        timeout: 10000
      }, (position, err) => {
        if (err) {
          console.error('Erreur lors du suivi de position:', err);
          return;
        }

        if (position) {
          const pos: Position = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
            timestamp: position.timestamp
          };
          this.currentPosition$.next(pos);
        }
      });
    } catch (error) {
      console.error('Erreur lors du démarrage du suivi:', error);
      throw error;
    }
  }

  /**
   * Arrête le suivi de la position
   */
  async stopWatching(): Promise<void> {
    if (this.watchId) {
      await Geolocation.clearWatch({ id: this.watchId });
      this.watchId = null;
    }
  }

  /**
   * Retourne un Observable de la position actuelle
   */
  getCurrentPosition$(): Observable<Position | null> {
    return this.currentPosition$.asObservable();
  }

  /**
   * Calcule la distance entre deux positions en mètres
   */
  calculateDistance(pos1: Position, pos2: Position): number {
    const R = 6371e3; // Rayon de la Terre en mètres
    const φ1 = pos1.latitude * Math.PI/180;
    const φ2 = pos2.latitude * Math.PI/180;
    const Δφ = (pos2.latitude-pos1.latitude) * Math.PI/180;
    const Δλ = (pos2.longitude-pos1.longitude) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c;
  }

  /**
   * Vérifie si une position est dans un rayon donné
   */
  isWithinRadius(center: Position, point: Position, radius: number): boolean {
    const distance = this.calculateDistance(center, point);
    return distance <= radius;
  }

  /**
   * Demande les permissions de géolocalisation
   */
  async requestPermissions(): Promise<boolean> {
    try {
      const permissions = await Geolocation.requestPermissions();
      return permissions.location === 'granted';
    } catch (error) {
      console.error('Erreur lors de la demande de permissions:', error);
      return false;
    }
  }

  /**
   * Vérifie les permissions de géolocalisation
   */
  async checkPermissions(): Promise<boolean> {
    try {
      const permissions = await Geolocation.checkPermissions();
      return permissions.location === 'granted';
    } catch (error) {
      console.error('Erreur lors de la vérification des permissions:', error);
      return false;
    }
  }
}