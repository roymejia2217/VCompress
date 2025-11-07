// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VCompress';

  @override
  String get appDescription => 'Compress videos without losing quality';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Application settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get storage => 'Storage';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'Auto';

  @override
  String get saveFolder => 'Save folder';

  @override
  String get changeFolder => 'Change folder';

  @override
  String get noVideosSelected => 'No videos selected';

  @override
  String get import => 'Import';

  @override
  String get processing => 'Processing...';

  @override
  String get compress => 'Compress';

  @override
  String get configurationTitle => 'Compression settings';

  @override
  String configurationBatch(int videoCount) {
    return 'Configuration for $videoCount videos';
  }

  @override
  String get preset => 'Preset';

  @override
  String get outputResolution => 'Output resolution';

  @override
  String get outputFormat => 'Output format';

  @override
  String get removeAudio => 'Remove audio';

  @override
  String get mirrorMode => 'Mirror mode';

  @override
  String get squareFormat => 'Square format';

  @override
  String get adjustSpeed => 'Adjust speed';

  @override
  String get replaceOriginal => 'Replace original';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get advancedSubtitle => 'Editing and technical adjustments';

  @override
  String get applyToAll => 'Apply to all';

  @override
  String get save => 'Save';

  @override
  String configureVideosNow(int videoCount) {
    return 'Configure $videoCount videos now?';
  }

  @override
  String get useSameConfiguration => 'Use same configuration';

  @override
  String get configureIndividually => 'Configure individually';

  @override
  String get completed => 'Completed';

  @override
  String get error => 'Error';

  @override
  String get fileSize => 'File size';

  @override
  String get duration => 'Duration';

  @override
  String get resolution => 'Resolution';

  @override
  String get format => 'Format';

  @override
  String get back => 'Back';

  @override
  String get home => 'Home';

  @override
  String get delete => 'Delete';

  @override
  String get configure => 'Configure';

  @override
  String get cancel => 'Cancel';

  @override
  String get loadingVideos => 'Loading videos';

  @override
  String loadingProgress(int current, int total) {
    return 'Loading $current of $total videos';
  }

  @override
  String get analyzingVideos => 'Analyzing videos';

  @override
  String get permissionGranted => 'Permission granted successfully';

  @override
  String permissionsGranted(int count) {
    return '$count permissions granted successfully';
  }

  @override
  String get saveDirectoryError => 'Could not get save directory';

  @override
  String get compressedVideoPathNotFound => 'Compressed video path not found';

  @override
  String compressedVideoShare(String fileName) {
    return 'Compressed video: $fileName';
  }

  @override
  String compressedVideoSubject(String appName) {
    return 'Compressed video with $appName';
  }

  @override
  String shareError(String errorMessage) {
    return 'Error sharing: $errorMessage';
  }

  @override
  String get results => 'Results';

  @override
  String spaceFreed(String space) {
    return '$space saved';
  }

  @override
  String videosCompressed(int count) {
    return '$count videos compressed';
  }

  @override
  String get compressing => 'Compressing';

  @override
  String videoProgress(int current, int total) {
    return 'Video $current of $total';
  }

  @override
  String get backToHome => 'Back to home';

  @override
  String get resolutionHelperText =>
      'Target height. Aspect ratio is maintained.';

  @override
  String get framesPerSecond => 'Frames per second';

  @override
  String get waiting => 'Waiting...';

  @override
  String percentCompleted(String percent) {
    return '$percent% completed';
  }

  @override
  String completedWithSize(String size) {
    return '$size';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String get cancelCompression => 'Cancel compression';

  @override
  String get configuration => 'Configuration';

  @override
  String get share => 'Share';

  @override
  String get noAudio => 'No audio';

  @override
  String get mirror => 'Mirror';

  @override
  String get square => 'Square';

  @override
  String speedFormat(String speed) {
    return '${speed}x';
  }

  @override
  String fpsFormat(String fps) {
    return '$fps FPS';
  }

  @override
  String get maximaCalidad => 'Maximum Quality';

  @override
  String get excelenteCalidad => 'Excellent Quality';

  @override
  String get buenaCalidad => 'Good Quality';

  @override
  String get compresionMedia => 'Medium Compression';

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
      other: '$count items selected',
      one: '1 item selected',
      zero: 'No items selected',
    );
    return '$_temp0';
  }

  @override
  String filePickerError(String errorMessage) {
    return 'Error selecting files: $errorMessage';
  }

  @override
  String permissionRequestError(String errorMessage) {
    return 'Error requesting permissions: $errorMessage';
  }

  @override
  String get permissionRequired => 'Permissions Required';

  @override
  String get permissionDeniedMessage =>
      'The application needs access to your videos to continue. Please enable permissions in settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get uriResolutionFailed =>
      'Could not get original path, temporary path will be used';
}
