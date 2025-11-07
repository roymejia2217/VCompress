// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'VCompress';

  @override
  String get appDescription => 'Compressez les vidéos sans perdre en qualité';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsSubtitle => 'Paramètres de l\'application';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get spanish => 'Espagnol';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get storage => 'Stockage';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Auto';

  @override
  String get saveFolder => 'Dossier de sauvegarde';

  @override
  String get changeFolder => 'Changer le dossier';

  @override
  String get noVideosSelected => 'Aucune vidéo sélectionnée';

  @override
  String get import => 'Importer';

  @override
  String get processing => 'Traitement...';

  @override
  String get compress => 'Compresser';

  @override
  String get configurationTitle => 'Paramètres de compression';

  @override
  String configurationBatch(int videoCount) {
    return 'Configuration pour $videoCount vidéos';
  }

  @override
  String get preset => 'Préréglage';

  @override
  String get outputResolution => 'Résolution de sortie';

  @override
  String get outputFormat => 'Format de sortie';

  @override
  String get removeAudio => 'Supprimer l\'audio';

  @override
  String get mirrorMode => 'Mode miroir';

  @override
  String get squareFormat => 'Format carré';

  @override
  String get adjustSpeed => 'Ajuster la vitesse';

  @override
  String get replaceOriginal => 'Remplacer l\'original';

  @override
  String get advancedOptions => 'Options avancées';

  @override
  String get advancedSubtitle => 'Édition et ajustements techniques';

  @override
  String get applyToAll => 'Appliquer à tous';

  @override
  String get save => 'Enregistrer';

  @override
  String configureVideosNow(int videoCount) {
    return 'Configurer $videoCount vidéos maintenant ?';
  }

  @override
  String get useSameConfiguration => 'Utiliser la même configuration';

  @override
  String get configureIndividually => 'Configurer individuellement';

  @override
  String get completed => 'Terminé';

  @override
  String get error => 'Erreur';

  @override
  String get fileSize => 'Taille du fichier';

  @override
  String get duration => 'Durée';

  @override
  String get resolution => 'Résolution';

  @override
  String get format => 'Format';

  @override
  String get back => 'Retour';

  @override
  String get home => 'Accueil';

  @override
  String get delete => 'Supprimer';

  @override
  String get configure => 'Configurer';

  @override
  String get cancel => 'Annuler';

  @override
  String get loadingVideos => 'Chargement des vidéos';

  @override
  String loadingProgress(int current, int total) {
    return 'Chargement de la vidéo $current sur $total';
  }

  @override
  String get analyzingVideos => 'Analyse des vidéos';

  @override
  String get permissionGranted => 'Permission accordée avec succès';

  @override
  String permissionsGranted(int count) {
    return '$count permissions accordées avec succès';
  }

  @override
  String get saveDirectoryError =>
      'Impossible d\'obtenir le dossier de sauvegarde';

  @override
  String get compressedVideoPathNotFound =>
      'Chemin de la vidéo compressée introuvable';

  @override
  String compressedVideoShare(String fileName) {
    return 'Vidéo compressée : $fileName';
  }

  @override
  String compressedVideoSubject(String appName) {
    return 'Vidéo compressée avec $appName';
  }

  @override
  String shareError(String errorMessage) {
    return 'Erreur lors du partage : $errorMessage';
  }

  @override
  String get results => 'Résultats';

  @override
  String spaceFreed(String space) {
    return '$space économisé';
  }

  @override
  String videosCompressed(int count) {
    return '$count vidéos compressées';
  }

  @override
  String get compressing => 'Compression';

  @override
  String videoProgress(int current, int total) {
    return 'Vidéo $current sur $total';
  }

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get resolutionHelperText =>
      'Hauteur cible. Le ratio d\'aspect est maintenu.';

  @override
  String get framesPerSecond => 'Images par seconde';

  @override
  String get waiting => 'En attente...';

  @override
  String percentCompleted(String percent) {
    return '$percent% terminé';
  }

  @override
  String completedWithSize(String size) {
    return '$size';
  }

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get cancelCompression => 'Annuler la compression';

  @override
  String get configuration => 'Paramètres';

  @override
  String get share => 'Partager';

  @override
  String get noAudio => 'Sans audio';

  @override
  String get mirror => 'Miroir';

  @override
  String get square => 'Carré';

  @override
  String speedFormat(String speed) {
    return '${speed}x';
  }

  @override
  String fpsFormat(String fps) {
    return '$fps IPS';
  }

  @override
  String get maximaCalidad => 'Qualité Maximale';

  @override
  String get excelenteCalidad => 'Excellente Qualité';

  @override
  String get buenaCalidad => 'Bonne Qualité';

  @override
  String get compresionMedia => 'Compression Moyenne';

  @override
  String get ultraCompresion => 'Ultra Compression';

  @override
  String get original => 'Original';

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
  String selected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments sélectionnés',
      one: '1 élément sélectionné',
      zero: 'Aucun élément sélectionné',
    );
    return '$_temp0';
  }

  @override
  String filePickerError(String errorMessage) {
    return 'Erreur lors de la sélection des fichiers : $errorMessage';
  }

  @override
  String permissionRequestError(String errorMessage) {
    return 'Erreur lors de la demande de permissions : $errorMessage';
  }

  @override
  String get permissionRequired => 'Permissions requises';

  @override
  String get permissionDeniedMessage =>
      'L\'application a besoin d\'accès à vos vidéos pour continuer. Veuillez activer les permissions dans les paramètres.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get uriResolutionFailed =>
      'Impossible d\'obtenir le chemin d\'accès d\'origine, le chemin temporaire sera utilisé';
}
