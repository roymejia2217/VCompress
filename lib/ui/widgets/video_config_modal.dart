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
class VideoConfigModal extends ConsumerWidget {
  const VideoConfigModal({this.task, super.key});

  final VideoTask? task;

  bool get _isBatchMode => task == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final videoCount = _isBatchMode ? ref.watch(tasksProvider).length : 1;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            MediaQuery.of(context).padding.bottom + AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ HEADER ═══
              Text(
                _isBatchMode
                    ? AppLocalizations.of(
                        context,
                      )!.configurationBatch(videoCount)
                    : AppLocalizations.of(context)!.configurationTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              
              // ═══ NIVEL 1: ESENCIAL (80% usuarios) ═══
              
              // Preset + Format en la misma fila (Petición usuario)
              Row(
                children: [
                  Expanded(child: _buildAlgorithmSelector(context, ref)),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(child: _buildFormatSelector(context, ref)),
                ],
              ),
              
              const SizedBox(height: AppSpacing.m),
              
              // Slider de Escala (Sustituye a Resolución fija)
              _buildScaleSlider(context, ref),

              const SizedBox(height: 12),
              
              // Grupo: Opciones básicas de salida
              _buildAudioToggle(context, ref),
              const SizedBox(height: AppSpacing.s),
              _buildReplaceOriginalToggle(context, ref),

              const SizedBox(height: 12),

              // ═══ NIVEL 2: AVANZADO (20% usuarios) ═══
              _buildAdvancedExpansion(context, ref),

              const SizedBox(height: AppSpacing.m),
              // Botón de acción
              _buildActionButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelector(BuildContext context, WidgetRef ref) {
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

  /// Slider de escala M3 (0.1 a 1.0)
  Widget _buildScaleSlider(BuildContext context, WidgetRef ref) {
    final scale = _isBatchMode
        ? ref.watch(batchScaleProvider)
        : ref.watch(videoScaleProvider(task!));

    final theme = Theme.of(context);
    final percentage = (scale * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // "Resolución (Escala)" o similar. Usamos string hardcoded por falta de key,
              // pero idealmente deberíamos agregar 'resolutionScale' al ARB.
              // Usamos 'outputResolution' existente para mantener compatibilidad.
              "${AppLocalizations.of(context)!.outputResolution}: $percentage%",
              style: theme.textTheme.titleSmall,
            ),
            if (task != null && task!.videoWidth != null && task!.videoHeight != null)
              Text(
                "${(task!.videoWidth! * scale).round()}x${(task!.videoHeight! * scale).round()}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        Slider(
          value: scale,
          min: 0.1,
          max: 1.0,
          divisions: 18, // Pasos de 5% (0.1, 0.15 ... 1.0) -> 90 / 5 = 18 pasos
          label: "$percentage%",
          onChanged: (value) {
            _isBatchMode
                ? ref.read(batchConfigProvider.notifier).updateScale(value)
                : ref
                      .read(videoConfigProvider(task!).notifier)
                      .updateScale(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("10%", style: theme.textTheme.labelSmall),
              Text("Original", style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ],
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

    final options = [VideoCodec.h264, VideoCodec.h265];
    final isFormatCompatible = format != OutputFormat.webm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledSwitch(
          label: AppLocalizations.of(context)!.videoCodec,
          value: enableCodec && isFormatCompatible,
          onChanged: isFormatCompatible ? (newValue) {
            if (newValue) {
              final newCodec = codec == VideoCodec.auto ? VideoCodec.h264 : codec;
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodecSettings(true)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodecSettings(true);
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodec(newCodec)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodec(newCodec);
            } else {
              _isBatchMode
                  ? ref.read(batchConfigProvider.notifier).updateCodecSettings(false)
                  : ref.read(videoConfigProvider(task!).notifier).updateCodecSettings(false);
            }
          } : null,
        ),

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

  Widget _buildAudioToggle(BuildContext context, WidgetRef ref) {
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
                    true,
                    newValue,
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
                          VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: fpsOptions
                        .map(
                          (fps) => ButtonSegment(
                            value: fps,
                            label: Text('$fps'),
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
                      visualDensity: VisualDensity.compact,
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

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              if (_isBatchMode) {
                final batchSettings = ref.read(batchConfigProvider);
                ref
                    .read(tasksProvider.notifier)
                    .updateAllSettings(batchSettings);
              } else {
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

  Widget _buildAdvancedExpansion(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      title: Text(AppLocalizations.of(context)!.advancedOptions),
      subtitle: Text(AppLocalizations.of(context)!.advancedSubtitle),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      initiallyExpanded: false,
      maintainState: true,
      visualDensity: VisualDensity.compact,
      children: [
        _buildMirrorToggle(context, ref),
        const SizedBox(height: AppSpacing.s),
        _buildSquareFormatToggle(context, ref),
        const SizedBox(height: AppSpacing.s),
        _buildCodecToggle(context, ref),
        const SizedBox(height: AppSpacing.s),
        _buildFpsToggle(context, ref),
        const SizedBox(height: AppSpacing.s),
        _buildSpeedToggle(context, ref),
      ],
    );
  }
}