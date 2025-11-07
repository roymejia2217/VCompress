// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'VCompress';

  @override
  String get appDescription => 'Comprime videos sin perder calidad';

  @override
  String get settings => 'Configuración';

  @override
  String get settingsSubtitle => 'Ajustes de la aplicación';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get french => 'Francés';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Auto';

  @override
  String get saveFolder => 'Carpeta de guardado';

  @override
  String get changeFolder => 'Cambiar carpeta';

  @override
  String get noVideosSelected => 'No hay videos seleccionados';

  @override
  String get import => 'Importar';

  @override
  String get processing => 'Procesando...';

  @override
  String get compress => 'Comprimir';

  @override
  String get configurationTitle => 'Configuración de compresión';

  @override
  String configurationBatch(int videoCount) {
    return 'Configuración para $videoCount videos';
  }

  @override
  String get preset => 'Preset';

  @override
  String get outputResolution => 'Resolución de salida';

  @override
  String get outputFormat => 'Formato de salida';

  @override
  String get removeAudio => 'Quitar audio';

  @override
  String get mirrorMode => 'Modo espejo';

  @override
  String get squareFormat => 'Formato cuadrado';

  @override
  String get adjustSpeed => 'Ajustar velocidad';

  @override
  String get replaceOriginal => 'Reemplazar original';

  @override
  String get advancedOptions => 'Opciones avanzadas';

  @override
  String get advancedSubtitle => 'Edición y ajustes técnicos';

  @override
  String get applyToAll => 'Aplicar a todos';

  @override
  String get save => 'Guardar';

  @override
  String configureVideosNow(int videoCount) {
    return '¿Configurar $videoCount videos ahora?';
  }

  @override
  String get useSameConfiguration => 'Usar misma configuración';

  @override
  String get configureIndividually => 'Configurar individualmente';

  @override
  String get completed => 'Completado';

  @override
  String get error => 'Error';

  @override
  String get fileSize => 'Tamaño del archivo';

  @override
  String get duration => 'Duración';

  @override
  String get resolution => 'Resolución';

  @override
  String get format => 'Formato';

  @override
  String get back => 'Volver';

  @override
  String get home => 'Inicio';

  @override
  String get delete => 'Eliminar';

  @override
  String get configure => 'Configurar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get loadingVideos => 'Cargando videos';

  @override
  String loadingProgress(int current, int total) {
    return 'Cargando $current de $total videos';
  }

  @override
  String get analyzingVideos => 'Analizando videos';

  @override
  String get permissionGranted => 'Permiso concedido correctamente';

  @override
  String permissionsGranted(int count) {
    return '$count permisos concedidos correctamente';
  }

  @override
  String get saveDirectoryError =>
      'No se pudo obtener el directorio de guardado';

  @override
  String get compressedVideoPathNotFound =>
      'No se encontró la ruta del video comprimido';

  @override
  String compressedVideoShare(String fileName) {
    return 'Video comprimido: $fileName';
  }

  @override
  String compressedVideoSubject(String appName) {
    return 'Video comprimido con $appName';
  }

  @override
  String shareError(String errorMessage) {
    return 'Error al compartir: $errorMessage';
  }

  @override
  String get results => 'Resultados';

  @override
  String spaceFreed(String space) {
    return '$space liberados';
  }

  @override
  String videosCompressed(int count) {
    return '$count videos comprimidos';
  }

  @override
  String get compressing => 'Comprimiendo';

  @override
  String videoProgress(int current, int total) {
    return 'Video $current de $total';
  }

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get resolutionHelperText =>
      'Altura objetivo. Se mantiene la relación de aspecto.';

  @override
  String get framesPerSecond => 'Fotogramas por segundo';

  @override
  String get waiting => 'En espera...';

  @override
  String percentCompleted(String percent) {
    return '$percent% completado';
  }

  @override
  String completedWithSize(String size) {
    return '$size';
  }

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get cancelCompression => 'Cancelar compresión';

  @override
  String get configuration => 'Configuración';

  @override
  String get share => 'Compartir';

  @override
  String get noAudio => 'Sin audio';

  @override
  String get mirror => 'Espejo';

  @override
  String get square => 'Cuadrado';

  @override
  String speedFormat(String speed) {
    return '${speed}x';
  }

  @override
  String fpsFormat(String fps) {
    return '$fps FPS';
  }

  @override
  String get maximaCalidad => 'Máxima Calidad';

  @override
  String get excelenteCalidad => 'Excelente Calidad';

  @override
  String get buenaCalidad => 'Buena Calidad';

  @override
  String get compresionMedia => 'Compresión Media';

  @override
  String get ultraCompresion => 'Ultra Compresión';

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
      other: '$count seleccionados',
      one: '1 seleccionado',
      zero: 'No seleccionados',
    );
    return '$_temp0';
  }

  @override
  String filePickerError(String errorMessage) {
    return 'Error al seleccionar archivos: $errorMessage';
  }

  @override
  String permissionRequestError(String errorMessage) {
    return 'Error al solicitar permisos: $errorMessage';
  }

  @override
  String get permissionRequired => 'Permisos requeridos';

  @override
  String get permissionDeniedMessage =>
      'La aplicación necesita acceso a tus videos para continuar. Por favor, habilita los permisos en la configuración.';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get uriResolutionFailed =>
      'No se pudo obtener la ruta original, se usará ruta temporal';
}
