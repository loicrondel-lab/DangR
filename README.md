# Danger Alert - Application de Signalement de Dangers

Une application mobile Ionic/Angular pour signaler et recevoir des alertes sur les dangers à proximité.

## 🚨 Fonctionnalités

### Signalement de Dangers
- **Signalement anonyme** : Signalez des dangers sans révéler votre identité
- **Types de dangers** : Accidents, travaux routiers, conditions météo, embouteillages, contrôles police, dangers routiers
- **Niveaux de sévérité** : Faible, modéré, élevé, critique
- **Géolocalisation automatique** : Utilise votre position GPS pour localiser le danger
- **Rayon d'alerte personnalisable** : Définissez la zone d'alerte (500m à 5km)

### Carte Interactive
- **Visualisation en temps réel** : Carte avec tous les dangers actifs
- **Marqueurs colorés** : Couleurs différentes selon la sévérité
- **Informations détaillées** : Cliquez sur un marqueur pour voir les détails
- **Position utilisateur** : Votre position est affichée sur la carte
- **Actions sur les dangers** : Confirmez ou signalez comme résolu

### Notifications Push
- **Alertes de proximité** : Notifications quand un danger est signalé près de vous
- **Paramètres personnalisables** :
  - Distance maximale d'alerte (1-10km)
  - Sévérité minimale pour recevoir des alertes
  - Types de dangers à surveiller
  - Son et vibration
- **Notifications locales** : Fonctionne même sans connexion serveur

### Paramètres et Confidentialité
- **Vie privée respectée** : Aucune donnée personnelle n'est collectée
- **Signalements anonymes** : Seule la position GPS est partagée
- **Stockage local** : Les données sont stockées sur votre appareil
- **Contrôle total** : Gérez vos préférences de notification

## 🛠 Technologies Utilisées

- **Framework** : Ionic 7 + Angular 17
- **Capacitor** : Pour les fonctionnalités natives
- **Leaflet** : Cartes interactives avec OpenStreetMap
- **TypeScript** : Langage de programmation
- **SCSS** : Styles et thèmes
- **RxJS** : Programmation réactive

### Plugins Capacitor
- `@capacitor/geolocation` : Géolocalisation
- `@capacitor/push-notifications` : Notifications push
- `@capacitor/local-notifications` : Notifications locales
- `@capacitor/haptics` : Retour haptique

## 📱 Installation et Développement

### Prérequis
- Node.js 18+
- npm ou yarn
- Ionic CLI
- Android Studio (pour Android)
- Xcode (pour iOS)

### Installation
```bash
# Cloner le projet
git clone <repository-url>
cd danger-alert

# Installer les dépendances
npm install

# Lancer en mode développement
ionic serve
```

### Build pour mobile
```bash
# Ajouter les plateformes
ionic capacitor add android
ionic capacitor add ios

# Build et synchronisation
ionic capacitor build android
ionic capacitor build ios

# Ouvrir dans l'IDE natif
ionic capacitor open android
ionic capacitor open ios
```

## 🏗 Architecture

### Structure du projet
```
src/
├── app/
│   ├── models/           # Modèles de données
│   │   ├── danger.model.ts
│   │   └── notification.model.ts
│   ├── services/         # Services métier
│   │   ├── geolocation.service.ts
│   │   ├── notification.service.ts
│   │   └── danger.service.ts
│   ├── pages/           # Pages de l'application
│   │   ├── tabs/        # Navigation par onglets
│   │   ├── map/         # Carte interactive
│   │   ├── report/      # Signalement de danger
│   │   └── settings/    # Paramètres
│   └── components/      # Composants réutilisables
├── theme/               # Variables de thème
└── assets/             # Ressources statiques
```

### Services principaux

#### GeolocationService
- Gestion de la géolocalisation
- Suivi de position en temps réel
- Calcul de distances
- Gestion des permissions

#### NotificationService
- Notifications push et locales
- Paramètres de notification
- Formatage des messages
- Gestion des permissions

#### DangerService
- CRUD des dangers
- Stockage local
- Nettoyage automatique
- Statistiques

## 🔒 Sécurité et Confidentialité

### Données collectées
- **Position GPS** : Uniquement lors du signalement
- **Préférences** : Stockées localement sur l'appareil
- **Aucune donnée personnelle** : Pas de nom, email, ou identifiant

### Stockage
- **Local uniquement** : Toutes les données restent sur votre appareil
- **Pas de serveur central** : Fonctionnement en mode déconnecté
- **Nettoyage automatique** : Les dangers expirés sont supprimés

### Permissions requises
- **Géolocalisation** : Pour localiser les dangers
- **Notifications** : Pour recevoir les alertes
- **Stockage** : Pour sauvegarder les préférences

## 🚀 Fonctionnalités avancées

### Gestion automatique
- **Expiration des dangers** : Suppression automatique selon le type
- **Nettoyage périodique** : Optimisation de l'espace de stockage
- **Mise à jour en temps réel** : Interface réactive aux changements

### Personnalisation
- **Thème sombre/clair** : Adaptation automatique au système
- **Interface responsive** : Optimisée pour tous les écrans
- **Accessibilité** : Support des lecteurs d'écran

## 🎨 Interface utilisateur

### Design moderne
- **Material Design** : Interface intuitive et moderne
- **Animations fluides** : Transitions et effets visuels
- **Icônes expressives** : Ionicons pour une meilleure UX
- **Couleurs adaptatives** : Thème qui s'adapte au mode sombre

### Navigation
- **3 onglets principaux** :
  - 🗺️ Carte : Visualisation des dangers
  - ⚠️ Signaler : Nouveau signalement
  - ⚙️ Paramètres : Configuration

## 📊 Utilisation

### Signaler un danger
1. Aller dans l'onglet "Signaler"
2. Sélectionner le type de danger
3. Choisir la sévérité
4. Ajuster le rayon d'alerte
5. Ajouter une description (optionnel)
6. Confirmer le signalement

### Consulter les dangers
1. Aller dans l'onglet "Carte"
2. Voir les marqueurs colorés sur la carte
3. Cliquer sur un marqueur pour les détails
4. Confirmer ou signaler comme résolu

### Configurer les alertes
1. Aller dans l'onglet "Paramètres"
2. Activer/désactiver les notifications
3. Régler la distance d'alerte
4. Choisir les types de dangers
5. Tester les notifications

## 🔧 Configuration

### Variables d'environnement
```typescript
// capacitor.config.ts
export default {
  appId: 'com.dangeralert.app',
  appName: 'Danger Alert',
  webDir: 'dist',
  plugins: {
    Geolocation: {
      permissions: ["location"]
    },
    PushNotifications: {
      presentationOptions: ["badge", "sound", "alert"]
    }
  }
};
```

### Permissions Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### Permissions iOS
```xml
<!-- ios/App/App/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app utilise la géolocalisation pour signaler les dangers.</string>
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation Ionic
- Vérifier les permissions de l'appareil

---

**Danger Alert** - Restez informé, restez en sécurité ! 🚨