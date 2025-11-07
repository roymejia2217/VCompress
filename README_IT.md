<div align="center">
  <img src="android/app/src/main/play_store_512.png" alt="Logo VCompress" width="200" height="200">
</div>

# VCompress

[![Licenza: MIT](https://img.shields.io/badge/Licenza-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green.svg)](https://www.android.com)
[![Rilascio GitHub](https://img.shields.io/github/v/release/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress/releases)
[![Ultimo commit GitHub](https://img.shields.io/github/last-commit/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress)

Una potente applicazione Android di compressione video costruita con Flutter. VCompress fornisce ottimizzazione video intelligente con accelerazione hardware, elaborazione in batch e tracciamento della progressione in tempo reale.

**Piattaforme**: Android (7.0+) | **Lingue**: [English](README.md) | [Español](README_ES.md) | [Français](README_FR.md) | [Italiano](README_IT.md)

---

## Funzionalità

### Compressione Principale
- **Algoritmi di Compressione Multipli**: VP8, VP9, H.264, H.265 con supporto di accelerazione hardware
- **Elaborazione in Batch**: Comprimi più video simultaneamente con accodamento intelligente
- **Tracciamento della Progressione in Tempo Reale**: Indicatori di progresso dal vivo per operazioni di importazione e compressione
- **Selezione Intelligente della Risoluzione**: Profili predefiniti (720p, 1080p, 2K, 4K) con opzioni personalizzate
- **Flessibilità di Formato**: Supporto per contenitori di output MP4, WebM, MKV

### Funzionalità Avanzate
- **Rilevamento Hardware**: Rilevamento automatico delle capacità del dispositivo (core CPU, RAM, supporto codec)
- **Integrazione FFmpeg**: Elaborazione video standard del settore con ffmpeg_kit_flutter_new
- **Generazione di Miniature**: Estrazione automatica delle miniature video con caching
- **Estrazione di Metadati**: Analisi completa dei video (durata, risoluzione, codec, fps)
- **Gestione File**: Sostituzione sicura dei file con opzioni di backup e risoluzione URI MediaStore
- **Sistema di Notifiche**: Notifiche di progressione della compressione in tempo reale

### Esperienza Utente
- **Material Design 3**: Interfaccia moderna e reattiva con tematizzazione dinamica dei colori
- **Supporto Multilingue**: Spagnolo (es), Inglese (en), Francese (fr) con Flutter Intl
- **Impostazioni Localizzate**: Modalità tema (chiaro/scuro/sistema), selezione lingua, directory di salvataggio personalizzata
- **Modalità Scura**: Supporto completo del tema scuro Material 3 con Flex Color Scheme
- **Accessibilità**: Etichette semantiche, navigazione da tastiera, supporto per lettori di schermo

---

## Specifiche Tecniche

### Requisiti di Sistema

| Componente | Minimo | Consigliato |
|-----------|--------|-----------|
| **Android** | 7.0 (API 24) | 12.0+ (API 31+) |
| **Dart** | 3.6.0 | 3.8.1 |
| **Flutter** | 3.19.0 | 3.32.8 |
| **RAM** | 2GB | 4GB+ |
| **Archiviazione** | 150MB liberi | 500MB+ liberi |

### Codec Supportati

**Codec Video**: VP8, VP9, H.264, H.265, AV1 (dipende dall'hardware)
**Codec Audio**: AAC, Opus, Vorbis
**Contenitori**: MP4, WebM, MKV
**Formati Pixel**: Yuv420, Yuv422, Yuv444

### Accelerazione Hardware

| Codec | Supporto |
|-------|---------|
| **H.264** | MediaCodec (hardware) |
| **H.265** | MediaCodec (hardware) |
| **VP9** | MediaCodec (hardware su 8.0+) |

---

## Architettura

### Stack Tecnologico

```
Gestione dello Stato: Riverpod 2.6.1 (FutureProvider, StateNotifier)
Navigazione:         GoRouter 16.2.0 (routing type-safe)
Framework UI:        Flutter Material 3
Elaborazione Video:  FFmpeg (ffmpeg_kit_flutter_new 3.2.0)
Archiviazione:       SharedPreferences + Path Provider
Icone:               Phosphor Flutter
Tematizzazione:      Flex Color Scheme 8.2.0
Localizzazione:      Flutter Intl (file .arb)
Permessi:            Permission Handler 12.0.1
Selezione File:      File Picker 10.3.2
Miniature:           Video Thumbnail 0.5.3
```

### Struttura del Progetto

```
lib/
├── core/                              # Logica principale dell'applicazione
│   ├── constants/
│   │   ├── app_constants.dart        # Costanti globali
│   │   └── app_design_tokens.dart    # Spaziatura M3, padding, colori
│   ├── error/
│   │   └── app_error.dart            # Gestione centralizzata degli errori
│   ├── performance/
│   │   └── memory_manager.dart       # Monitoraggio e ottimizzazione della memoria
│   └── result/
│       └── result.dart               # Tipo Result<T, E> generico
│
├── data/                              # Livello dati e servizi
│   ├── repositories/                 # Repository di dati
│   └── services/                     # 15 servizi specializzati
│
├── domain/                            # Logica di business e casi d'uso
│   └── usecases/
│       └── add_video_files_usecase.dart
│
├── models/                            # Modelli di dati
│   ├── video_task.dart               # Attività di compressione video
│   ├── video_settings.dart           # Impostazioni di compressione
│   ├── hardware_info.dart            # Capacità del dispositivo
│   └── compression_result.dart       # Risultati dell'elaborazione
│
├── providers/                         # Gestione dello stato Riverpod (8 provider)
│   ├── batch_config_provider.dart    # Configurazione elaborazione in batch
│   ├── error_handler_provider.dart   # Gestione globale degli errori
│   ├── hardware_provider.dart        # Capacità del dispositivo
│   ├── loading_provider.dart         # Stati di caricamento e progressione
│   ├── settings_provider.dart        # Preferenze dell'utente
│   ├── tasks_provider.dart           # Gestione coda attività
│   ├── video_config_provider.dart    # Configurazione compressione individuale
│   └── video_services_provider.dart  # Provider di servizi
│
├── router/                            # Configurazione navigazione
│   └── app_router.dart               # Configurazione GoRouter
│
├── theme/                             # Temi Material 3
│   └── app_theme.dart                # Configurazione tema (chiaro/scuro)
│
├── ui/                                # Interfaccia utente
│   ├── hardware/                     # Visualizzazione informazioni hardware
│   ├── home/                         # Pagina principale
│   ├── process/                      # Pagina elaborazione video
│   ├── settings/                     # Impostazioni e preferenze
│   ├── theme/                        # Utilità tema
│   ├── video/                        # Widget correlati a video
│   └── widgets/                      # Componenti riutilizzabili
│
├── utils/                             # Funzioni di utilità
│   └── cache_service.dart            # Servizio cache in memoria e su disco
│
├── l10n/                              # Localizzazione
│   ├── app_localizations.dart        # Localizzazioni generate
│   ├── app_es.arb                    # Traduzioni spagnole
│   ├── app_en.arb                    # Traduzioni inglesi
│   └── app_fr.arb                    # Traduzioni francesi
│
├── l10n.yaml                         # Configurazione localizzazione
└── main.dart                         # Punto di ingresso dell'applicazione

android/                               # Configurazione specifica Android
├── app/src/main/
│   ├── AndroidManifest.xml           # Manifest Android
│   ├── java/                         # Codice sorgente Java
│   ├── kotlin/                       # Codice sorgente Kotlin
│   └── res/
│       ├── mipmap-*/                 # Icone dell'applicazione
│       ├── values/                   # Stringhe, colori, temi
│       └── play_store_512.png        # Icona Play Store
│
├── build.gradle                      # Gradle a livello di progetto
└── settings.gradle                   # Impostazioni Gradle

test/                                  # Suite di test (5 categorie)
├── accessibility/                    # Test di accessibilità
├── integration/                      # Test di integrazione
├── performance/                      # Test di performance
├── unit/                             # Test unitari
└── widget/                           # Test widget
```

### Servizi Chiave Spiegati

#### VideoProcessorService / VideoProcessorServiceMobile
Gestisce la compressione video basata su FFmpeg. Costruisce comandi FFmpeg in base alle impostazioni, monitora la progressione e gestisce le ottimizzazioni specifiche della piattaforma.

#### VideoMetadataService / VideoMetadataServiceMobile
Estrae metadati video utilizzando FFprobe: durata, risoluzione, codec, fps. Genera miniature per l'anteprima UI.

#### HardwareDetectionService
Rileva le capacità del dispositivo (core CPU, RAM, codec disponibili) per le decisioni di ottimizzazione.

#### FFmpegProgressService
Tracciamento della progressione in tempo reale dall'analisi dell'output FFmpeg. Converte bitrate/tempo in percentuale di completamento.

#### NotificationService
Invia notifiche di sistema per la progressione della compressione e gli eventi.

#### CacheService
Singleton per il caching in memoria e su disco (SharedPreferences). Memorizza miniature, metadati, file recenti.

---

## Installazione e Configurazione

### Prerequisiti
- **Flutter**: 3.19.0+ ([guida di installazione](https://flutter.dev/docs/get-started/install))
- **Dart**: 3.6.0+ (incluso in Flutter)
- **Android SDK**: API 24+ per build Android

### Clonare il Repository
```bash
git clone https://github.com/roymejia2217/VCompress.git
cd VCompressor
```

### Installare le Dipendenze
```bash
flutter pub get
```

### Generare i File di Localizzazione
```bash
flutter gen-l10n
```

### Eseguire l'Applicazione

**Dispositivo/Emulatore Android**:
```bash
flutter run -d android
# o per dispositivo specifico
flutter run -d <device_id>
```

**Build di Rilascio (Android)**:
```bash
flutter build apk --release
# o bundle app per Play Store
flutter build appbundle --release
```

---

## Utilizzo

### Flusso di Lavoro di Base

1. **Importare Video**: Tocca il pulsante di importazione, seleziona uno o più video
2. **Configurare la Compressione**: Scegli algoritmo, risoluzione, formato (individuale o batch)
3. **Monitorare la Progressione**: Osserva le barre di progresso in tempo reale durante importazione e compressione
4. **Salvare Video Compressi**: I file vengono salvati nella directory configurata (predefinita: Download/VCompress)

### Impostazioni di Compressione

| Impostazione | Opzioni | Note |
|---|---|---|
| **Algoritmo** | VP8, VP9, H.264, H.265, AV1 | H.265 miglior compressione, H.264 miglior compatibilità |
| **Risoluzione** | 720p, 1080p, 2K, 4K, Personalizzato | Ridurre risoluzione riduce significativamente dimensione file |
| **Formato** | MP4, WebM, MKV | MP4 più compatibile, WebM più piccolo |
| **Qualità** | 18-28 CRF | Inferiore = miglior qualità, file più grandi |
| **FPS** | Originale, 15, 24, 30, 60 | Ridurre fps salva larghezza di banda |

### Elaborazione in Batch

Abilita modalità batch per comprimere più video con impostazioni coerenti:
1. Seleziona più video durante l'importazione
2. Configura le impostazioni una volta (applicate a tutti)
3. I processi vengono accodati automaticamente
4. Monitora tutto il progresso in un'unica lista

### Configurazione Archiviazione

Modifica la directory di salvataggio in Impostazioni > Archiviazione > Cambia Cartella. Posizioni personalizzate supportate su Android 11+.

---

## Sviluppo

### Stile di Codice

- **Formato**: Esegui `flutter format lib/` regolarmente
- **Analisi**: Mantieni avvertimenti di `flutter analyze` a 0
- **Commenti**: Spiega il *perché*, non il *cosa* (il codice mostra cosa)
- **Nomenclatura**: Nomi descrittivi con suffissi per classi specializzate (es: `_mobile.dart` per specifico di piattaforma)

### Flussi di Lavoro Comuni

**Flusso di Correzione Bug**:
```bash
flutter analyze
grep -r "search_term" lib/
# (modifica file)
flutter format lib/
flutter analyze
flutter test
flutter run -d android
```

**Implementazione Funzionalità**:
```bash
# (crea/modifica file)
flutter format lib/
flutter analyze
flutter test test/unit/
flutter run -d android
```

---

## Test

### Categorie di Test

| Categoria | Ubicazione | Scopo |
|-----------|-----------|-------|
| **Unitari** | `test/unit/` | Logica servizi, algoritmi, calcoli |
| **Widget** | `test/widget/` | Componenti UI, rendering, interazioni |
| **Integrazione** | `test/integration/` | Flussi end-to-end, servizi multipli |
| **Accessibilità** | `test/accessibility/` | Lettori di schermo, navigazione tastiera |
| **Performance** | `test/performance/` | Benchmark, uso memoria, frequenza fotogrammi |

### Eseguire i Test

```bash
flutter test
flutter test test/unit/
flutter test test/unit/services/video_processor_service_test.dart
flutter test --coverage
```

---

## Ottimizzazioni di Performance

### Gestione della Memoria

- **Caching Miniature**: Cache su disco per miniature video
- **Caricamento Differito**: Le liste usano `ListView.builder` per efficienza memoria
- **Monitoraggio Memoria**: `MemoryManager` traccia uso heap, attiva pulizia
- **Caching Metadati**: Estrae una volta, riutilizza in tutte le operazioni

### Ottimizzazione FFmpeg

- **Accelerazione Hardware**: Usa MediaCodec su Android per H.264/H.265
- **Codifica Guidata da Profilo**: Preset FFmpeg (ultrafast, superfast, fast) secondo dispositivo
- **Elaborazione per Segmenti**: Processa video in segmenti per file grandi
- **Attività Parallele**: Compressioni multiple con accodamento intelligente

### Performance UI

- **Selettori Provider**: Osserva solo stato necessario (`.select()`)
- **Limiti Repaint**: Barre progresso non riconstruiscono intera lista
- **Costruttori Const**: Widget marcati `const` dove possibile
- **Cache Immagine**: Miniature cachate con ImageCache

### Archiviazione e Rete

- **Elaborazione Locale**: Tutta l'elaborazione avviene sul dispositivo
- **I/O Efficiente**: SharedPreferences per impostazioni, Path Provider per file
- **Integrazione MediaStore**: Usa Android MediaStore per corretta risoluzione URI

---

## Compatibilità

### Versioni Android

| Versione | API | Stato | Note |
|----------|-----|-------|-------|
| **7.0** | 24 | Supportato | Versione minima |
| **8.0** | 26 | Supportato | Supporto hardware VP9 |
| **9.0** | 28 | Supportato | Archiviazione per scopo migliorata |
| **11.0+** | 30+ | Consigliato | Archiviazione per scopo completa |
| **14.0+** | 34+ | Supporto completo | API più recenti |

---

## Risoluzione dei Problemi

### Problemi Comuni

#### Build Fallisce: "Android SDK not found"
```bash
flutter config --android-sdk /percorso/a/android-sdk
flutter doctor
```

#### Errori FFmpeg Durante Compressione
```bash
ffmpeg -version
flutter run -d android --verbose
```

#### Timeout Durante Importazione Video (50+ file)
Il timeout di importazione scala automaticamente: **30 + (numero file) secondi**.

#### Memoria Insufficiente su Video Grandi
- Chiudi altre app
- Riduci risoluzione target
- Svuota cache: Impostazioni > Svuota Cache

#### Modalità Scura Non Funziona
Assicurati che il dispositivo abbia:
1. "Usa tema del sistema" abilitato in Impostazioni
2. Modalità scura di sistema attivata (Android 9+)

---

## Gestione Dipendenze

### Dipendenze Principali

| Pacchetto | Versione | Scopo |
|-----------|----------|-------|
| **flutter** | 3.32.8 | Framework UI |
| **flutter_riverpod** | 2.6.1 | Gestione dello stato |
| **go_router** | 16.2.0 | Navigazione |
| **ffmpeg_kit_flutter_new** | 3.2.0 | Elaborazione video |
| **video_thumbnail** | 0.5.3 | Generazione miniature |
| **file_picker** | 10.3.2 | Selezione file |
| **permission_handler** | 12.0.1 | Richiesta permessi |
| **flex_color_scheme** | 8.2.0 | Temi Material 3 |
| **phosphor_flutter** | 2.1.0 | Icone (600+) |
| **path_provider** | 2.1.4 | Directory applicazione |
| **shared_preferences** | 2.3.2 | Impostazioni persistenti |
| **provider** | 6.1.2 | Stato livello widget |

---

## Decisioni Architetturali

### Perché Riverpod?
- Type-safe senza BuildContext
- Eccellente gestione async
- Stato con scope utilizzando `.family`
- Testabile senza framework mocking

### Perché GoRouter?
- Parametri di route type-safe
- Supporto deep linking
- Albero routing dichiarativo
- Navigazione annidata per tablet

### Perché FFmpeg?
- Standard industriale
- Supporta 100+ codec/contenitori
- Supporto accelerazione hardware
- Comunità attiva e aggiornamenti

### Implementazione Specifica Piattaforma
- File **_mobile.dart** per logica specifica Android
- Ottimizzato per Android 7.0+ con supporto accelerazione hardware

---

## Contribuzioni

Le contribuzioni sono benvenute! Per favore:

1. **Fai un fork del repository** e crea un branch di feature
2. **Codifica** seguendo i pattern stabiliti (vedi sezione Sviluppo)
3. **Testa** completamente (unitari, widget, integrazione)
4. **Formatta** con `flutter format lib/`
5. **Analizza** con `flutter analyze` (0 avvertimenti)
6. **Invia PR** con descrizione chiara

### Aree di Contribuzione

- [ ] Algoritmi di compressione aggiuntivi
- [ ] Più traduzioni linguistiche
- [ ] Benchmark di performance
- [ ] Miglioramenti accessibilità

---

## Licenza

Licenza MIT - Vedi file LICENSE per i dettagli.

---

## Supporto

### Documentazione
- [CLAUDE.md](./CLAUDE.md) - Linee guida sviluppo e decisioni architetturali
- [Documentazione Flutter](https://flutter.dev/docs)
- [Documentazione FFmpeg](https://ffmpeg.org/documentation.html)

### Problemi e Feedback
- Problemi GitHub: [Problemi VCompress](https://github.com/roymejia2217/VCompress/issues)
- Report Bug: Includi output `flutter doctor` e step per riprodurre
- Richieste Feature: Descrivi caso d'uso e comportamento atteso

## Cronologia Versioni

| Versione | Data | Evidenziamenti |
|----------|------|-----------|
| **2.0** | 2025-11-06 | Riprogettazione Material 3, ottimizzazione performance, supporto multilingue |
| **1.0** | 2025-10-01 | Rilascio iniziale, compressione base, supporto Android |

---

**Costruito con ❤️ usando Flutter**

Domande? Apri un problema o visita il [repository GitHub](https://github.com/roymejia2217/VCompress).
