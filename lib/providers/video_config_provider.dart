import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/models/video_codec.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

/// Provider para manejar la configuración de video de manera optimizada
/// Reemplaza el uso de ValueNotifier con Riverpod para mejor performance
class VideoConfigNotifier extends StateNotifier<VideoSettings> {
  VideoConfigNotifier(super.initialSettings);

  /// Actualiza el algoritmo de compresión
  void updateAlgorithm(CompressionAlgorithm algorithm) {
    state = state.copyWith(algorithm: algorithm);
  }

  /// Actualiza el códec de video
  void updateCodec(VideoCodec codec) {
    state = state.copyWith(codec: codec);
  }

  /// Actualiza la configuración de habilitación de codec manual
  void updateCodecSettings(bool enableCodec) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(enableCodec: enableCodec),
    );
  }

  /// Actualiza la resolución de salida
  void updateResolution(OutputResolution resolution) {
    state = state.copyWith(resolution: resolution);
  }

  /// Actualiza el formato de salida
  void updateFormat(OutputFormat format) {
    state = state.copyWith(format: format);
  }

  /// Actualiza la configuración de audio
  void updateAudioSettings(bool enableVolume, bool isMuted) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(
        enableVolume: enableVolume,
        isMuted: isMuted,
      ),
    );
  }

  /// Actualiza la configuración de espejo
  void updateMirrorSettings(bool enableMirror) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(enableMirror: enableMirror),
    );
  }

  /// Actualiza la configuración de formato cuadrado
  void updateSquareFormatSettings(bool enableSquareFormat) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(
        enableSquareFormat: enableSquareFormat,
      ),
    );
  }

  /// Actualiza la configuración de velocidad
  void updateSpeedSettings(bool enableSpeed, double speed) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(
        enableSpeed: enableSpeed,
        speed: speed,
      ),
    );
  }

  /// Actualiza la configuración de FPS
  void updateFpsSettings(bool enableFps, int? targetFps) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(
        enableFps: enableFps,
        targetFps: targetFps,
      ),
    );
  }

  /// Actualiza la configuración de reemplazo de archivo original
  void updateReplaceOriginalSettings(bool enableReplaceOriginal) {
    state = state.copyWith(
      editSettings: state.editSettings.copyWith(
        replaceOriginalFile: enableReplaceOriginal,
      ),
    );
  }

  /// Actualiza toda la configuración de edición
  void updateEditSettings(VideoEditSettings editSettings) {
    state = state.copyWith(editSettings: editSettings);
  }

  /// Actualiza toda la configuración
  void updateSettings(VideoSettings settings) {
    state = settings;
  }

  /// Resetea la configuración a los valores por defecto
  void resetToDefaults() {
    state = VideoSettings.defaults();
  }
}

/// Provider factory para crear un VideoConfigNotifier para una tarea específica
final videoConfigProvider =
    StateNotifierProvider.family<VideoConfigNotifier, VideoSettings, VideoTask>(
      (ref, task) => VideoConfigNotifier(task.settings),
    );

/// Provider para obtener solo el algoritmo de compresión
final videoAlgorithmProvider = Provider.family<CompressionAlgorithm, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(task).select((settings) => settings.algorithm),
  ),
);

/// Provider para obtener solo el códec de video
final videoCodecProvider = Provider.family<VideoCodec, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(task).select((settings) => settings.codec),
  ),
);

/// Provider para obtener solo la resolución
final videoResolutionProvider = Provider.family<OutputResolution, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(task).select((settings) => settings.resolution),
  ),
);

/// Provider para obtener solo el formato
final videoFormatProvider = Provider.family<OutputFormat, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(task).select((settings) => settings.format),
  ),
);

/// Provider para obtener solo la configuración de audio
final videoAudioProvider =
    Provider.family<({bool enableVolume, bool isMuted}), VideoTask>((
      ref,
      task,
    ) {
      final settings = ref.watch(
        videoConfigProvider(task).select((settings) => settings.editSettings),
      );
      return (enableVolume: settings.enableVolume, isMuted: settings.isMuted);
    });

/// Provider para obtener solo la configuración de espejo
final videoMirrorProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.enableMirror),
  ),
);

/// Provider para obtener solo la configuración de formato cuadrado
final videoSquareFormatProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.enableSquareFormat),
  ),
);

/// Provider para obtener solo la velocidad
final videoSpeedProvider = Provider.family<double, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(task).select((settings) => settings.editSettings.speed),
  ),
);

/// Provider para obtener solo el estado de habilitación de velocidad
final videoEnableSpeedProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.enableSpeed),
  ),
);

/// Provider para obtener solo la configuración de FPS
final videoFpsProvider = Provider.family<int?, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.targetFps),
  ),
);

/// Provider para obtener solo el estado de habilitación de FPS
final videoEnableFpsProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.enableFps),
  ),
);

/// Provider para obtener el estado de habilitación de selección de codec
final videoEnableCodecProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.enableCodec),
  ),
);

/// Provider para obtener solo la configuración de reemplazo de archivo original
final videoReplaceOriginalProvider = Provider.family<bool, VideoTask>(
  (ref, task) => ref.watch(
    videoConfigProvider(
      task,
    ).select((settings) => settings.editSettings.replaceOriginalFile),
  ),
);

/// Provider para obtener un resumen de las configuraciones de edición
/// Requiere BuildContext para localización
String buildVideoEditSummary(VideoTask task, BuildContext context) {
  final settings = task.settings;
  return _buildEditSummary(settings, context);
}

/// Función para obtener el nombre localizado del algoritmo de compresión
String getLocalizedAlgorithmName(
  CompressionAlgorithm algorithm,
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (algorithm) {
    case CompressionAlgorithm.maximaCalidad:
      return l10n.maximaCalidad;
    case CompressionAlgorithm.excelenteCalidad:
      return l10n.excelenteCalidad;
    case CompressionAlgorithm.buenaCalidad:
      return l10n.buenaCalidad;
    case CompressionAlgorithm.compresionMedia:
      return l10n.compresionMedia;
    case CompressionAlgorithm.ultraCompresion:
      return l10n.ultraCompresion;
  }
}

/// Función para obtener la etiqueta localizada de la resolución
String getLocalizedResolutionLabel(
  OutputResolution resolution,
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (resolution) {
    case OutputResolution.original:
      return l10n.original;
    case OutputResolution.p1080:
      return l10n.p1080;
    case OutputResolution.p720:
      return l10n.p720;
    case OutputResolution.p480:
      return l10n.p480;
    case OutputResolution.p360:
      return l10n.p360;
    case OutputResolution.p240:
      return l10n.p240;
    case OutputResolution.p144:
      return l10n.p144;
  }
}

/// Función para obtener la etiqueta localizada del formato
String getLocalizedFormatLabel(OutputFormat format, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (format) {
    case OutputFormat.mp4:
      return l10n.mp4;
    case OutputFormat.avi:
      return l10n.avi;
    case OutputFormat.mov:
      return l10n.mov;
    case OutputFormat.mkv:
      return l10n.mkv;
    case OutputFormat.webm:
      return l10n.webm;
  }
}

/// Provider para verificar si hay configuraciones de edición activas
final videoHasEditSettingsProvider = Provider.family<bool, VideoTask>((
  ref,
  task,
) {
  final settings = ref.watch(videoConfigProvider(task));
  return _hasEditSettings(settings);
});

/// Función auxiliar para construir el resumen de edición
String _buildEditSummary(VideoSettings settings, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final List<String> edits = [];

  if (settings.editSettings.enableVolume && settings.editSettings.isMuted) {
    edits.add(l10n.noAudio);
  }

  if (settings.editSettings.enableMirror) {
    edits.add(l10n.mirror);
  }

  if (settings.editSettings.enableSquareFormat) {
    edits.add(l10n.square);
  }

  if (settings.editSettings.enableSpeed && settings.editSettings.speed != 1.0) {
    edits.add(l10n.speedFormat(settings.editSettings.speed.toStringAsFixed(1)));
  }

  if (settings.editSettings.enableFps &&
      settings.editSettings.targetFps != null) {
    edits.add(l10n.fpsFormat(settings.editSettings.targetFps.toString()));
  }

  if (settings.editSettings.enableCodec) {
    edits.add(settings.codec.name.toUpperCase());
  }

  if (settings.editSettings.replaceOriginalFile) {
    edits.add(l10n.replaceOriginal);
  }

  return edits.join(' • ');
}

/// Función auxiliar para verificar si hay configuraciones de edición
bool _hasEditSettings(VideoSettings settings) {
  return settings.editSettings.enableVolume ||
      settings.editSettings.enableMirror ||
      settings.editSettings.enableSquareFormat ||
      settings.editSettings.enableSpeed ||
      settings.editSettings.enableFps ||
      settings.editSettings.enableCodec ||
      settings.editSettings.replaceOriginalFile;
}
