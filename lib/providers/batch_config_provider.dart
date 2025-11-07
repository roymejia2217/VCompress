import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/providers/video_config_provider.dart';

/// Provider para manejar la configuración batch (aplicada a todos los videos)
/// SOLID: Reutiliza VideoConfigNotifier de video_config_provider
/// DRY: No duplica código, importa clase existente

/// Provider GLOBAL para configuración batch (no family)
/// Inicializado con valores por defecto
final batchConfigProvider =
    StateNotifierProvider<VideoConfigNotifier, VideoSettings>(
      (ref) => VideoConfigNotifier(VideoSettings.defaults()),
    );

/// Providers selectores para batch config (sin family)
final batchAlgorithmProvider = Provider<CompressionAlgorithm>(
  (ref) =>
      ref.watch(batchConfigProvider.select((settings) => settings.algorithm)),
);

final batchResolutionProvider = Provider<OutputResolution>(
  (ref) =>
      ref.watch(batchConfigProvider.select((settings) => settings.resolution)),
);

final batchFormatProvider = Provider<OutputFormat>(
  (ref) => ref.watch(batchConfigProvider.select((settings) => settings.format)),
);

final batchAudioProvider = Provider<({bool enableVolume, bool isMuted})>((ref) {
  final settings = ref.watch(
    batchConfigProvider.select((settings) => settings.editSettings),
  );
  return (enableVolume: settings.enableVolume, isMuted: settings.isMuted);
});

final batchMirrorProvider = Provider<bool>(
  (ref) => ref.watch(
    batchConfigProvider.select(
      (settings) => settings.editSettings.enableMirror,
    ),
  ),
);

final batchSquareFormatProvider = Provider<bool>(
  (ref) => ref.watch(
    batchConfigProvider.select(
      (settings) => settings.editSettings.enableSquareFormat,
    ),
  ),
);

final batchSpeedProvider = Provider<double>(
  (ref) => ref.watch(
    batchConfigProvider.select((settings) => settings.editSettings.speed),
  ),
);

final batchEnableSpeedProvider = Provider<bool>(
  (ref) => ref.watch(
    batchConfigProvider.select((settings) => settings.editSettings.enableSpeed),
  ),
);

final batchFpsProvider = Provider<int?>(
  (ref) => ref.watch(
    batchConfigProvider.select((settings) => settings.editSettings.targetFps),
  ),
);

final batchEnableFpsProvider = Provider<bool>(
  (ref) => ref.watch(
    batchConfigProvider.select((settings) => settings.editSettings.enableFps),
  ),
);

final batchReplaceOriginalProvider = Provider<bool>(
  (ref) => ref.watch(
    batchConfigProvider.select(
      (settings) => settings.editSettings.replaceOriginalFile,
    ),
  ),
);
