# DangR - Sécurisation des trajets piétons

Application mobile pour alerter en temps réel et cartographier les zones à risque pour sécuriser les trajets à pied, priorité femmes, dans les grandes villes françaises.

## 🎯 Vision

Alerter en temps réel et cartographier les zones à risque pour sécuriser les trajets à pied, priorité femmes, dans les grandes villes françaises.

## 🏗️ Architecture

### Stack technique
- **Frontend Mobile**: Ionic 7 + Angular 17 + Capacitor
- **Backend**: Supabase (PostgreSQL + PostGIS + Auth + Realtime)
- **Cartographie**: MapLibre GL + H3 + Supercluster
- **Monorepo**: Nx 21.3.11

### Structure du projet
```
apps/
├── mobile/          # App Ionic mobile (MVP)
└── admin/           # Interface web admin (modération)
libs/
├── ui/              # Design system partagé
├── data/            # Modèles et DTOs
├── api/             # Services REST/RPC
├── map/             # Utilitaires MapLibre/H3
└── auth/            # Services d'authentification
supabase/
└── schema.sql       # Schéma PostgreSQL + PostGIS
```

## 🚀 Démarrage rapide

### Prérequis
- Node.js 18+
- pnpm
- Compte Supabase

### Installation
```bash
# Cloner le projet
git clone <repository>
cd dangr

# Installer les dépendances
pnpm install

# Démarrer l'app mobile
pnpm exec nx serve mobile

# Démarrer l'admin web
pnpm exec nx serve admin
```

### Configuration Supabase
1. Créer un projet Supabase (région EU)
2. Exécuter le schéma SQL : `supabase/schema.sql`
3. Configurer les variables d'environnement

## 📱 Fonctionnalités MVP

### Utilisateur
- ✅ **Carte interactive** avec clusters et heatmap
- ✅ **Signalement rapide** (≤15s, 3 étapes)
- ✅ **Feed de proximité** avec filtres
- ✅ **Itinéraire sûr** évitant les zones chaudes
- ✅ **Notifications push** de proximité
- ✅ **Confirmation/contestation** des signalements

### Modérateur
- ✅ **File de modération** avec règles automatiques
- ✅ **Actions** : approuver/refuser/flouter/bannir
- ✅ **SLA** : <5 min p50 (objectif phase 3)

### Admin
- ✅ **Paramétrage** catégories et seuils
- ✅ **Gestion partenaires** lieux sûrs
- ✅ **Analytics** et métriques

## 🔒 Sécurité & Conformité

### Privacy-by-design
- Minimisation des données
- Masquage précision GPS (jitter 30-50m)
- Rétention courte (30-90 jours)
- Consentement granulaire

### RGPD
- DPIA (Analyse d'Impact)
- Registre des traitements
- Base légale "intérêt légitime"
- Droits utilisateur (accès, suppression)

## 📊 Métriques clés

### Performance
- TTFU <3 min
- Latence carte <300 ms
- Render 60 fps (milieu de gamme)

### Qualité
- Taux faux signalements <10% (MVP)
- Taux faux <7% (v1)
- NPS ≥30 (phase 3)

## 🗺️ Roadmap

### Phase 2 (S7-S12) - MVP fermé
- [x] Structure monorepo Nx
- [x] App Ionic mobile
- [x] Schéma Supabase
- [ ] Intégration MapLibre
- [ ] Services API
- [ ] Tests E2E

### Phase 3 (S13-S20) - Beta ville pilote
- [ ] Safe Walk (itinéraire sûr)
- [ ] Mode discret
- [ ] Live location opt-in
- [ ] Modération p50<5 min

### Phase 4 (S21-S32) - v1 multi-villes
- [ ] Essais monétisation
- [ ] B2B dashboards
- [ ] Affiliation

## 🛠️ Développement

### Commandes utiles
```bash
# Build
pnpm exec nx build mobile
pnpm exec nx build admin

# Tests
pnpm exec nx test mobile
pnpm exec nx test admin

# Lint
pnpm exec nx lint mobile
pnpm exec nx lint admin

# E2E
pnpm exec nx e2e mobile-e2e
```

### Ajouter une librairie
```bash
pnpm exec nx g @nx/js:library ma-lib --directory libs/ma-lib --bundler=vite --importPath @dangr/ma-lib --projectNameAndRootFormat=as-provided
```

### Ajouter une page
```bash
# Créer le fichier dans apps/mobile/src/app/pages/
# Ajouter la route dans app.routes.ts
```

## 📝 Modèle de données

### Tables principales
- `profiles` - Profils utilisateurs
- `reports` - Signalements géolocalisés
- `report_votes` - Confirmations/contestations
- `moderation_actions` - Actions de modération
- `safe_places` - Lieux sûrs partenaires
- `device_tokens` - Tokens push notifications

### Score de fiabilité
Formule composite : `(0.5 * time_decay) + (0.4 * conf_part) - (0.2 * cont_part) + rep_part`

## 🌍 Villes pilotes
- Paris (10e/11e arrondissements)
- Lyon (1er/7e arrondissements)  
- Marseille (2 arrondissements)

## 📞 Support
- Issues : GitHub
- Documentation : Wiki interne
- Sécurité : security@dangr.fr

## 📄 Licence
Propriétaire - Tous droits réservés