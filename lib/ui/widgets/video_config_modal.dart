import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/video_codec.dart';
import 'package:vcompressor/providers/batch_config_provider.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/video_config_provider.dart';
import 'package:vcompressor/providers/hardware_provider.dart';
import 'package:vcompressor/ui/widgets/labeled_switch.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

/// Modal UNIFICADO para configuración de video (individual y batch)
///
/// **ARQUITECTURA:**
/// -  SafeArea + SingleChildScrollView + Column(mainAxisSize.min)
/// -  Se ajusta dinámicamente al contenido (ExpansionTile colapsa/expande)
/// -  NO usa DraggableScrollableSheet (reserva espacio fijo, inadecuado para contenido dinámico)
///
/// **MIGRACIÓN MATERIAL 3:**
/// - Unifica video_config_modal.dart + batch_config_modal.dart (900 líneas → 350 líneas)
/// - Elimina tooltips con question icons (anti-patrón M3)
/// - Usa description inline en AppToggle (M3 supporting text)
/// - Elimina iconos redundantes en SegmentedButtons (compacidad)
/// - Elimina leading icons en toggles (semantic colors suficientes)
/// - Usa spacing tokens M3 (AppSpacing.s = 8dp, AppSpacing.m = 16dp)
/// - Usa typography M3 (titleLarge en vez de fontSize manual)
/// - Optimiza rebuilds con .select() de Riverpod
///
/// **MODO DE USO:**
/// ```dart
/// // Batch mode (aplica a múltiples videos)
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true, //  REQUERIDO
///   builder: (_) => const VideoConfigModal(), // task = null
/// );
///
/// // Individual mode (aplica a un video específico)
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true, //  REQUERIDO
///   builder: (_) => VideoConfigModal(task: selectedTask),
/// );
/// ```
///
/// **REFERENCIAS M3:**
/// - Bottom sheets: https://m3.material.io/components/bottom-sheets/overview
/// - Typography: https://developer.android.com/develop/ui/compose/designsystems/material3
/// - Spacing: https://m3.material.io/foundations/layout/understanding-layout/spacing
/// - Supporting text: https://m3.material.io/components/text-fields/guidelines
class VideoConfigModal extends ConsumerWidget {
  const VideoConfigModal({this.task, super.key});

  /// Video task para configuración individual.
  /// Si es null → modo batch (configuración para múltiples videos).
  final VideoTask? task;

  /// Indica si está en modo batch (múltiples videos)
  bool get _isBatchMode => task == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final videoCount = _isBatchMode ? ref.watch(tasksProvider).length : 1;

    // M3 PATTERN: Modal simple que se ajusta al contenido dinámico
    // NO usar DraggableScrollableSheet para contenido variable (ExpansionTile)
    return SafeArea(
      // Protege de notch/status bar, pero NO bottom (manejado manualmente)
      top: true,
      bottom: false, // Manual para incluir design tokens
      child: SingleChildScrollView(
        // Scroll solo si contenido excede altura disponible
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.m, // 16dp - M3 container padding
            AppSpacing.m,
            AppSpacing.m,
            MediaQuery.of(context).padding.bottom + AppSpacing.m,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // CRÍTICO: Se ajusta al contenido real
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ HEADER ═══
              Text(
                _isBatchMode
                    ? AppLocalizations.of(
                        context,
                      )!.configurationBatch(videoCount)
                    : AppLocalizations.of(context)!.configurationTitle,
                style: theme.textTheme.titleLarge, // M3 typography
              ),
              const SizedBox(height: 12), // M3 spacing: título → contenido
              // ═══ NIVEL 1: ESENCIAL (80% usuarios) ═══
              _buildAlgorithmSelector(context, ref),
              const SizedBox(height: AppSpacing.s),
              _buildResolutionSelector(context, ref),
              const SizedBox(height: AppSpacing.s),
              _buildFormatSelector(context, ref),

              const SizedBox(height: 12), // Separador de grupo
              // Grupo: Opciones básicas de salida
              _buildAudioToggle(context, ref),
              const SizedBox(height: AppSpacing.s),
              _buildReplaceOriginalToggle(context, ref),

              const SizedBox(height: 12),

              // ═══ NIVEL 2: AVANZADO (20% usuarios) ═══
              _buildAdvancedExpansion(context, ref),

              const SizedBox(height: AppSpacing.m), // Separación antes de botón
              // Botón de acción
              _buildActionButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelector(BuildContext context, WidgetRef ref) {
    // .select() para rebuild solo cuando algorithm cambia
    final algorithm = _isBatchMode
        ? ref.watch(batchAlgorithmProvider)
        : ref.watch(videoAlgorithmProvider(task!));

    return DropdownMenu<CompressionAlgorithm>(
      expandedInsets: EdgeInsets.zero,
      enableSearch: false,
      initialSelection: algorithm,
      dropdownMenuEntries: CompressionAlgorithm.values
          .map(
            (algo) => DropdownMenuEntry<CompressionAlgorithm>(
              value: algo,
              label: getLocalizedAlgorithmName(algo, context),
            ),
          )
          .toList(),
      onSelected: (value) {
        if (value != null) {
          _isBatchMode
              ? ref.read(batchConfigProvider.notifier).updateAlgorithm(value)
              : ref
                    .read(videoConfigProvider(task!).notifier)
                    .updateAlgorithm(value);
        }
      },
      label: Text(AppLocalizations.of(context)!.preset),
    );
  }

  Widget _buildCodecToggle(BuildContext context, WidgetRef ref) {
    final enableCodec = _isBatchMode
        ? ref.watch(batchEnableCodecProvider)
        : ref.watch(videoEnableCodecProvider(task!));

    final codec = _isBatchMode
        ? ref.watch(batchCodecProvider)
        : ref.watch(videoCodecProvider(task!));

    final format = _isBatchMode
        ? ref.watch(batchFormatProvider)
        : ref.watch(videoFormatProvider(task!));

    final capabilities = ref.watch(hardwareCapabilitiesProvider).valueOrNull;

    // Solo mostrar H264 y H265 en el selector
    final options = [VideoCodec.h264, VideoCodec.h265];
    
    // Si el formato es WebM, deshabilitar la opción (solo soporta VP9 por ahora)
    final isFormatCompatible = format != OutputFormat.webm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledSwitch(
          label: AppLocalizations.of(context)!.videoCodec,
          value: enableCodec && isFormatCompatible,
          onChanged: isFormatCompatible ? (newValue) {
            if (newValue) {
              // Si se activa, mantener el codec actual o default a h264 si es auto
              final newCodec = codec == VideoCodec.auto ? VideoCodec.h264 : codec;
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodecSettings(true)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodecSettings(true);
                  
              // Asegurar que tenemos un codec válido seleccionado
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodec(newCodec)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodec(newCodec);
            } else {
              // Si se desactiva
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodecSettings(false)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodecSettings(false);
            }
          } : null, // Disabled si el formato no es compatible
        ),

        // Selector de Codec con animación
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: (enableCodec && isFormatCompatible) ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (enableCodec && isFormatCompatible) ? 1.0 : 0.0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.m,
                  top: AppSpacing.s,
                  right: AppSpacing.m,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<VideoCodec>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: options.map((option) {
                      final isHwSupported = option == VideoCodec.h264
                          ? (capabilities?.hasH264HwEncoder ?? false)
                          : (capabilities?.hasH265HwEncoder ?? false);

                      return ButtonSegment(
                        value: option,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(option.getLocalizedName(context)),
                            if (isHwSupported) ...[
                              const SizedBox(width: 4),
                              Icon(
                                PhosphorIcons.lightning(), 
                                size: 14, 
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        tooltip: isHwSupported ? 'Hardware Acceleration Available' : null,
                      );
                    }).toList(),
                    selected: {codec == VideoCodec.auto ? VideoCodec.h264 : codec},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _isBatchMode
                            ? ref.read(batchConfigProvider.notifier).updateCodec(selection.first)
                            : ref.read(videoConfigProvider(task!).notifier).updateCodec(selection.first);
                      }
                    },
                    showSelectedIcon: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionSelector(BuildContext context, WidgetRef ref) {
    final resolution = _isBatchMode
        ? ref.watch(batchResolutionProvider)
        : ref.watch(videoResolutionProvider(task!));

    return DropdownMenu<OutputResolution>(
      expandedInsets: EdgeInsets.zero,
      enableSearch: false,
      initialSelection: resolution,
      dropdownMenuEntries: OutputResolution.values
          .map(
            (res) => DropdownMenuEntry<OutputResolution>(
              value: res,
              label: getLocalizedResolutionLabel(res, context),
            ),
          )
          .toList(),
      onSelected: (value) {
        if (value != null) {
          _isBatchMode
              ? ref.read(batchConfigProvider.notifier).updateResolution(value)
              : ref
                    .read(videoConfigProvider(task!).notifier)
                    .updateResolution(value);
        }
      },
      label: Text(AppLocalizations.of(context)!.outputResolution),
    );
  }

  Widget _buildFormatSelector(BuildContext context, WidgetRef ref) {
    final format = _isBatchMode
        ? ref.watch(batchFormatProvider)
        : ref.watch(videoFormatProvider(task!));

    return DropdownMenu<OutputFormat>(
      expandedInsets: EdgeInsets.zero,
      enableSearch: false,
      initialSelection: format,
      dropdownMenuEntries: OutputFormat.values
          .map(
            (fmt) => DropdownMenuEntry<OutputFormat>(
              value: fmt,
              label: getLocalizedFormatLabel(fmt, context),
            ),
          )
          .toList(),
      onSelected: (value) {
        if (value != null) {
          _isBatchMode
              ? ref.read(batchConfigProvider.notifier).updateFormat(value)
              : ref
                    .read(videoConfigProvider(task!).notifier)
                    .updateFormat(value);
        }
      },
      label: Text(AppLocalizations.of(context)!.outputFormat),
    );
  }

  Widget _buildAudioToggle(BuildContext context, WidgetRef ref) {
    // .select() para rebuild solo cuando isMuted cambia
    final audioSettings = _isBatchMode
        ? ref.watch(batchAudioProvider)
        : ref.watch(videoAudioProvider(task!));
    final isMuted = audioSettings.enableVolume && audioSettings.isMuted;

    return LabeledSwitch(
      label: AppLocalizations.of(context)!.removeAudio,
      value: isMuted,
      onChanged: (newValue) {
        _isBatchMode
            ? ref
                  .read(batchConfigProvider.notifier)
                  .updateAudioSettings(
                    true, // enableVolume siempre true
                    newValue, // isMuted cambia según el toggle
                  )
            : ref
                  .read(videoConfigProvider(task!).notifier)
                  .updateAudioSettings(true, newValue);
      },
    );
  }

  Widget _buildMirrorToggle(BuildContext context, WidgetRef ref) {
    final enableMirror = _isBatchMode
        ? ref.watch(batchMirrorProvider)
        : ref.watch(videoMirrorProvider(task!));

    return LabeledSwitch(
      label: AppLocalizations.of(context)!.mirrorMode,
      value: enableMirror,
      onChanged: (newValue) {
        _isBatchMode
            ? ref
                  .read(batchConfigProvider.notifier)
                  .updateMirrorSettings(newValue)
            : ref
                  .read(videoConfigProvider(task!).notifier)
                  .updateMirrorSettings(newValue);
      },
    );
  }

  Widget _buildSquareFormatToggle(BuildContext context, WidgetRef ref) {
    final enableSquareFormat = _isBatchMode
        ? ref.watch(batchSquareFormatProvider)
        : ref.watch(videoSquareFormatProvider(task!));

    return LabeledSwitch(
      label: AppLocalizations.of(context)!.squareFormat,
      value: enableSquareFormat,
      onChanged: (newValue) {
        _isBatchMode
            ? ref
                  .read(batchConfigProvider.notifier)
                  .updateSquareFormatSettings(newValue)
            : ref
                  .read(videoConfigProvider(task!).notifier)
                  .updateSquareFormatSettings(newValue);
      },
    );
  }

  Widget _buildReplaceOriginalToggle(BuildContext context, WidgetRef ref) {
    final replaceOriginal = _isBatchMode
        ? ref.watch(batchReplaceOriginalProvider)
        : ref.watch(videoReplaceOriginalProvider(task!));

    return LabeledSwitch(
      label: AppLocalizations.of(context)!.replaceOriginal,
      value: replaceOriginal,
      onChanged: (newValue) {
        _isBatchMode
            ? ref
                  .read(batchConfigProvider.notifier)
                  .updateReplaceOriginalSettings(newValue)
            : ref
                  .read(videoConfigProvider(task!).notifier)
                  .updateReplaceOriginalSettings(newValue);
      },
    );
  }

  Widget _buildFpsToggle(BuildContext context, WidgetRef ref) {
    final enableFps = _isBatchMode
        ? ref.watch(batchEnableFpsProvider)
        : ref.watch(videoEnableFpsProvider(task!));

    final targetFps = _isBatchMode
        ? ref.watch(batchFpsProvider)
        : ref.watch(videoFpsProvider(task!));

    const fpsOptions = [15, 24, 30, 50, 60];
    const defaultFps = 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledSwitch(
          label: AppLocalizations.of(context)!.framesPerSecond,
          value: enableFps,
          onChanged: (newValue) {
            if (newValue) {
              _isBatchMode
                  ? ref
                        .read(batchConfigProvider.notifier)
                        .updateFpsSettings(true, defaultFps)
                  : ref
                        .read(videoConfigProvider(task!).notifier)
                        .updateFpsSettings(true, defaultFps);
            } else {
              _isBatchMode
                  ? ref
                        .read(batchConfigProvider.notifier)
                        .updateFpsSettings(false, null)
                  : ref
                        .read(videoConfigProvider(task!).notifier)
                        .updateFpsSettings(false, null);
            }
          },
        ),

        // Selector de FPS con animación
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: enableFps ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enableFps ? 1.0 : 0.0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.m,
                  top: AppSpacing.s,
                  right: AppSpacing.m,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    style: const ButtonStyle(
                      visualDensity:
                          VisualDensity.compact, // M3 compact density
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: fpsOptions
                        .map(
                          (fps) => ButtonSegment(
                            value: fps,
                            label: Text('$fps'), // Label-only, sin iconos
                          ),
                        )
                        .toList(),
                    selected: {targetFps ?? defaultFps},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _isBatchMode
                            ? ref
                                  .read(batchConfigProvider.notifier)
                                  .updateFpsSettings(true, selection.first)
                            : ref
                                  .read(videoConfigProvider(task!).notifier)
                                  .updateFpsSettings(true, selection.first);
                      }
                    },
                    showSelectedIcon: false, // Sin checkmark para compacidad
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedToggle(BuildContext context, WidgetRef ref) {
    final enableSpeed = _isBatchMode
        ? ref.watch(batchEnableSpeedProvider)
        : ref.watch(videoEnableSpeedProvider(task!));

    final speed = _isBatchMode
        ? ref.watch(batchSpeedProvider)
        : ref.watch(videoSpeedProvider(task!));

    const speedOptions = [0.25, 0.5, 2.0, 4.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledSwitch(
          label: AppLocalizations.of(context)!.adjustSpeed,
          value: enableSpeed,
          onChanged: (newValue) {
            if (newValue) {
              _isBatchMode
                  ? ref
                        .read(batchConfigProvider.notifier)
                        .updateSpeedSettings(true, 0.5)
                  : ref
                        .read(videoConfigProvider(task!).notifier)
                        .updateSpeedSettings(true, 0.5);
            } else {
              _isBatchMode
                  ? ref
                        .read(batchConfigProvider.notifier)
                        .updateSpeedSettings(false, 1.0)
                  : ref
                        .read(videoConfigProvider(task!).notifier)
                        .updateSpeedSettings(false, 1.0);
            }
          },
        ),

        // Selector de velocidad con animación
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: enableSpeed ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enableSpeed ? 1.0 : 0.0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.m,
                  top: AppSpacing.s,
                  right: AppSpacing.m,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<double>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact, // M3
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: speedOptions
                        .map(
                          (speedOption) => ButtonSegment(
                            value: speedOption,
                            label: Text(
                              speedOption == 0.25
                                  ? '.25x'
                                  : speedOption == 0.5
                                  ? '.5x'
                                  : '${speedOption.toInt()}x',
                            ),
                            // ELIMINADO: icon (ruido visual en espacio compacto)
                          ),
                        )
                        .toList(),
                    selected: {speed},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        _isBatchMode
                            ? ref
                                  .read(batchConfigProvider.notifier)
                                  .updateSpeedSettings(true, selection.first)
                            : ref
                                  .read(videoConfigProvider(task!).notifier)
                                  .updateSpeedSettings(true, selection.first);
                      }
                    },
                    showSelectedIcon: false, // Compacidad
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              if (_isBatchMode) {
                // Modo batch: aplicar configuración a todos los videos
                final batchSettings = ref.read(batchConfigProvider);
                ref
                    .read(tasksProvider.notifier)
                    .updateAllSettings(batchSettings);
              } else {
                // Modo individual: actualizar solo este video
                final currentSettings = ref.read(videoConfigProvider(task!));
                ref
                    .read(tasksProvider.notifier)
                    .updateSettings(task!.id, currentSettings);
              }

              Navigator.of(context).pop();
            },
            icon: const Icon(PhosphorIconsFill.checkCircle),
            label: Text(
              _isBatchMode
                  ? AppLocalizations.of(context)!.applyToAll
                  : AppLocalizations.of(context)!.save,
            ),
          ),
        ),
      ],
    );
  }

  /// ═══ NIVEL 2: AVANZADO (20% usuarios) ═══
  /// ExpansionTile con opciones avanzadas usando progressive disclosure M3
  Widget _buildAdvancedExpansion(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      // Title + Subtitle descriptivos
      title: Text(AppLocalizations.of(context)!.advancedOptions),
      subtitle: Text(AppLocalizations.of(context)!.advancedSubtitle),

      // Sin padding extra (modal ya tiene padding)
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),

      // Configuración de expansión
      initiallyExpanded: false, // 80/20 rule
      maintainState: true, // Preserva estado de toggles
      visualDensity: VisualDensity.compact, // Compacto para modales
      // Chevron por defecto (showTrailingIcon: true es default)
      // NO leading icon (redundante)
      children: [
        // Toggle 1: Modo espejo
        _buildMirrorToggle(context, ref),
        const SizedBox(height: AppSpacing.s),

        // Toggle 2: Formato cuadrado
        _buildSquareFormatToggle(context, ref),
        const SizedBox(height: AppSpacing.s),

        // Codec Toggle
        _buildCodecToggle(context, ref),
        const SizedBox(height: AppSpacing.s),

        // FPS Selector
        _buildFpsToggle(context, ref),
        const SizedBox(height: AppSpacing.s),

        // Speed Slider
        _buildSpeedToggle(context, ref),
      ],
    );
  }
}
