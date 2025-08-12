# DangR - Application de Sécurité Urbaine

DangR est une application mobile Flutter qui permet aux utilisateurs de signaler et visualiser les zones à risque en temps réel, inspirée du design intuitif de Waze.

## 🎯 Objectif

Alerter en temps réel et cartographier les zones à risque pour sécuriser les trajets à pied, avec une priorité pour la sécurité des femmes dans les grandes villes françaises.

## ✨ Fonctionnalités

- **Carte interactive** avec visualisation des incidents en temps réel
- **Signalement rapide** d'incidents en 2 clics
- **Système de votes** pour valider les signalements
- **Notifications de proximité** pour alerter les utilisateurs
- **Design moderne** inspiré de Waze avec des couleurs vives
- **Mode sombre/clair** pour une meilleure expérience utilisateur
- **Interface intuitive** avec animations fluides

## 🛠️ Technologies

- **Flutter 3.x** - Framework de développement cross-platform
- **Dart 3.x** - Langage de programmation
- **Riverpod** - Gestion d'état
- **GoRouter** - Navigation
- **MapLibre GL** - Cartographie
- **Isar** - Base de données locale
- **Supabase** - Backend-as-a-Service
- **Firebase** - Notifications push

## 📱 Captures d'écran

### Page d'accueil (Carte)
- Carte interactive avec marqueurs d'incidents
- Bouton flottant de signalement rapide
- Contrôles de carte (style, filtres)
- Carte d'information des incidents

### Signalement d'incident
- Sélecteur de type d'incident avec icônes colorées
- Slider de gravité
- Ajout de photos
- Description optionnelle

### Onboarding
- 4 étapes d'introduction avec animations Lottie
- Design moderne avec gradients
- Navigation fluide

## 🚀 Installation

### Prérequis

- Flutter SDK 3.0.0 ou supérieur
- Dart SDK 3.0.0 ou supérieur
- Android Studio / VS Code
- Un appareil Android/iOS ou émulateur

### Étapes d'installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/votre-username/dangr.git
   cd dangr
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer les services externes**

   **MapLibre GL**
   - Obtenir un token d'accès sur [MapLibre](https://maplibre.org/)
   - Remplacer `YOUR_MAPLIBRE_TOKEN` dans `lib/features/map/presentation/pages/map_page.dart`

   **Firebase**
   - Créer un projet Firebase
   - Ajouter les fichiers de configuration :
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

   **Supabase**
   - Créer un projet Supabase
   - Configurer les variables d'environnement dans `.env`

4. **Générer le code**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Lancer l'application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

L'application suit une architecture Clean Architecture avec une organisation par features :

```
lib/
├── core/
│   ├── theme/          # Thème et styles
│   ├── router/         # Navigation
│   ├── providers/      # Gestion d'état global
│   └── services/       # Services partagés
├── features/
│   ├── map/           # Carte et visualisation
│   ├── reports/       # Signalement d'incidents
│   ├── feed/          # Flux d'actualités
│   ├── profile/       # Profil utilisateur
│   ├── onboarding/    # Introduction
│   └── auth/          # Authentification
└── shared/
    ├── widgets/       # Composants réutilisables
    └── models/        # Modèles de données
```

## 🎨 Design System

### Couleurs principales
- **Orange principal** : `#FF6B35` - Actions principales
- **Bleu** : `#4A90E2` - Informations
- **Vert** : `#7ED321` - Succès
- **Rouge** : `#E74C3C` - Dangers
- **Jaune** : `#F5A623` - Avertissements

### Typographie
- **Police** : Inter
- **Tailles** : 12px à 28px
- **Poids** : Regular (400), Medium (500), SemiBold (600), Bold (700)

### Composants
- Boutons avec bordures arrondies (12px)
- Cartes avec ombres subtiles
- Animations fluides (200-300ms)
- Feedback haptique

## 📊 Fonctionnalités techniques

### Performance
- **Démarrage** : < 2.5 secondes
- **Carte** : ≥ 50 FPS avec 3000 points
- **Batterie** : < 6%/h en navigation
- **Mémoire** : < 350 Mo

### Sécurité
- **Pseudonymisation** des utilisateurs
- **Chiffrement** des données locales
- **Rate limiting** côté API
- **Détection d'anomalies**

### Conformité
- **RGPD/CNIL** compatible
- **Minimisation** des données
- **Rétention courte** (30-90 jours)
- **Consentement** explicite

## 🔧 Configuration

### Variables d'environnement

Créer un fichier `.env` à la racine du projet :

```env
# MapLibre
MAPLIBRE_TOKEN=your_maplibre_token

# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project_id

# Sentry
SENTRY_DSN=your_sentry_dsn
```

### Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`) :
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`) :
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DangR a besoin de votre localisation pour afficher les incidents à proximité</string>
<key>NSCameraUsageDescription</key>
<string>DangR a besoin de l'accès à la caméra pour ajouter des photos aux signalements</string>
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests de widgets
flutter test test/widget_test.dart
```

## 📦 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🚀 Déploiement

### Android
1. Générer un keystore
2. Configurer `android/app/build.gradle`
3. Uploader sur Google Play Console

### iOS
1. Configurer les certificats dans Xcode
2. Uploader sur App Store Connect

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

- **Email** : support@dangr.app
- **Documentation** : [docs.dangr.app](https://docs.dangr.app)
- **Issues** : [GitHub Issues](https://github.com/votre-username/dangr/issues)

## 🙏 Remerciements

- **Waze** pour l'inspiration du design
- **Flutter** pour le framework
- **MapLibre** pour la cartographie
- **Supabase** pour le backend

---

**DangR** - Ensemble, plus sûrs dans nos villes 🛡️
