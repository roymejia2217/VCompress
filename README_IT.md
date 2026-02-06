<div align="center">
  <img src="android/app/src/main/play_store_512.png" alt="Logo VCompress" width="200" height="200">
</div>

# VCompress

[![Licenza: MIT](https://img.shields.io/badge/Licenza-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.8-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green.svg)](https://www.android.com)
[![GitHub Release](https://img.shields.io/github/v/release/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress/releases)
[![Ultimo Commit GitHub](https://img.shields.io/github/last-commit/roymejia2217/VCompress.svg)](https://github.com/roymejia2217/VCompress)

Una potente applicazione Android di compressione video costruita con Flutter. VCompress offre un'ottimizzazione intelligente dei video con accelerazione hardware, elaborazione batch e monitoraggio della progressione in tempo reale.

**Piattaforme**: Android (7.0+) | **Lingue**: [English](README.md) | [Español](README_ES.md) | [Français](README_FR.md) | [Italiano](README_IT.md)

---

## Indice

- [Funzionalità](#funzionalità)
- [Anteprima dell'Interfaccia Utente](#anteprima-dellinterfaccia-utente)
- [Specifiche Tecniche](#specifiche-tecniche)
- [Architettura](#architettura)
- [Installazione e Configurazione](#installazione-e-configurazione)
- [Utilizzo](#utilizzo)
- [Sviluppo](#sviluppo)
- [Test](#test)
- [Ottimizzazioni di Performance](#ottimizzazioni-di-performance)
- [Compatibilità](#compatibilità)
- [Risoluzione dei Problemi](#risoluzione-dei-problemi)
- [Gestione delle Dipendenze](#gestione-delle-dipendenze)
- [Decisioni Architetturali](#decisioni-architetturali)
- [Contribuzioni](#contribuzioni)
- [Domande Frequenti](#domande-frequenti)
- [Licenza](#licenza)
- [Supporto](#supporto)

---

## Funzionalità

### Compressione Principale
- **Algoritmi di Compressione Multipli**: VP8, VP9, H.264, H.265 con supporto di accelerazione hardware
- **Elaborazione Batch**: Comprimi più video simultaneamente con coda intelligente
- **Monitoraggio della Progressione in Tempo Reale**: Indicatori di avanzamento dal vivo per importazione e operazioni di compressione
- **Selezione Intelligente della Risoluzione**: Profili predefiniti (720p, 1080p, 2K, 4K) con opzioni personalizzate
- **Flessibilità del Formato**: Supporto per contenitori di output MP4, WebM, MKV

### Funzionalità Avanzate
- **Rilevamento Hardware**: Rilevamento automatico delle capacità del dispositivo (core CPU, RAM, supporto codec)
- **Integrazione FFmpeg**: Elaborazione video standard industriale con ffmpeg_kit_flutter_new
- **Generazione di Miniature**: Estrazione automatica delle miniature video con caching
- **Estrazione dei Metadati**: Analisi completa dei video (durata, risoluzione, codec, fps)
- **Gestione dei File**: Sostituzione sicura dei file con opzioni di backup e risoluzione URI MediaStore
- **Sistema di Notifiche**: Notifiche di progressione della compressione in tempo reale

### Esperienza Utente
- **Material Design 3**: Interfaccia moderna e reattiva con tematizzazione dinamica dei colori
- **Supporto Multilingue**: Spagnolo (es), Inglese (en), Francese (fr), Italiano (it) con Flutter Intl
- **Impostazioni Localizzate**: Modalità tema (chiaro/scuro/sistema), selezione della lingua, directory di salvataggio personalizzata
- **Modalità Scura**: Supporto completo del tema scuro Material 3 con Flex Color Scheme
- **Accessibilità**: Etichette semantiche, navigazione da tastiera, supporto per lettori di schermo

---

## Anteprima dell'Interfaccia Utente

### Flusso di Compressione

VCompress offre un'interfaccia intuitiva in Material Design 3 che guida gli utenti attraverso il processo di compressione video:

| **Passo 1: Importa** | **Passo 2: Configura** | **Passo 3: Elabora** | **Passo 4: Risultati** |
|:---:|:---:|:---:|:---:|
| Sfoglia e seleziona video dal tuo dispositivo | Configura le impostazioni di compressione (algoritmo, risoluzione, formato) | Monitora la progressione della compressione in tempo reale | Visualizza i video compressi ed esporta |
| ![Home](docs/mockups/home_page_withvideo.png) | ![Modal Config](docs/mockups/videoconfigmodal.png) | ![Compressione](docs/mockups/process_page_video_compressing.png) | ![Risultati](docs/mockups/process_Page_result_videocompressed.png) |

### Funzionalità Avanzate

**Regolazione Fine** - Espandi il modal di configurazione per un controllo granulare dei parametri di compressione
![Modal Espanso](docs/mockups/videoconfigmodal_expanded.png)

**Riproduzione Nativa** - Visualizza i video compressi utilizzando il lettore multimediale nativo del tuo dispositivo
![Riproduzione](docs/mockups/video_player_watching_result.png)

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
| **VP9** | MediaCodec (hardware da 8.0+) |

---

## Architettura

### Stack Tecnologico

```
Gestione dello Stato:     Riverpod 2.6.1 (FutureProvider, StateNotifier)
Navigazione:             GoRouter 16.2.0 (routing type-safe)
Framework UI:            Flutter Material 3
Elaborazione Video:      FFmpeg (ffmpeg_kit_flutter_new 4.1.0)
Archiviazione:           SharedPreferences + Path Provider
Icone:                   Phosphor Flutter 2.1.0
Tematizzazione:          Flex Color Scheme 8.3.1
Localizzazione:          Flutter Intl (file .arb)
Permessi:                Permission Handler 12.0.1
Selezione File:          File Picker 10.3.3
Miniature:               Video Thumbnail 0.5.6
```

### Struttura del Progetto

```
lib/
├── core/                              # Architettura e utilità principali
│   ├── accessibility/                # Aiuti per l'accessibilità
│   ├── constants/                    # Costanti, token di design, animazioni
│   ├── error/                        # Gestione e definizioni degli errori
│   ├── extensions/                   # Estensioni Dart
│   ├── hardware/                     # Logica di rilevamento hardware
│   ├── logging/                      # Utilità di logging
│   ├── performance/                  # Gestione della memoria
│   ├── result/                       # Pattern di tipo Result
│   ├── services/                     # Servizi principali
│   └── validation/                   # Logica di validazione
│
├── data/                              # Livello dati
│   ├── repositories/                 # Implementazioni dei repository
│   └── services/                     # Servizi dati (FFmpeg, MediaStore, ecc.)
│
├── domain/                            # Livello di dominio (Logica di Business)
│   ├── models/                       # Modelli di dominio
│   ├── repositories/                 # Interfacce dei repository
│   └── usecases/                     # Casi d'uso dell'applicazione
│
├── l10n/                              # File di localizzazione (.arb)
│
├── models/                            # Modelli di dati condivisi
│
├── providers/                         # Gestione dello stato (Riverpod)
│
├── router/                            # Configurazione della navigazione
│
├── services/                          # Servizi globali (Permessi)
│
├── ui/                                # Interfaccia Utente (Widget e Pagine)
│   ├── home/                         # Schermata principale
│   ├── process/                      # Schermata di elaborazione
│   ├── settings/                     # Schermata impostazioni
│   ├── theme/                        # Configurazione del tema
│   └── widgets/                      # Widget riutilizzabili
│
└── utils/                             # Utilità generali
│
└── main.dart                          # Punto di ingresso dell'applicazione
```

android/                               # Configurazione specifica Android
├── app/src/main/
│   ├── AndroidManifest.xml           # Manifest Android
│   ├── java/                         # Codice sorgente Java
│   ├── kotlin/                       # Codice sorgente Kotlin
│   └── res/
│       ├── mipmap-*/                 # Icone dell'applicazione
│       ├── values/                   # String, colori, temi
│       └── play_store_512.png        # Icona Play Store
│
├── build.gradle                      # Gradle a livello di progetto
└── settings.gradle                   # Impostazioni Gradle

test/                                  # Suite di test (5 categorie)
├── accessibility/                    # Test di accessibilità
├── integration/                      # Test di integrazione
├── performance/                      # Test di performance
├── unit/                             # Test unitari
└── widget/                           # Test di widget
```

### Servizi Chiave Spiegati

#### VideoProcessorService / VideoProcessorServiceMobile
Gestisce la compressione video basata su FFmpeg. Costruisce i comandi FFmpeg in base alla configurazione, monitora la progressione e gestisce le ottimizzazioni specifiche della piattaforma.

#### VideoMetadataService / VideoMetadataServiceMobile
Estrae i metadati video usando FFprobe: durata, risoluzione, codec, fps. Genera miniature per l'anteprima dell'interfaccia utente.

#### HardwareDetectionService
Rileva le capacità del dispositivo (core CPU, RAM, codec disponibili) per le decisioni di ottimizzazione.

#### FFmpegProgressService
Monitoraggio della progressione in tempo reale dall'analisi dell'output FFmpeg. Converte il bitrate/tempo in percentuale di completamento.

#### NotificationService
Invia notifiche di sistema per la progressione della compressione e gli eventi.

#### CacheService
Singleton per il caching in memoria e su disco (SharedPreferences). Memorizza le miniature, i metadati, i file recenti.

---

## Installazione e Configurazione

### Prerequisiti
- **Flutter**: 3.19.0+ ([guida di installazione](https://flutter.dev/docs/get-started/install))
- **Dart**: 3.6.0+ (incluso in Flutter)
- **Android SDK**: API 24+ per le compilazioni Android

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
# o per un dispositivo specifico
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

### Flusso di Lavoro Base

1. **Importa Video**: Premi il pulsante di importazione, seleziona uno o più video
2. **Configura Compressione**: Scegli l'algoritmo, la risoluzione, il formato (singolo o batch)
3. **Monitora Progressione**: Osserva le barre di progressione dal vivo durante l'importazione e la compressione
4. **Salva Video Compressi**: I file vengono salvati nella directory configurata (default: Download/VCompress)

### Impostazioni di Compressione

| Parametro | Opzioni | Note |
|-----------|---------|-------|
| **Algoritmo** | VP8, VP9, H.264, H.265, AV1 | H.265 migliore compressione, H.264 migliore compatibilità |
| **Risoluzione** | 720p, 1080p, 2K, 4K, Personalizzato | Ridurre la risoluzione diminuisce significativamente la dimensione del file |
| **Formato** | MP4, WebM, MKV | MP4 più compatibile, WebM più piccolo |
| **Qualità** | 18-28 CRF | Minore = migliore qualità, file più grandi |
| **FPS** | Originale, 15, 24, 30, 60 | Ridurre gli fps risparmia larghezza di banda |

### Elaborazione Batch

Abilita la modalità batch per comprimere più video con parametri coerenti:
1. Seleziona più video durante l'importazione
2. Configura i parametri una volta (applicati a tutti)
3. I processi vengono automaticamente messi in coda
4. Monitora l'intero avanzamento in un'unica lista

### Configurazione Archiviazione

Modifica la directory di salvataggio in Impostazioni > Archiviazione > Cambia Cartella. Posizioni personalizzate supportate da Android 11+.

---

## Sviluppo

### Stile del Codice

- **Formato**: Esegui `flutter format lib/` regolarmente
- **Analisi**: Mantieni gli avvisi `flutter analyze` a 0
- **Commenti**: Spiega il *perché*, non il *cosa* (il codice mostra cosa)
- **Nomenclatura**: Nomi descrittivi con suffissi per le classi specializzate (es: `_mobile.dart` per specifico della piattaforma)

### Flussi di Lavoro Comuni

**Flusso di Correzione Bug**:
```bash
flutter analyze
grep -r "search_term" lib/
# (modifica i file)
flutter format lib/
flutter analyze
flutter test
flutter run -d android
```

**Implementazione Funzionalità**:
```bash
# (crea/modifica i file)
flutter format lib/
flutter analyze
flutter test test/unit/
flutter run -d android
```

---

## Test

### Categorie di Test

| Categoria | Posizione | Obiettivo |
|-----------|-----------|----------|
| **Unitari** | `test/unit/` | Logica di servizio, algoritmi, calcoli |
| **Widget** | `test/widget/` | Componenti UI, rendering, interazioni |
| **Integrazione** | `test/integration/` | Flussi end-to-end, servizi multipli |
| **Accessibilità** | `test/accessibility/` | Lettori di schermo, navigazione da tastiera |
| **Performance** | `test/performance/` | Benchmark, utilizzo memoria, frame rate |

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

- **Caching di Miniature**: Cache su disco per le miniature video
- **Caricamento Differito**: Le liste usano `ListView.builder` per l'efficienza della memoria
- **Tracciamento Memoria**: `MemoryManager` traccia l'utilizzo dell'heap, attiva la pulizia
- **Caching Metadati**: Estratto una volta, riutilizzato per tutte le operazioni

### Ottimizzazione FFmpeg

- **Accelerazione Hardware**: Usa MediaCodec su Android per H.264/H.265
- **Codifica Guidata da Profilo**: FFmpeg preset (ultrafast, superfast, fast) in base al dispositivo
- **Elaborazione Segmentata**: Elabora il video in segmenti per file di grandi dimensioni
- **Task Paralleli**: Multiple compressions con coda intelligente

### Performance UI

- **Selettori Provider**: Osserva solo lo stato necessario (`.select()`)
- **Limiti Repaint**: Le barre di progressione non ricostruiscono l'intera lista
- **Costruttori Const**: Widget contrassegnati `const` dove possibile
- **Cache Immagine**: Miniature cachate con ImageCache

### Archiviazione e Rete

- **Elaborazione Locale**: Tutta l'elaborazione avviene sul dispositivo
- **I/O Efficiente**: SharedPreferences per le impostazioni, Path Provider per i file
- **Integrazione MediaStore**: Usa Android MediaStore per la corretta risoluzione degli URI

---

## Compatibilità

### Versioni Android

| Versione | API | Stato | Note |
|---------|-----|--------|-------|
| **7.0** | 24 | Compatibile | Versione minima |
| **8.0** | 26 | Compatibile | Supporto hardware VP9 |
| **9.0** | 28 | Compatibile | Archiviazione scoped migliorata |
| **11.0+** | 30+ | Consigliato | Archiviazione scoped completa |
| **14.0+** | 34+ | Supporto completo | APIs più recenti |

---

## Risoluzione dei Problemi

### Problemi Comuni

#### Errore di Compilazione: "Android SDK not found"
```bash
flutter config --android-sdk /percorso/verso/android-sdk
flutter doctor
```

#### Errori FFmpeg Durante la Compressione
```bash
ffmpeg -version
flutter run -d android --verbose
```

#### Timeout Durante l'Importazione di Video (50+ file)
Il timeout di importazione si regola automaticamente: **30 + (numero di file) secondi**.

#### Memoria Insufficiente su File Video di Grandi Dimensioni
- Chiudi altre applicazioni
- Riduci la risoluzione target
- Svuota la cache: Impostazioni > Svuota Cache

#### Modalità Scura Non Funzionante
Assicurati che il dispositivo abbia:
1. "Usa tema di sistema" abilitato in Impostazioni
2. Modalità scura di sistema abilitata (Android 9+)

---

## Gestione delle Dipendenze

### Dipendenze Principali

| Pacchetto | Versione | Obiettivo |
|---------|---------|----------|
| **flutter** | 3.32.8 | Framework UI |
| **flutter_riverpod** | 2.6.1 | Gestione dello stato |
| **go_router** | 16.2.0 | Navigazione |
| **ffmpeg_kit_flutter_new** | 4.1.0 | Elaborazione video |
| **video_thumbnail** | 0.5.6 | Generazione miniature |
| **file_picker** | 10.3.3 | Selezione file |
| **permission_handler** | 12.0.1 | Richiesta permessi |
| **flex_color_scheme** | 8.3.1 | Temi Material 3 |
| **phosphor_flutter** | 2.1.0 | Icone (600+) |
| **path_provider** | 2.1.5 | Directory app |
| **shared_preferences** | 2.5.3 | Impostazioni persistenti |
| **crypto** | 3.0.7 | Utilità crittografiche |
| **package_info_plus** | 8.0.2 | Informazioni sul pacchetto |
| **logger** | 2.6.2 | Logging |

---

## Decisioni Architetturali

### Perché Riverpod?
- Type-safe senza BuildContext
- Gestione eccezionale dell'async
- Stato con scope usando `.family`
- Testabile senza framework di mocking

### Perché GoRouter?
- Parametri di route type-safe
- Supporto di deep linking
- Albero di routing dichiarativo
- Navigazione annidata per tablet

### Perché FFmpeg?
- Standard industriale
- Supporta 100+ codec/contenitori
- Supporto accelerazione hardware
- Comunità attiva e aggiornamenti

### Implementazione Specifica della Piattaforma
- File **_mobile.dart** per la logica specifica Android
- Ottimizzato per Android 7.0+ con supporto di accelerazione hardware

---

## Contribuzioni

Le contribuzioni sono benvenute! Per favore:

1. **Fai un fork del repository** e crea un ramo di funzionalità
2. **Codifica** seguendo i pattern stabiliti (vedi sezione Sviluppo)
3. **Testa** completamente (unitari, widget, integrazione)
4. **Formatta** con `flutter format lib/`
5. **Analizza** con `flutter analyze` (0 avvisi)
6. **Invia PR** con descrizione chiara

### Aree di Contribuzione

- [ ] Algoritmi di compressione aggiuntivi
- [ ] Più traduzioni linguistiche
- [ ] Benchmark di performance
- [ ] Miglioramenti di accessibilità

---

## Domande Frequenti

D: Quanto tempo impiega tipicamente la compressione video?

R: Il tempo dipende dalla dimensione del video, dalla risoluzione, dal codec target e dall'hardware del dispositivo. Un video di 100 MB può impiegare 2-5 minuti su un dispositivo di fascia media. L'accelerazione hardware (H.264/H.265 con MediaCodec) riduce significativamente il tempo di elaborazione.

D: Qual è la differenza tra gli algoritmi di compressione (VP8, VP9, H.264, H.265)?

R: H.265 offre il migliore rapporto di compressione ma la codifica è più lenta. H.264 equilibra compressione e velocità. VP9 offre l'ottimizzazione web. VP8 è obsoleto e raramente usato. Scegli H.265 per la massima riduzione di dimensione, H.264 per compatibilità e velocità.

D: Il file video originale verrà eliminato dopo la compressione?

R: No. VCompress salva il video compresso in un nuovo file. L'originale rimane intatto. Puoi abilitare la sovrascrittura in Impostazioni se desiderato.

D: Perché il mio dispositivo si riscalda durante la compressione?

R: La compressione video consuma molto CPU/GPU. Su dispositivi più vecchi, l'elaborazione continua genera calore. È normale. Riduci la risoluzione target o dividi i video di grandi dimensioni in segmenti per minimizzare la generazione di calore.

D: Quali permessi richiede VCompress e perché?

R: Archiviazione: Leggere/scrivere file video. Notifiche: Visualizzare la progressione della compressione. Fotocamera/Microfono: Non richiesti; l'applicazione non li usa. I permessi vengono richiesti al bisogno.

D: Posso comprimere video in background o usando altre applicazioni?

R: Sì. VCompress esegue la compressione come servizio in background. Puoi navigare, usare altre applicazioni o bloccare il dispositivo. Le notifiche di progressione ti mantengono informato.

D: Quali formati video sono supportati in input?

R: Qualsiasi formato supportato da FFmpeg: MP4, MKV, AVI, MOV, FLV, WebM, 3GP e altri. I codec devono essere riconosciuti dal decoder video del tuo dispositivo.

D: Quanto spazio libero devo avere per la compressione?

R: Lo spazio temporaneo necessario durante la compressione è approssimativamente uguale alla dimensione del file di input. Il percorso di salvataggio deve avere spazio sufficiente per il file di output. Svuota la cache dell'applicazione se lo spazio è basso.

D: Perché la compressione è più lenta su Android 7.0 rispetto alle versioni più recenti?

R: Android 7.0 manca di alcune funzionalità di accelerazione hardware disponibili su 8.0+. La codifica software è più lenta. Aggiorna se possibile, o riduci la risoluzione/qualità per un'elaborazione più veloce.

D: Cosa devo fare se la compressione fallisce o si blocca?

R: Controlla lo spazio disponibile (>200 MB consigliato). Assicurati che il file video non sia corrotto. Riavvia l'applicazione. Per problemi persistenti, segnala con le informazioni del dispositivo (output `flutter doctor`) e i dettagli del video.

D: Posso comprimere in più formati in una singola sessione?

R: No. Ogni compressione crea un file di output in un formato. Per più output, comprimi più volte con parametri diversi.

---

## Licenza

Licenza MIT - Vedi il file LICENSE per i dettagli.

---

## Supporto

### Documentazione
- [CLAUDE.md](./CLAUDE.md) - Linee guida di sviluppo e decisioni architetturali
- [Documentazione Flutter](https://flutter.dev/docs)
- [Documentazione FFmpeg](https://ffmpeg.org/documentation.html)

### Problemi e Feedback
- Problemi GitHub: [Problemi VCompress](https://github.com/roymejia2217/VCompress/issues)
- Rapporti di Bug: Includi l'output `flutter doctor` e i passaggi per riprodurre
- Richieste di Funzionalità: Descrivi il caso d'uso e il comportamento atteso

## Cronologia delle Versioni

| Versione | Data | Modifiche |
|---------|------|-----------|
| **2.0.5** | 2026-01-21 | Compatibilità F-Droid (build riproducibili), DependencyInfoBlock disabilitato |
| **2.0.4** | 2025-11-11 | Aggiornamento dipendenze, miglioramenti regole ProGuard per F-Droid |
| **2.0.3** | 2025-11-09 | Abilitata minificazione ProGuard, correzioni configurazione FFmpeg Kit |
| **2.0.2** | 2025-11-08 | Aggiunta localizzazione italiana completa (it) |
| **2.0.1** | 2025-11-07 | Rilascio di manutenzione, correzioni coerenza localizzazione |
| **2.0.0** | 2025-11-07 | Rilascio Iniziale, Material Design 3, Multilingua, Accelerazione Hardware |

---

**Costruito con ❤️ usando Flutter**

Hai domande? Apri un problema o visita il [repository GitHub](https://github.com/roymejia2217/VCompress).
