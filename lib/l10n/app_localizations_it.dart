// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'VCompress';

  @override
  String get appDescription => 'Comprimi video senza perdere qualità';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsSubtitle => 'Impostazioni dell\'applicazione';

  @override
  String get appearance => 'Aspetto';

  @override
  String get language => 'Lingua';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get english => 'Inglese';

  @override
  String get french => 'Francese';

  @override
  String get italian => 'Italiano';

  @override
  String get storage => 'Archiviazione';

  @override
  String get loadingSettings => 'Caricamento impostazioni...';

  @override
  String get errorLoadingSettings =>
      'Errore durante il caricamento delle impostazioni';

  @override
  String get retry => 'Riprova';

  @override
  String saveFolderSemantics(String path) {
    return 'Cartella di salvataggio impostata su $path';
  }

  @override
  String get changeFolderSemantics => 'Cambia cartella di salvataggio';

  @override
  String get changeFolderHint => 'Attiva per selezionare una nuova cartella';

  @override
  String invalidFilesCount(int count) {
    return 'File non validi: $count';
  }

  @override
  String get view => 'Vedi';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get system => 'Auto';

  @override
  String get saveFolder => 'Cartella di salvataggio';

  @override
  String get changeFolder => 'Cambia cartella';

  @override
  String get noVideosSelected => 'Nessun video selezionato';

  @override
  String get import => 'Importa';

  @override
  String get processing => 'Elaborazione in corso...';

  @override
  String get compress => 'Comprimi';

  @override
  String get configurationTitle => 'Impostazioni di compressione';

  @override
  String configurationBatch(int videoCount) {
    return 'Configurazione per $videoCount video';
  }

  @override
  String get preset => 'Preimpostazione';

  @override
  String get outputResolution => 'Risoluzione di output';

  @override
  String get outputFormat => 'Formato di output';

  @override
  String get removeAudio => 'Rimuovi audio';

  @override
  String get mirrorMode => 'Modalità specchio';

  @override
  String get squareFormat => 'Formato quadrato';

  @override
  String get adjustSpeed => 'Regola velocità';

  @override
  String get replaceOriginal => 'Sostituisci originale';

  @override
  String get advancedOptions => 'Opzioni avanzate';

  @override
  String get advancedSubtitle => 'Modifica e regolazioni tecniche';

  @override
  String get applyToAll => 'Applica a tutti';

  @override
  String get save => 'Salva';

  @override
  String configureVideosNow(int videoCount) {
    return 'Configurare $videoCount video adesso?';
  }

  @override
  String get useSameConfiguration => 'Usa la stessa configurazione';

  @override
  String get configureIndividually => 'Configura individualmente';

  @override
  String get completed => 'Completato';

  @override
  String get error => 'Errore';

  @override
  String get fileSize => 'Dimensione file';

  @override
  String get duration => 'Durata';

  @override
  String get resolution => 'Risoluzione';

  @override
  String get format => 'Formato';

  @override
  String get back => 'Indietro';

  @override
  String get home => 'Home';

  @override
  String get delete => 'Elimina';

  @override
  String get configure => 'Configura';

  @override
  String get cancel => 'Annulla';

  @override
  String get loadingVideos => 'Caricamento video';

  @override
  String loadingProgress(int current, int total) {
    return 'Caricamento $current di $total video';
  }

  @override
  String get analyzingVideos => 'Analisi dei video';

  @override
  String get permissionGranted => 'Autorizzazione concessa con successo';

  @override
  String permissionsGranted(int count) {
    return '$count autorizzazioni concesse con successo';
  }

  @override
  String get saveDirectoryError =>
      'Impossibile ottenere la cartella di salvataggio';

  @override
  String get compressedVideoPathNotFound =>
      'Percorso video compresso non trovato';

  @override
  String compressedVideoShare(String fileName) {
    return 'Video compresso: $fileName';
  }

  @override
  String compressedVideoSubject(String appName) {
    return 'Video compresso con $appName';
  }

  @override
  String shareError(String errorMessage) {
    return 'Errore nella condivisione: $errorMessage';
  }

  @override
  String get results => 'Risultati';

  @override
  String spaceFreed(String space) {
    return '$space risparmiati';
  }

  @override
  String videosCompressed(int count) {
    return '$count video compressi';
  }

  @override
  String get compressing => 'Compressione';

  @override
  String videoProgress(int current, int total) {
    return 'Video $current di $total';
  }

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get resolutionHelperText =>
      'Altezza target. Le proporzioni vengono mantenute.';

  @override
  String get framesPerSecond => 'Fotogrammi al secondo';

  @override
  String get waiting => 'In attesa...';

  @override
  String percentCompleted(String percent) {
    return '$percent% completato';
  }

  @override
  String completedWithSize(String size) {
    return '$size';
  }

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get cancelCompression => 'Annulla compressione';

  @override
  String get configuration => 'Configurazione';

  @override
  String get share => 'Condividi';

  @override
  String get noAudio => 'Senza audio';

  @override
  String get mirror => 'Specchio';

  @override
  String get square => 'Quadrato';

  @override
  String speedFormat(String speed) {
    return '${speed}x';
  }

  @override
  String fpsFormat(String fps) {
    return '$fps FPS';
  }

  @override
  String get maximaCalidad => 'Qualità Massima';

  @override
  String get excelenteCalidad => 'Qualità Eccellente';

  @override
  String get buenaCalidad => 'Buona Qualità';

  @override
  String get compresionMedia => 'Compressione Media';

  @override
  String get ultraCompresion => 'Ultra Compressione';

  @override
  String get original => 'Originale';

  @override
  String get p1080 => '1080p';

  @override
  String get p720 => '720p';

  @override
  String get p480 => '480p';

  @override
  String get p360 => '360p';

  @override
  String get p240 => '240p';

  @override
  String get p144 => '144p';

  @override
  String get mp4 => 'MP4';

  @override
  String get avi => 'AVI';

  @override
  String get mov => 'MOV';

  @override
  String get mkv => 'MKV';

  @override
  String get webm => 'WebM';

  @override
  String get videoCodec => 'Codec video';

  @override
  String get h264 => 'H.264 (AVC)';

  @override
  String get h265 => 'H.265 (HEVC)';

  @override
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi selezionati',
      one: '1 elemento selezionato',
      zero: 'Nessun elemento selezionato',
    );
    return '$_temp0';
  }

  @override
  String filePickerError(String errorMessage) {
    return 'Errore nella selezione dei file: $errorMessage';
  }

  @override
  String permissionRequestError(String errorMessage) {
    return 'Errore nella richiesta di autorizzazioni: $errorMessage';
  }

  @override
  String get permissionRequired => 'Autorizzazioni Richieste';

  @override
  String get permissionDeniedMessage =>
      'L\'applicazione ha bisogno di accesso ai tuoi video per continuare. Abilita le autorizzazioni nelle impostazioni.';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get uriResolutionFailed =>
      'Impossibile ottenere il percorso originale, verrà utilizzato un percorso temporaneo';

  @override
  String resolutionScale(int percentage) {
    return 'Risoluzione di output: $percentage%';
  }

  @override
  String get scale10Percent => '10%';

  @override
  String get scaleOriginal => 'Originale';

  @override
  String get hardwareAccelerationAvailable =>
      'Accelerazione hardware disponibile';

  @override
  String timeRemaining(String time) {
    return '$time rimanenti';
  }
}
