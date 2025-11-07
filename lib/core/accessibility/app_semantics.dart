import 'package:flutter/material.dart';

/// Sistema centralizado de accesibilidad y semántica
/// Proporciona etiquetas y descripciones consistentes para lectores de pantalla
class AppSemantics {
  AppSemantics._();

  // Etiquetas de navegación
  static const String backButton = 'Volver';
  static const String settingsButton = 'Configuración';
  static const String homeButton = 'Inicio';
  static const String hardwareButton = 'Hardware del dispositivo';

  // Etiquetas de acciones principales
  static const String selectVideosButton = 'Seleccionar videos';
  static const String compressButton = 'Comprimir videos';
  static const String configureButton = 'Configurar';
  static const String deleteButton = 'Eliminar';
  static const String saveButton = 'Guardar';
  static const String cancelButton = 'Cancelar';

  // Etiquetas de configuración
  static const String algorithmDropdown = 'Algoritmo de compresión';
  static const String resolutionDropdown = 'Resolución de salida';
  static const String formatDropdown = 'Formato de salida';
  static const String audioToggle = 'Quitar audio';
  static const String mirrorToggle = 'Modo espejo';
  static const String squareFormatToggle = 'Formato cuadrado';
  static const String speedSelector = 'Ajustar velocidad';

  // Etiquetas de progreso
  static const String processingStatus = 'Procesando';
  static const String loadingStatus = 'Cargando';
  static const String completedStatus = 'Completado';
  static const String errorStatus = 'Error';

  // Etiquetas de información
  static const String fileSize = 'Tamaño del archivo';
  static const String duration = 'Duración';
  static const String resolution = 'Resolución';
  static const String format = 'Formato';

  // Descripciones detalladas
  static const String algorithmDescription =
      'Selecciona el algoritmo de compresión para optimizar calidad y tamaño';
  static const String resolutionDescription =
      'Define la resolución de salida manteniendo la relación de aspecto';
  static const String formatDescription =
      'Elige el formato de salida para el video comprimido';
  static const String audioDescription =
      'Elimina la pista de audio para reducir el tamaño del archivo';
  static const String mirrorDescription =
      'Voltea horizontalmente el video para corregir orientación';
  static const String squareDescription =
      'Convierte el video a formato cuadrado 1:1 ideal para redes sociales';
  static const String speedDescription =
      'Ajusta la velocidad de reproducción del video';

  // Mensajes de estado
  static const String noVideosSelected = 'No hay videos seleccionados';
  static const String videosSelected = 'videos seleccionados';
  static const String processingVideos = 'Procesando videos';
  static const String compressionComplete = 'Compresión completada';
  static const String compressionFailed = 'Error en la compresión';

  // Etiquetas de hardware
  static const String cpuCores = 'Núcleos de CPU';
  static const String gpuInfo = 'Información de GPU';
  static const String hardwareAcceleration = 'Aceleración por hardware';
  static const String h264Support = 'Soporte H.264';
  static const String h265Support = 'Soporte H.265';

  // Etiquetas de configuración de tema
  static const String lightTheme = 'Tema claro';
  static const String darkTheme = 'Tema oscuro';
  static const String systemTheme = 'Tema del sistema';
  static const String saveDirectory = 'Carpeta de guardado';

  // Etiquetas de notificaciones
  static const String successNotification = 'Operación exitosa';
  static const String errorNotification = 'Error en la operación';
  static const String warningNotification = 'Advertencia';
  static const String infoNotification = 'Información';

  // Métodos de ayuda para generar etiquetas dinámicas
  static String videoCount(int count) => '$count $videosSelected';
  static String progressPercent(double percent) =>
      '${(percent * 100).round()}% completado';
  static String fileSizeFormatted(String size) => '$fileSize: $size';
  static String durationFormatted(String duration) => '$duration: $duration';
  static String resolutionFormatted(String resolution) =>
      '$resolution: $resolution';

  // Etiquetas para lectores de pantalla
  static String getSemanticsLabel(String baseLabel, {String? context}) {
    if (context != null) {
      return '$baseLabel, $context';
    }
    return baseLabel;
  }

  static String getSemanticsHint(String action, {String? target}) {
    if (target != null) {
      return '$action $target';
    }
    return action;
  }

  // Configuraciones de semántica para widgets comunes
  static Semantics buttonSemantics({
    required String label,
    String? hint,
    bool enabled = true,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      button: true,
      child: child,
    );
  }

  static Semantics imageSemantics({
    required String label,
    String? hint,
    required Widget child,
  }) {
    return Semantics(label: label, hint: hint, image: true, child: child);
  }

  static Semantics progressSemantics({
    required String label,
    required double value,
    String? hint,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: '${(value * 100).round()}%',
      child: child,
    );
  }

  static Semantics listSemantics({
    required String label,
    required int itemCount,
    String? hint,
    required Widget child,
  }) {
    return Semantics(label: label, hint: hint, child: child);
  }
}

/// Extension para facilitar el uso de semántica en widgets
extension SemanticsExtension on Widget {
  /// Agrega semántica básica a un widget
  Widget withSemantics({
    String? label,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: this,
    );
  }

  /// Agrega semántica de botón
  Widget withButtonSemantics({
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      button: true,
      child: this,
    );
  }

  /// Agrega semántica de imagen
  Widget withImageSemantics({required String label, String? hint}) {
    return Semantics(label: label, hint: hint, image: true, child: this);
  }

  /// Agrega semántica de progreso
  Widget withProgressSemantics({
    required String label,
    required double value,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: '${(value * 100).round()}%',
      child: this,
    );
  }

  /// Agrega semántica de lista
  Widget withListSemantics({
    required String label,
    required int itemCount,
    String? hint,
  }) {
    return Semantics(label: label, hint: hint, child: this);
  }
}
