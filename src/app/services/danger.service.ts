import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, interval } from 'rxjs';
import { Danger, DangerReport, Position } from '../models/danger.model';
import { GeolocationService } from './geolocation.service';
import { NotificationService } from './notification.service';

@Injectable({
  providedIn: 'root'
})
export class DangerService {
  private dangers$ = new BehaviorSubject<Danger[]>([]);
  private storageKey = 'dangers';

  constructor(
    private geolocationService: GeolocationService,
    private notificationService: NotificationService
  ) {
    this.loadDangers();
    this.startPeriodicCleanup();
    this.startProximityCheck();
  }

  /**
   * Signale un nouveau danger
   */
  async reportDanger(report: DangerReport): Promise<string> {
    const danger: Danger = {
      id: this.generateId(),
      type: report.type,
      severity: report.severity,
      position: report.position,
      description: report.description,
      reportedAt: new Date(),
      expiresAt: this.calculateExpirationDate(report.type),
      isActive: true,
      reportCount: 1,
      radius: report.radius || this.getDefaultRadius(report.type)
    };

    const currentDangers = this.dangers$.value;
    const updatedDangers = [...currentDangers, danger];
    
    this.dangers$.next(updatedDangers);
    this.saveDangers(updatedDangers);

    // Notifier les utilisateurs à proximité
    await this.notifyNearbyUsers(danger);

    return danger.id;
  }

  /**
   * Confirme un danger existant (augmente le compteur)
   */
  confirmDanger(dangerId: string): void {
    const currentDangers = this.dangers$.value;
    const dangerIndex = currentDangers.findIndex(d => d.id === dangerId);
    
    if (dangerIndex !== -1) {
      const updatedDangers = [...currentDangers];
      updatedDangers[dangerIndex] = {
        ...updatedDangers[dangerIndex],
        reportCount: updatedDangers[dangerIndex].reportCount + 1
      };
      
      this.dangers$.next(updatedDangers);
      this.saveDangers(updatedDangers);
    }
  }

  /**
   * Désactive un danger
   */
  deactivateDanger(dangerId: string): void {
    const currentDangers = this.dangers$.value;
    const dangerIndex = currentDangers.findIndex(d => d.id === dangerId);
    
    if (dangerIndex !== -1) {
      const updatedDangers = [...currentDangers];
      updatedDangers[dangerIndex] = {
        ...updatedDangers[dangerIndex],
        isActive: false
      };
      
      this.dangers$.next(updatedDangers);
      this.saveDangers(updatedDangers);
    }
  }

  /**
   * Retourne tous les dangers actifs
   */
  getActiveDangers(): Observable<Danger[]> {
    return this.dangers$.asObservable();
  }

  /**
   * Retourne les dangers dans un rayon donné
   */
  getDangersNearPosition(position: Position, radius: number): Danger[] {
    return this.dangers$.value.filter(danger => {
      if (!danger.isActive) return false;
      
      const distance = this.geolocationService.calculateDistance(
        position, 
        danger.position
      );
      
      return distance <= radius;
    });
  }

  /**
   * Génère un ID unique
   */
  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  /**
   * Calcule la date d'expiration selon le type de danger
   */
  private calculateExpirationDate(type: string): Date {
    const now = new Date();
    const expirationHours: Record<string, number> = {
      'accident': 2,
      'road_work': 24,
      'weather': 6,
      'traffic_jam': 1,
      'police': 0.5,
      'hazard': 12,
      'other': 4
    };

    const hours = expirationHours[type] || 4;
    return new Date(now.getTime() + (hours * 60 * 60 * 1000));
  }

  /**
   * Retourne le rayon par défaut selon le type de danger
   */
  private getDefaultRadius(type: string): number {
    const defaultRadii: Record<string, number> = {
      'accident': 1000,
      'road_work': 2000,
      'weather': 5000,
      'traffic_jam': 1500,
      'police': 800,
      'hazard': 1200,
      'other': 1000
    };

    return defaultRadii[type] || 1000;
  }

  /**
   * Notifie les utilisateurs à proximité
   */
  private async notifyNearbyUsers(danger: Danger): Promise<void> {
    try {
      const currentPosition = await this.geolocationService.getCurrentPosition();
      const distance = this.geolocationService.calculateDistance(
        currentPosition,
        danger.position
      );

      // Ne pas notifier l'utilisateur qui a signalé le danger
      if (distance < 100) return;

      const title = this.notificationService.formatNotificationTitle(
        danger.type,
        distance
      );
      
      const body = this.notificationService.formatNotificationBody(
        danger.type,
        danger.severity,
        danger.description
      );

      await this.notificationService.sendLocalNotification({
        id: danger.id,
        title,
        body,
        dangerType: danger.type,
        severity: danger.severity,
        latitude: danger.position.latitude,
        longitude: danger.position.longitude,
        distance,
        timestamp: Date.now()
      });
    } catch (error) {
      console.error('Erreur lors de la notification:', error);
    }
  }

  /**
   * Vérifie périodiquement la proximité des dangers
   */
  private startProximityCheck(): void {
    interval(30000).subscribe(async () => {
      try {
        const currentPosition = await this.geolocationService.getCurrentPosition();
        const nearbyDangers = this.getDangersNearPosition(currentPosition, 5000);
        
        // Ici on pourrait implémenter une logique plus sophistiquée
        // pour éviter les notifications répétées
      } catch (error) {
        // Géolocalisation non disponible
      }
    });
  }

  /**
   * Nettoie périodiquement les dangers expirés
   */
  private startPeriodicCleanup(): void {
    interval(60000).subscribe(() => {
      this.cleanupExpiredDangers();
    });
  }

  /**
   * Supprime les dangers expirés
   */
  private cleanupExpiredDangers(): void {
    const currentDangers = this.dangers$.value;
    const now = new Date();
    
    const activeDangers = currentDangers.filter(danger => {
      if (!danger.expiresAt) return true;
      return danger.expiresAt > now;
    });

    if (activeDangers.length !== currentDangers.length) {
      this.dangers$.next(activeDangers);
      this.saveDangers(activeDangers);
    }
  }

  /**
   * Sauvegarde les dangers dans le stockage local
   */
  private saveDangers(dangers: Danger[]): void {
    try {
      const serializedDangers = dangers.map(danger => ({
        ...danger,
        reportedAt: danger.reportedAt.toISOString(),
        expiresAt: danger.expiresAt?.toISOString()
      }));
      
      localStorage.setItem(this.storageKey, JSON.stringify(serializedDangers));
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error);
    }
  }

  /**
   * Charge les dangers depuis le stockage local
   */
  private loadDangers(): void {
    try {
      const saved = localStorage.getItem(this.storageKey);
      if (saved) {
        const serializedDangers = JSON.parse(saved);
        const dangers: Danger[] = serializedDangers.map((danger: any) => ({
          ...danger,
          reportedAt: new Date(danger.reportedAt),
          expiresAt: danger.expiresAt ? new Date(danger.expiresAt) : undefined
        }));
        
        // Filtrer les dangers expirés au chargement
        const now = new Date();
        const activeDangers = dangers.filter(danger => {
          if (!danger.expiresAt) return true;
          return danger.expiresAt > now;
        });
        
        this.dangers$.next(activeDangers);
        
        // Sauvegarder si on a filtré des dangers
        if (activeDangers.length !== dangers.length) {
          this.saveDangers(activeDangers);
        }
      }
    } catch (error) {
      console.error('Erreur lors du chargement:', error);
      this.dangers$.next([]);
    }
  }

  /**
   * Efface tous les dangers (pour les tests)
   */
  clearAllDangers(): void {
    this.dangers$.next([]);
    localStorage.removeItem(this.storageKey);
  }

  /**
   * Retourne les statistiques des dangers
   */
  getDangerStats(): { total: number; byType: Record<string, number>; byStatus: Record<string, number> } {
    const dangers = this.dangers$.value;
    const stats = {
      total: dangers.length,
      byType: {} as Record<string, number>,
      byStatus: {
        active: 0,
        inactive: 0,
        expired: 0
      }
    };

    const now = new Date();
    
    dangers.forEach(danger => {
      // Compter par type
      stats.byType[danger.type] = (stats.byType[danger.type] || 0) + 1;
      
      // Compter par statut
      if (!danger.isActive) {
        stats.byStatus.inactive++;
      } else if (danger.expiresAt && danger.expiresAt <= now) {
        stats.byStatus.expired++;
      } else {
        stats.byStatus.active++;
      }
    });

    return stats;
  }
}