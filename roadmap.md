# Roadmap DangR (version Flutter)

**Date : 12 août 2025** — **Marché cible : grandes villes françaises** — **Vision :** Alerter en temps réel et cartographier les zones à risque pour sécuriser les trajets à pied (priorité : femmes).

---

## Phase 0 — Kickoff & cadrage (S1–S2)

**Objectifs :** alignement, risques, cadre légal.

* **Produit/Tech :** backlog initial, design system (inspiration Waze), arborescence écrans clé (Carte/Accueil, Signalement, Feed, Itinéraire sûr, Profil). **Stack : Flutter/Dart**, Map (MapLibre via `maplibre_gl` ou fallback `flutter_map`), **Backend : Supabase** (Auth/Postgres/Realtime) ou **Firebase** (Auth/Firestore). Hébergement UE.
* **Légal & sûreté :** DPIA v0 (RGPD), politique de modération/anti-dénonciation, matrice risques (diffamation, faux signalements, stigmatisation).
* **Marché :** plan d’étude (entretiens + sondage), personas (ex. « Étudiante parisienne 22–28 ans »).
* **Go-to-market :** identité de marque, ton, landing d’attente + liste d’inscription.
* **Business :** hypothèses de monétisation (B2C freemium, B2B villes/assureurs, API chaleur urbaine).
  **Critères de sortie :** maquettes basse fidélité validées, DPIA v0, 20 entretiens planifiés, 1 000 inscrits en liste d’attente.

---

## Phase 1 — Discovery terrain & Design sprint (S3–S6)

* **Marché :** 30–40 entretiens qualis à Paris/Lyon/Marseille + 1 sondage (n≈500).
* **Produit :** design sprint #1 (signalement en 15 s), wireframes → maquettes hi‑fi (Figma), proto cliquable testé (n=12).
* **Légal :** charte d’usage, CGU/Privacy v0, seuils de visibilité (p. ex. 2 confirmations ⇒ public).
* **Comms :** messages sécurité non anxiogènes, partenariats ONG locales (marches exploratoires), programme bêta‑testrices.
  **Sortie :** PROTO validé (SUS ≥ 75), charte modération, 3 partenaires associatifs d’accord de principe.

---

## Phase 2 — MVP fermé (S7–S12)

**Fonctionnalités MVP :**

* Signalement géolocalisé (catégories : agression verbale, groupe agressif, ivresse, pillage, harcèlement…), photo/texte optionnels, timer d’auto‑suppression.
* Carte chaleur + clusters, feed à proximité, filtres heure/type.
* Système de fiabilité : réputation utilisateur, double validation, détection d’anomalies, bouton « contester ».
* Modération : file hybride (automatique + modérateurs), guidelines claires, bannissement progressif.
* Notifications : push « zone à éviter »/« itinéraire à risque ».
* Comptes : email/Apple/Google ; **data minimisée**.
* Observabilité : logs et traçabilité des modérations.

**Tech Flutter :**

* **UI/State :** Flutter 3.x, Material 3, **Riverpod** (ou Bloc) + Router. Theming sombre par défaut.
* **Carto :** `maplibre_gl` (vector tiles) avec style MapLibre / tuiles OSM FR ; fallback `flutter_map` si besoin. Clustering côté serveur pour densité urbaine, avec supercluster côté back si nécessaire.
* **Géolocalisation & BG :** `geolocator` (foreground), plugin BG (ex. `flutter_background_geolocation`) pour tâches critiques ; `workmanager` pour jobs périodiques non temps réel.
* **Realtime & stockage :** Supabase (Auth + Realtime + RLS) **ou** Firebase (Auth + Firestore listeners). Media : stockage objet (Supabase Storage / Firebase Storage).
* **Push :** FCM via `firebase_messaging` + `flutter_local_notifications`.
* **CI/CD :** GitHub Actions + **Fastlane** (build/signature, déploiement stores) ou Codemagic. Tests unitaires + golden tests UI. E2E (Flutter Integration Tests).

**Comms :** bêta fermée (n=500) dans 2 arrondissements cibles par ville (Paris 10/11, Lyon 1/7).

**Sortie :** TTFU < 3 min, 1 000 signalements cumulés, taux de faux < 10 %, latence carte < 300 ms.

---

## Phase 3 — Beta publique ville pilote (S13–S20)

* **Produit :** Safe Walk (trajet évitant zones chaudes), listes de lieux sensibles temporels (soirées, gares), mode discret, partage position live (opt‑in).
* **Sûreté :** escalade incidents graves (112/114, conseils vérifiés), guide d’auto‑protection co‑rédigé avec ONG.
* **Croissance :** campus/after‑work/collectifs féminins, micro‑influence locales, street marketing sorties de transports.
* **PR :** presse locale + radios ; événements municipaux.
* **Data :** modèle de confiance par zone (temps/récence/volume).
  **Sortie :** DAU ≥ 5 k (ville pilote), rétention J7 ≥ 25 %, temps de modération p50 < 5 min, NPS ≥ 30.

---

## Phase 4 — v1 multi‑villes & monétisation test (S21–S32)

* **Lancement :** Paris, Lyon, Marseille, Lille, Bordeaux.
* **Produit :** gamification « gardien·ne de quartier » (non compétitive), badges discrétion ; mode hors‑ligne (cache carreaux) ; signalements programmés (ex. « marché du soir »).
* **Business (essais) :**

  * **B2C :** abonnement **Plus** (alertes avancées, trajets illimités, zones personnalisées).
  * **B2B :** dashboards anonymisés pour villes/transports (contrats pilotes).
  * **Affiliation :** trajets alternatifs (VTC nocturne, parkings sécurisés) **éthique** et non ciblé.
* **Partenariats :** mairies/SEM, opérateurs transport, festivals.
  **Sortie :** ≥ 50 k MAU, 3 pilotes B2B signés, ARPU test ≥ 1,5 €/mois sur cohortes, faux signalements < 7 %.

---

## Phase 5 — Scale national & durcissement sûreté (S33–S52)

* **Produit :** recommandations locales on‑device (privacy‑first), classification assistée (ML légère), sandbox pour événements (Fête de la musique, 31/12).
* **Sûreté :** audit externe (sécurité applicative + biais), bug bounty, comité éthique.
* **Gouvernance data :** rétention courte (30–90 j), anonymisation forte, transparence publique (rapport trimestriel).
* **Go‑to‑market :** TV/radio régionales, assureurs/banques étudiantes, pack « Rentrée ».
* **Business :** conversion > 3 % au payant, 10+ contrats B2B, marge infra positive.
  **Sortie :** ≥ 250 k MAU, rétention M2 ≥ 35 %, CAC < 1,5 €, 10 villes actives.

---

## KPI à piloter

* **Sécurité/fiabilité :** % faux signalements, délai modération p50/p95, taux de contestation confirmé.
* **Usage :** DAU/MAU, rétention J1/J7/J30, temps en app, taux de signalement/1 000 users.
* **Couverture :** densité signalements par km², zones froides vs. trajets.
* **Croissance :** CAC, K‑factor local, coût par inscription vérifiée.
* **Business :** ARPU, conversion payant, MRR, contrats B2B signés.
* **Confiance :** NPS, CSAT modération, incidents médiatiques (zéro tolérance).

---

## Organisation (équipe minimale)

* PM, **Lead Mobile (Flutter/Dart)**, Dev Mobile, Dev Back, Designer UX/UI, Data/ML light, Modération (2–4 en horaires sensibles), Legal/Privacy, Growth, Partenariats locaux.

---

## Prochaines actions (dès cette semaine)

1. Ateliers cadrage + risques (1/2 jour).
2. Maquettes low‑fi des 5 écrans cœur (Carte/Accueil, Signalement, Feed, Itinéraire, Profil).
3. Plan d’entretiens + script + calendrier.
4. Landing + liste d’attente + tracking.
5. Choix infra (Supabase/Firebase) et **squelette app Flutter** (modules : core/ui, features, data). Mise en place CI/CD (GitHub Actions + Fastlane).
