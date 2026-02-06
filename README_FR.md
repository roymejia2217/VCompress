<div align="center">
  <img src="android/app/src/main/play_store_512.png" alt="Logo VCompress" width="200" height="200">
</div>

# VCompress

[![Licence : MIT](https://img.shields.io/badge/Licence-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green.svg)](https://www.android.com)
[![Version GitHub](https://img.shields.io/github/v/release/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress/releases)
[![Dernier commit GitHub](https://img.shields.io/github/last-commit/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress)

Une puissante application Android de compression vidéo construite avec Flutter. VCompress offre une optimisation vidéo intelligente avec accélération matérielle, traitement par lot et suivi de progression en temps réel.

**Plateformes**: Android (7.0+) | **Langues**: [English](README.md) | [Español](README_ES.md) | [Français](README_FR.md) | [Italiano](README_IT.md)

---

## Table des Matières

- [Fonctionnalités](#fonctionnalités)
- [Aperçu de l'Interface Utilisateur](#aperçu-de-linterface-utilisateur)
- [Spécifications Techniques](#spécifications-techniques)
- [Architecture](#architecture)
- [Installation et Configuration](#installation-et-configuration)
- [Utilisation](#utilisation)
- [Développement](#développement)
- [Tests](#tests)
- [Optimisations de Performance](#optimisations-de-performance)
- [Compatibilité](#compatibilité)
- [Dépannage](#dépannage)
- [Gestion des Dépendances](#gestion-des-dépendances)
- [Décisions Architecturales](#décisions-architecturales)
- [Contributions](#contributions)
- [FAQ](#faq)
- [Licence](#licence)
- [Support](#support)

---

## Fonctionnalités

### Compression Principale
- **Algorithmes de Compression Multiples**: VP8, VP9, H.264, H.265 avec support d'accélération matérielle
- **Traitement par Lot**: Compresse plusieurs vidéos simultanément avec mise en file d'attente intelligente
- **Suivi de Progression en Temps Réel**: Indicateurs de progression en direct pour l'importation et les opérations de compression
- **Sélection Intelligente de la Résolution**: Profils prédéfinis (720p, 1080p, 2K, 4K) avec options personnalisées
- **Flexibilité de Format**: Support des conteneurs de sortie MP4, WebM, MKV

### Fonctionnalités Avancées
- **Détection Matérielle**: Détection automatique des capacités du périphérique (cœurs CPU, RAM, support des codecs)
- **Intégration FFmpeg**: Traitement vidéo standard de l'industrie avec ffmpeg_kit_flutter_new
- **Génération de Miniatures**: Extraction automatique des miniatures vidéo avec mise en cache
- **Extraction de Métadonnées**: Analyse complète des vidéos (durée, résolution, codec, fps)
- **Gestion de Fichiers**: Remplacement sécurisé des fichiers avec options de sauvegarde et résolution URI MediaStore
- **Système de Notifications**: Notifications de progression de compression en temps réel

### Expérience Utilisateur
- **Material Design 3**: Interface moderne et réactive avec thématisation dynamique des couleurs
- **Support Multilingue**: Espagnol (es), Anglais (en), Français (fr) avec Flutter Intl
- **Paramètres Localisés**: Mode thème (clair/sombre/système), sélection de langue, répertoire d'enregistrement personnalisé
- **Mode Sombre**: Support complet du thème sombre Material 3 avec Flex Color Scheme
- **Accessibilité**: Étiquettes sémantiques, navigation au clavier, support des lecteurs d'écran

---

## Aperçu de l'Interface Utilisateur

### Flux de Compression

VCompress offre une interface intuitive en Material Design 3 qui guide les utilisateurs à travers le processus de compression vidéo:

| **Étape 1: Importer** | **Étape 2: Configurer** | **Étape 3: Traiter** | **Étape 4: Résultats** |
|:---:|:---:|:---:|:---:|
| Parcourez et sélectionnez des vidéos de votre appareil | Configurez les paramètres de compression (algorithme, résolution, format) | Surveillez la progression de compression en temps réel | Visualisez les vidéos comprimées et exportez |
| ![Accueil](docs/mockups/home_page_withvideo.png) | ![Modal de Config](docs/mockups/videoconfigmodal.png) | ![Compression](docs/mockups/process_page_video_compressing.png) | ![Résultats](docs/mockups/process_Page_result_videocompressed.png) |

### Fonctionnalités Avancées

**Paramètres Fins** - Développez le modal de configuration pour un contrôle granulaire des paramètres de compression
![Modal Étendu](docs/mockups/videoconfigmodal_expanded.png)

**Lecture Native** - Visualisez les vidéos comprimées en utilisant le lecteur multimédia natif de votre appareil
![Lecture](docs/mockups/video_player_watching_result.png)

---

## Spécifications Techniques

### Configuration Système Requise

| Composant | Minimum | Recommandé |
|-----------|---------|-----------|
| **Android** | 7.0 (API 24) | 12.0+ (API 31+) |
| **Dart** | 3.6.0 | 3.8.1 |
| **Flutter** | 3.19.0 | 3.32.8 |
| **RAM** | 2GB | 4GB+ |
| **Stockage** | 150MB libres | 500MB+ libres |

### Codecs Supportés

**Codecs Vidéo**: VP8, VP9, H.264, H.265, AV1 (dépend du matériel)
**Codecs Audio**: AAC, Opus, Vorbis
**Conteneurs**: MP4, WebM, MKV
**Formats de Pixels**: Yuv420, Yuv422, Yuv444

### Accélération Matérielle

| Codec | Support |
|-------|---------|
| **H.264** | MediaCodec (matériel) |
| **H.265** | MediaCodec (matériel) |
| **VP9** | MediaCodec (matériel sur 8.0+) |

---

## Architecture

### Stack Technologique

```
Gestion d'État:      Riverpod 2.6.1 (FutureProvider, StateNotifier)
Navigation:          GoRouter 16.2.0 (routage type-safe)
Framework UI:        Flutter Material 3
Traitement Vidéo:    FFmpeg (ffmpeg_kit_flutter_new 4.1.0)
Stockage:            SharedPreferences + Path Provider
Icônes:              Phosphor Flutter 2.1.0
Thématisation:       Flex Color Scheme 8.3.1
Localisation:        Flutter Intl (fichiers .arb)
Permissions:         Permission Handler 12.0.1
Sélection Fichiers:  File Picker 10.3.3
Miniatures:          Video Thumbnail 0.5.6
```

### Structure du Projet

```
lib/
├── core/                              # Architecture et utilitaires du noyau
│   ├── accessibility/                # Aides à l'accessibilité
│   ├── constants/                    # Constantes, jetons de design, animations
│   ├── error/                        # Gestion et définitions des erreurs
│   ├── extensions/                   # Extensions Dart
│   ├── hardware/                     # Logique de détection matérielle
│   ├── logging/                      # Utilitaires de journalisation
│   ├── performance/                  # Gestion de la mémoire
│   ├── result/                       # Modèle de type Result
│   ├── services/                     # Services du noyau
│   └── validation/                   # Logique de validation
│
├── data/                              # Couche de données
│   ├── repositories/                 # Implémentations des dépôts
│   └── services/                     # Services de données (FFmpeg, MediaStore, etc.)
│
├── domain/                            # Couche de domaine (Logique Métier)
│   ├── models/                       # Modèles de domaine
│   ├── repositories/                 # Interfaces des dépôts
│   └── usecases/                     # Cas d'utilisation de l'application
│
├── l10n/                              # Fichiers de localisation (.arb)
│
├── models/                            # Modèles de données partagés
│
├── providers/                         # Gestion d'état (Riverpod)
│
├── router/                            # Configuration de la navigation
│
├── services/                          # Services globaux (Permissions)
│
├── ui/                                # Interface Utilisateur (Widgets et Pages)
│   ├── home/                         # Écran d'accueil
│   ├── process/                      # Écran de traitement
│   ├── settings/                     # Écran des paramètres
│   ├── theme/                        # Configuration du thème
│   └── widgets/                      # Widgets réutilisables
│
└── utils/                             # Utilitaires généraux
│
└── main.dart                          # Point d'entrée de l'application
```

### Services Clés Expliqués

#### VideoProcessorService / VideoProcessorServiceMobile
Gère la compression vidéo basée sur FFmpeg. Construit les commandes FFmpeg en fonction de la configuration, surveille la progression et traite les optimisations spécifiques à la plateforme.

#### VideoMetadataService / VideoMetadataServiceMobile
Extrait les métadonnées vidéo à l'aide de FFprobe: durée, résolution, codec, fps. Génère des miniatures pour l'aperçu UI.

#### HardwareDetectionService
Détecte les capacités du périphérique (cœurs CPU, RAM, codecs disponibles) pour les décisions d'optimisation.

#### FFmpegProgressService
Suivi de la progression en temps réel à partir de l'analyse de la sortie FFmpeg. Convertit le débit/temps en pourcentage d'achèvement.

#### NotificationService
Envoie des notifications système pour la progression de compression et les événements.

#### CacheService
Singleton pour la mise en cache en mémoire et sur disque (SharedPreferences). Stocke les miniatures, les métadonnées, les fichiers récents.

---

## Installation et Configuration

### Prérequis
- **Flutter**: 3.19.0+ ([guide d'installation](https://flutter.dev/docs/get-started/install))
- **Dart**: 3.6.0+ (inclus dans Flutter)
- **SDK Android**: API 24+ pour les compilations Android

### Cloner le Référentiel
```bash
git clone https://github.com/roymejia2217/VCompress.git
cd VCompressor
```

### Installer les Dépendances
```bash
flutter pub get
```

### Générer les Fichiers de Localisation
```bash
flutter gen-l10n
```

### Exécuter l'Application

**Périphérique/Émulateur Android**:
```bash
flutter run -d android
# ou pour un périphérique spécifique
flutter run -d <device_id>
```

**Compilation de Version (Android)**:
```bash
flutter build apk --release
# ou bundle d'application pour Play Store
flutter build appbundle --release
```

---

## Utilisation

### Flux de Travail de Base

1. **Importer des Vidéos**: Appuyez sur le bouton d'importation, sélectionnez une ou plusieurs vidéos
2. **Configurer la Compression**: Choisissez l'algorithme, la résolution, le format (individuel ou par lot)
3. **Surveiller la Progression**: Observez les barres de progression en direct pendant l'importation et la compression
4. **Enregistrer les Vidéos Comprimées**: Les fichiers sont enregistrés dans le répertoire configuré (par défaut: Téléchargements/VCompress)

### Paramètres de Compression

| Paramètre | Options | Notes |
|-----------|---------|-------|
| **Algorithme** | VP8, VP9, H.264, H.265, AV1 | H.265 meilleure compression, H.264 meilleure compatibilité |
| **Résolution** | 720p, 1080p, 2K, 4K, Personnalisé | Réduire la résolution diminue considérablement la taille du fichier |
| **Format** | MP4, WebM, MKV | MP4 plus compatible, WebM plus petit |
| **Qualité** | 18-28 CRF | Inférieur = meilleure qualité, fichiers plus grands |
| **FPS** | Original, 15, 24, 30, 60 | Réduire les fps économise la bande passante |

### Traitement par Lot

Activez le mode par lot pour compresser plusieurs vidéos avec des paramètres cohérents:
1. Sélectionnez plusieurs vidéos lors de l'importation
2. Configurez les paramètres une fois (appliqués à tous)
3. Les processus sont mis en file d'attente automatiquement
4. Surveillez toute la progression dans une seule liste

### Configuration du Stockage

Modifiez le répertoire d'enregistrement dans Paramètres > Stockage > Changer de Dossier. Emplacements personnalisés pris en charge sur Android 11+.

---

## Développement

### Style de Code

- **Format**: Exécutez `flutter format lib/` régulièrement
- **Analyse**: Gardez les avertissements `flutter analyze` à 0
- **Commentaires**: Expliquez le *pourquoi*, pas le *quoi* (le code montre quoi)
- **Nomenclature**: Noms descriptifs avec suffixes pour les classes spécialisées (ex: `_mobile.dart` pour spécifique à la plateforme)

### Flux de Travail Communs

**Flux de Correction de Bogues**:
```bash
flutter analyze
grep -r "search_term" lib/
# (modifier les fichiers)
flutter format lib/
flutter analyze
flutter test
flutter run -d android
```

**Implémentation de Fonctionnalité**:
```bash
# (créer/modifier les fichiers)
flutter format lib/
flutter analyze
flutter test test/unit/
flutter run -d android
```

---

## Tests

### Catégories de Tests

| Catégorie | Emplacement | Objectif |
|-----------|-----------|----------|
| **Unitaires** | `test/unit/` | Logique de service, algorithmes, calculs |
| **Widget** | `test/widget/` | Composants UI, rendu, interactions |
| **Intégration** | `test/integration/` | Flux de bout en bout, multiples services |
| **Accessibilité** | `test/accessibility/` | Lecteurs d'écran, navigation au clavier |
| **Performance** | `test/performance/` | Benchmarks, utilisation mémoire, fréquences d'images |

### Exécuter les Tests

```bash
flutter test
flutter test test/unit/
flutter test test/unit/services/video_processor_service_test.dart
flutter test --coverage
```

---

## Optimisations de Performance

### Gestion de la Mémoire

- **Mise en Cache de Miniatures**: Cache disque pour les miniatures vidéo
- **Chargement Différé**: Les listes utilisent `ListView.builder` pour l'efficacité mémoire
- **Suivi de la Mémoire**: `MemoryManager` suit l'utilisation du tas, déclenche le nettoyage
- **Mise en Cache de Métadonnées**: Extrait une fois, réutilise toutes les opérations

### Optimisation FFmpeg

- **Accélération Matérielle**: Utilise MediaCodec sur Android pour H.264/H.265
- **Codage Guidé par Profil**: Préréglage FFmpeg (ultrafast, superfast, fast) selon le périphérique
- **Traitement par Segments**: Traite la vidéo en segments pour les gros fichiers
- **Tâches Parallèles**: Plusieurs compressions avec mise en file d'attente intelligente

### Performance UI

- **Sélecteurs de Fournisseur**: Observe uniquement l'état nécessaire (`.select()`)
- **Limites de Repaint**: Les barres de progression ne reconstruisent pas la liste entière
- **Constructeurs Const**: Widgets marqués `const` où possible
- **Cache d'Image**: Miniatures cachées avec ImageCache

### Stockage et Réseau

- **Traitement Local**: Tout traitement se fait sur l'appareil
- **E/S Efficace**: SharedPreferences pour les paramètres, Path Provider pour les fichiers
- **Intégration MediaStore**: Utilise Android MediaStore pour la résolution correcte des URI

---

## Compatibilité

### Versions Android

| Version | API | Statut | Notes |
|---------|-----|--------|-------|
| **7.0** | 24 | Compatible | Version minimale |
| **8.0** | 26 | Compatible | Support matériel VP9 |
| **9.0** | 28 | Compatible | Stockage par portée amélioré |
| **11.0+** | 30+ | Recommandé | Stockage par portée complet |
| **14.0+** | 34+ | Support complet | APIs les plus récentes |

---

## Dépannage

### Problèmes Courants

#### Échec de Compilation: "Android SDK not found"
```bash
flutter config --android-sdk /chemin/vers/android-sdk
flutter doctor
```

#### Erreurs FFmpeg Pendant la Compression
```bash
ffmpeg -version
flutter run -d android --verbose
```

#### Timeout Lors de l'Importation de Vidéo (50+ fichiers)
Le timeout d'importation s'ajuste automatiquement: **30 + (nombre de fichiers) secondes**.

#### Manque de Mémoire sur les Gros Fichiers Vidéo
- Fermez les autres applications
- Réduisez la résolution cible
- Videz le cache: Paramètres > Vider le Cache

#### Mode Sombre Non Fonctionnel
Assurez-vous que l'appareil a:
1. "Utiliser le thème du système" activé dans Paramètres
2. Mode sombre du système activé (Android 9+)

---

## Gestion des Dépendances

### Dépendances Principales

| Paquet | Version | Objectif |
|--------|---------|----------|
| **flutter** | 3.32.8 | Framework UI |
| **flutter_riverpod** | 2.6.1 | Gestion d'état |
| **go_router** | 16.2.0 | Navigation |
| **ffmpeg_kit_flutter_new** | 4.1.0 | Traitement vidéo |
| **video_thumbnail** | 0.5.6 | Génération de miniatures |
| **file_picker** | 10.3.3 | Sélection de fichiers |
| **permission_handler** | 12.0.1 | Demande de permissions |
| **flex_color_scheme** | 8.3.1 | Thèmes Material 3 |
| **phosphor_flutter** | 2.1.0 | Icônes (600+) |
| **path_provider** | 2.1.5 | Répertoires d'application |
| **shared_preferences** | 2.5.3 | Paramètres persistants |
| **crypto** | 3.0.7 | Utilitaires cryptographiques |
| **package_info_plus** | 8.0.2 | Informations sur le package |
| **logger** | 2.6.2 | Journalisation |

---

## Décisions Architecturales

### Pourquoi Riverpod?
- Type-safe sans BuildContext
- Gestion exceptionnelle du async
- État avec portée utilisant `.family`
- Testable sans frameworks de mocking

### Pourquoi GoRouter?
- Paramètres de route type-safe
- Support de la liaison profonde
- Arbre de routage déclaratif
- Navigation imbriquée pour les tablettes

### Pourquoi FFmpeg?
- Standard de l'industrie
- Supporte 100+ codecs/conteneurs
- Support de l'accélération matérielle
- Communauté active et mises à jour

### Implémentation Spécifique à la Plateforme
- Fichiers **_mobile.dart** pour la logique spécifique Android
- Optimisé pour Android 7.0+ avec support d'accélération matérielle

---

## Contributions

Les contributions sont bienvenues! S'il vous plaît:

1. **Forkez le référentiel** et créez une branche de fonctionnalité
2. **Codez** en suivant les modèles établis (voir section Développement)
3. **Testez** complètement (unitaires, widget, intégration)
4. **Formatez** avec `flutter format lib/`
5. **Analysez** avec `flutter analyze` (0 avertissements)
6. **Soumettez PR** avec description claire

### Domaines de Contribution

- [ ] Algorithmes de compression supplémentaires
- [ ] Plus de traductions linguistiques
- [ ] Benchmarks de performance
- [ ] Améliorations d'accessibilité

---

## FAQ

Q: Combien de temps la compression vidéo prend-elle généralement?

R: Le temps dépend de la taille vidéo, de la résolution, du codec cible et du matériel de l'appareil. Une vidéo de 100 Mo peut prendre 2-5 minutes sur un appareil de milieu de gamme. L'accélération matérielle (H.264/H.265 avec MediaCodec) réduit considérablement le temps de traitement.

Q: Quelle est la différence entre les algorithmes de compression (VP8, VP9, H.264, H.265)?

R: H.265 offre le meilleur ratio de compression mais l'encodage est plus lent. H.264 équilibre compression et vitesse. VP9 offre l'optimisation web. VP8 est ancien et rarement utilisé. Choisissez H.265 pour une réduction de taille maximale, H.264 pour la compatibilité et la vitesse.

Q: Le fichier vidéo original sera-t-il supprimé après la compression?

R: Non. VCompress enregistre la vidéo comprimée dans un nouveau fichier. Votre original reste intact. Vous pouvez activer la réécriture dans Paramètres si souhaité.

Q: Pourquoi mon appareil chauffe-t-il pendant la compression?

R: La compression vidéo consomme beaucoup de CPU/GPU. Sur les appareils plus anciens, le traitement continu génère de la chaleur. C'est normal. Réduisez la résolution cible ou divisez les grandes vidéos en segments pour minimiser la génération de chaleur.

Q: Quelles autorisations VCompress nécessite-t-il et pourquoi?

R: Stockage: Lire/écrire des fichiers vidéo. Notifications: Afficher la progression de compression. Caméra/Microphone: Non requis; l'application ne les utilise pas. Les autorisations sont demandées au besoin.

Q: Puis-je compresser des vidéos en arrière-plan ou utilisant d'autres applications?

R: Oui. VCompress exécute la compression en tant que service d'arrière-plan. Vous pouvez naviguer, utiliser d'autres applications ou verrouiller l'appareil. Les notifications de progression vous tiennent informé.

Q: Quels formats vidéo sont supportés en entrée?

R: Tout format supporté par FFmpeg: MP4, MKV, AVI, MOV, FLV, WebM, 3GP et autres. Les codecs doivent être reconnus par le décodeur vidéo de votre appareil.

Q: Combien d'espace libre dois-je avoir pour la compression?

R: L'espace temporaire nécessaire durant la compression est approximativement égal à la taille du fichier d'entrée. L'emplacement de sauvegarde doit avoir suffisamment d'espace pour le fichier de sortie. Videz le cache de l'application si l'espace est faible.

Q: Pourquoi la compression est-elle plus lente sur Android 7.0 comparé aux versions plus récentes?

R: Android 7.0 manque de certaines fonctionnalités d'accélération matérielle disponibles sur 8.0+. L'encodage logiciel est plus lent. Mettez à jour si possible, ou réduisez la résolution/qualité pour un traitement plus rapide.

Q: Que dois-je faire si la compression échoue ou se bloque?

R: Vérifiez l'espace disponible (>200 Mo recommandé). Assurez-vous que le fichier vidéo n'est pas corrompu. Redémarrez l'application. Pour les problèmes persistants, signalez avec les informations de l'appareil (sortie `flutter doctor`) et les détails vidéo.

Q: Puis-je compresser dans plusieurs formats en une seule passe?

R: Non. Chaque compression crée un fichier de sortie dans un format. Pour plusieurs sorties, compressez plusieurs fois avec des paramètres différents.

---

## Licence

Licence MIT - Voir le fichier LICENSE pour les détails.

---

## Support

### Documentation
- [CLAUDE.md](./CLAUDE.md) - Directives de développement et décisions architecturales
- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation FFmpeg](https://ffmpeg.org/documentation.html)

### Problèmes et Retours
- Problèmes GitHub: [Problèmes VCompress](https://github.com/roymejia2217/VCompress/issues)
- Rapports de Bogues: Inclure la sortie `flutter doctor` et les étapes pour reproduire
- Demandes de Fonctionnalités: Décrivez le cas d'utilisation et le comportement attendu

## Historique des Versions

| Version | Date | Évolutions |
|---------|------|-----------|
| **2.0.5** | 2026-01-21 | Compatibilité F-Droid (builds reproductibles), désactivation de DependencyInfoBlock |
| **2.0.4** | 2025-11-11 | Mises à jour des dépendances, améliorations des règles ProGuard pour F-Droid |
| **2.0.3** | 2025-11-09 | Minification ProGuard activée, correctifs de configuration FFmpeg Kit |
| **2.0.2** | 2025-11-08 | Ajout de la localisation italienne complète (it) |
| **2.0.1** | 2025-11-07 | Version de maintenance, correctifs de cohérence de localisation |
| **2.0.0** | 2025-11-07 | Version Initiale, Material Design 3, Multilingue, Accélération Matérielle |

---

**Construit avec ❤️ en utilisant Flutter**

Des questions? Ouvrez un problème ou visitez le [référentiel GitHub](https://github.com/roymejia2217/VCompress).