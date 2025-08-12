# Assets DangR

Ce dossier contient tous les assets de l'application DangR.

## Structure

```
assets/
├── animations/          # Animations Lottie
│   ├── onboarding/     # Animations pour l'onboarding
│   ├── loading/        # Animations de chargement
│   └── success/        # Animations de succès
├── images/             # Images statiques
│   ├── icons/          # Icônes personnalisées
│   ├── logos/          # Logos de l'application
│   └── backgrounds/    # Images de fond
├── fonts/              # Polices personnalisées
│   └── Inter/          # Police Inter
└── README.md           # Ce fichier
```

## Animations Lottie

### Onboarding
- `welcome.json` - Animation de bienvenue
- `safety.json` - Animation sur la sécurité
- `community.json` - Animation sur la communauté
- `ready.json` - Animation de fin d'onboarding

### Loading
- `loading.json` - Animation de chargement générale
- `map_loading.json` - Animation de chargement de la carte
- `sync.json` - Animation de synchronisation

### Success
- `report_sent.json` - Animation de signalement envoyé
- `hazard_resolved.json` - Animation d'incident résolu

## Images

### Icônes
- `hazard_accident.png` - Icône d'accident
- `hazard_traffic.png` - Icône de trafic
- `hazard_weather.png` - Icône météo
- `hazard_construction.png` - Icône de travaux
- `hazard_obstacle.png` - Icône d'obstacle
- `hazard_police.png` - Icône de police
- `hazard_emergency.png` - Icône d'urgence

### Logos
- `logo_primary.png` - Logo principal
- `logo_white.png` - Logo blanc
- `logo_icon.png` - Icône de l'application

## Polices

### Inter
- `Inter-Regular.ttf`
- `Inter-Medium.ttf`
- `Inter-SemiBold.ttf`
- `Inter-Bold.ttf`

## Utilisation

Les assets sont référencés dans le fichier `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/animations/
    - assets/images/
    - assets/fonts/
```

## Génération des assets

Pour générer les assets manquants :

1. **Animations Lottie** : Utiliser des outils comme LottieFiles ou After Effects
2. **Icônes** : Utiliser Figma, Sketch ou Adobe Illustrator
3. **Polices** : Télécharger depuis Google Fonts ou utiliser des polices libres

## Optimisation

- Compresser les images PNG/JPEG
- Optimiser les animations Lottie
- Utiliser des formats appropriés (WebP pour les images)
- Minimiser la taille des polices en ne gardant que les caractères nécessaires
