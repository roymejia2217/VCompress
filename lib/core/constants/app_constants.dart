/// Constantes centralizadas de la aplicación
/// Siguiendo las mejores prácticas de Flutter para mantener consistencia
class AppConstants {
  AppConstants._(); // Constructor privado para clase estática

  // Configuración de la aplicación
  static const String appName = 'VCompress';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Compresor de videos inteligente';

  // Configuración de archivos
  static const String defaultSaveFolder = 'VCompress';
  static const List<String> supportedVideoExtensions = [
    '.mp4',
    '.avi',
    '.mov',
    '.mkv',
    '.webm',
    '.flv',
    '.wmv',
    '.m4v',
  ];

  // Formatos de archivo no soportados (para validación)
  static const List<String> unsupportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.tiff',
    '.svg',
  ];

  static const List<String> unsupportedAudioExtensions = [
    '.mp3',
    '.wav',
    '.flac',
    '.aac',
    '.ogg',
    '.wma',
    '.m4a',
    '.opus',
  ];

  static const List<String> unsupportedDocumentExtensions = [
    '.pdf',
    '.doc',
    '.docx',
    '.txt',
    '.rtf',
    '.odt',
    '.xls',
    '.xlsx',
    '.csv',
    '.ods',
    '.ppt',
    '.pptx',
    '.odp',
    '.zip',
    '.rar',
    '.7z',
    '.tar',
    '.gz',
  ];

  // Límite dinámico basado en hardware disponible
  static const int baseMaxFileSizeMB = 2048; // 2GB base
  static const int extendedMaxFileSizeMB = 5120; // 5GB para dispositivos potentes
  static const int ultraMaxFileSizeMB = 10240; // 10GB para dispositivos premium
  static const int minFileSizeBytes = 1024; // 1KB mínimo
  static const int thumbnailQuality = 75;
  static const int thumbnailMaxHeight = 120;

  // Configuración de procesamiento
  static const int longVideoThresholdSeconds = 180; // 3 minutos
  static const int maxConcurrentTasks = 2;
  static const Duration progressUpdateInterval = Duration(milliseconds: 100);
  static const Duration cacheExpiryDuration = Duration(hours: 24);

  // Configuración de UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration loadingDelay = Duration(milliseconds: 500);

  // Configuración de hardware
  static const int defaultCpuCores = 4;
  static const int maxOptimalThreads = 8;
  static const int minOptimalThreads = 1;

  // Configuración de FFmpeg
  static const String ffmpegCommand = 'ffmpeg';
  static const List<String> supportedHwCodecs = [
    'h264_mediacodec',
    'hevc_mediacodec',
    'h264_nvenc',
    'hevc_nvenc',
  ];

  // Configuración de permisos optimizada (principio de menor privilegio)
  static const List<String> requiredPermissions = [
    // Permiso específico para videos (Android 13+)
    'android.permission.READ_MEDIA_VIDEO',

    // Permisos legacy para versiones anteriores
    'android.permission.READ_EXTERNAL_STORAGE',  // Android < 13
    'android.permission.WRITE_EXTERNAL_STORAGE', // Android < 10
  ];

  // Configuración de errores
  static const String errorFileNotFound = 'Archivo no encontrado';
  static const String errorPermissionDenied = 'Permisos denegados';
  static const String errorProcessingFailed = 'Error en el procesamiento';
  static const String errorHardwareDetection = 'Error detectando hardware';

  // Configuración de mensajes
  static const String messageProcessingComplete = 'Procesamiento completado';
  static const String messageCacheCleared = 'Cache limpiado';
  static const String messageSettingsSaved = 'Configuración guardada';

  // Configuración de versiones Android
  static const int androidVersionTiramisu = 33;  // Android 13
  static const int androidVersionQ = 29;         // Android 10
}
