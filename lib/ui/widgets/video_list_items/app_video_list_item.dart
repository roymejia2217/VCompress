import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/domain/models/video_list_item_config.dart';
import 'package:vcompressor/ui/widgets/app_video_player.dart';
import 'package:vcompressor/providers/video_config_provider.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/models/video_task.dart'; // Import para VideoTaskState
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';
import 'package:vcompressor/core/extensions/theme_extensions.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

/// Widget de lista de video usando ListTile NATIVO Material Design 3
///
/// **VARIANTES M3:**
/// - standard: Card elevated + settings/delete (home_page)
/// - compact: ListTile dense sin Card (listas compactas)
/// - results: Card elevated + play/share (process_page)
class AppVideoListItem extends ConsumerWidget {
  final String taskId;
  final AppVideoListItemConfig config;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onTap;
  final String? tooltip;
  final VoidCallback? onDeleteComplete;
  final bool isSelected;

  const AppVideoListItem({
    super.key,
    required this.taskId,
    required this.config,
    this.onSettingsPressed,
    this.onPlayPressed,
    this.onSharePressed,
    this.onCancelPressed,
    this.onDeleteComplete,
    this.onTap,
    this.tooltip,
    this.isSelected = false,
  });

  // Factory helper para results (compatibilidad API)
  const AppVideoListItem.results({
    Key? key,
    required String taskId,
    VoidCallback? onPlayPressed,
    VoidCallback? onSharePressed,
    VoidCallback? onDeleteComplete,
    VoidCallback? onTap,
    String? tooltip,
  }) : this(
         key: key,
         taskId: taskId,
         config: const AppVideoListItemConfig.results(),
         onPlayPressed: onPlayPressed,
         onSharePressed: onSharePressed,
         onDeleteComplete: onDeleteComplete,
         onTap: onTap,
         tooltip: tooltip,
       );

  // Factory helper para process (compatibilidad API)
  const AppVideoListItem.process({
    Key? key,
    required String taskId,
    VoidCallback? onCancelPressed,
    VoidCallback? onTap,
    String? tooltip,
  }) : this(
         key: key,
         taskId: taskId,
         config: const AppVideoListItemConfig.process(),
         onCancelPressed: onCancelPressed,
         onTap: onTap,
         tooltip: tooltip,
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskByIdProvider(taskId));
    if (task == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = context.colorScheme;

    // ListTile NATIVO M3
    final listTile = ListTile(
      dense: config.isDense,
      contentPadding: config.contentPadding, // null = M3 default
      leading: config.showThumbnail
          ? _buildThumbnail(task, theme, colorScheme)
          : null,
      title: Text(task.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: _buildSubtitle(context, ref, task, theme, colorScheme),
      trailing: _buildTrailing(context, ref, task, theme),
      onTap: onTap,
      isThreeLine: _needsThreeLines(ref, task),
      selected: isSelected,
    );

    // Wrapper simplificado basado en config
    return _wrapWithCard(listTile);
  }

  /// Construye wrapper de Card según config.hasCardWrapper
  Widget _wrapWithCard(Widget listTile) {
    if (!config.hasCardWrapper) {
      return listTile; // compact: sin Card
    }

    // standard y results: ambos usan Card elevated (sin outline)
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: AppSpacing.xs,
      ),
      elevation: 1.0, // M3 default elevation
      child: listTile,
    );
  }

  /// Construye thumbnail con M3 constraint (48-56dp según variant)
  /// Material 3: Thumbnails estáticos durante procesamiento (sin play icon)
  Widget _buildThumbnail(
    dynamic task,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final size = config.thumbnailSize; // Derivado del variant

    // M3: Opacity 38% para pending state (disabled)
    final opacity =
        config.variant == AppVideoListItemVariant.process && task.isPending
        ? 0.38
        : 1.0;

    // Config condicional: static durante processing, interactivo cuando completed
    final thumbnailConfig =
        config.variant == AppVideoListItemVariant.process && !task.isCompleted
        ? VideoPlayerConfig.staticThumbnail
        : VideoPlayerConfig.thumbnailForTask(
            task,
            isHomePage: config.variant.isHomePage, // Usa extension
          );

    final thumbnail = AppVideoPlayer.buildTaskThumbnail(
      task: task,
      config: thumbnailConfig,
      width: size,
      height: size,
    );

    return Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(config.thumbnailBorderRadius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  config.thumbnailBorderRadius,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  config.thumbnailBorderRadius - 1,
                ),
                child: thumbnail,
              ),
            ),
            if (isSelected)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(128),
                  borderRadius: BorderRadius.circular(
                    config.thumbnailBorderRadius,
                  ),
                ),
                child: Icon(
                  PhosphorIconsFill.checkCircle,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construye subtitle con contenido condicional
  Widget _buildSubtitle(
    BuildContext context,
    WidgetRef ref,
    dynamic task,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final List<Widget> subtitleLines = [];

    // Caso especial: Process variant muestra progress bar
    if (config.variant == AppVideoListItemVariant.process) {
      return _buildProgressSubtitle(context, ref, task, theme, colorScheme);
    }

    // Línea 1: Configuración del video
    if (config.variant == AppVideoListItemVariant.results) {
      // Results: Menos info, solo algorithm y format (localizado)
      subtitleLines.add(
        Text(
          '${getLocalizedAlgorithmName(task.settings.algorithm, context)} · ${getLocalizedFormatLabel(task.settings.format, context)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );

      // Compression ratio si existe
      if (task.compressionRatio != null) {
        subtitleLines.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    task.originalSizeFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.arrowRight,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Flexible(
                  child: Text(
                    task.compressedSizeFormatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '(${task.compressionRatio!.toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // Standard/compact: Info completa
      subtitleLines.add(
        Text(
          '${getLocalizedAlgorithmName(task.settings.algorithm, context)} · ${getLocalizedResolutionLabel(task.settings.resolution, context)} · ${getLocalizedFormatLabel(task.settings.format, context)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Línea 2: Edit summary si está habilitado
    if (config.showEditSummary) {
      final hasEditSettings = ref.watch(videoHasEditSettingsProvider(task));
      if (hasEditSettings) {
        subtitleLines.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              buildVideoEditSummary(task, context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: subtitleLines,
    );
  }

  /// Construye subtitle con estados visuales para process variant
  /// Material 3: 4 estados distintos (pending, processing, completed, error)
  /// Optimizado con RepaintBoundary para aislar repaints
  Widget _buildProgressSubtitle(
    BuildContext context,
    WidgetRef ref,
    dynamic task,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Material 3: Estados visuales diferenciados
    final taskState = task.state as VideoTaskState;

    return switch (taskState) {
      VideoTaskState.pending => Text(
        AppLocalizations.of(context)!.waiting,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      VideoTaskState.processing => RepaintBoundary(
        // Aísla repaints de animación
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto de progreso
            Text(
              AppLocalizations.of(context)!.percentCompleted(
                (task.displayProgress * 100).toStringAsFixed(0),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Barra de progreso con animación suave (Material 3 spec)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut, // M3 recomienda ease-out
              tween: Tween<double>(
                begin: 0,
                end: task.displayProgress.clamp(0.0, 1.0),
              ),
              builder: (context, animatedProgress, _) {
                return LinearProgressIndicator(
                  value: animatedProgress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),

      VideoTaskState.completed => Row(
        children: [
          Icon(
            PhosphorIconsFill.checkCircle,
            size: 16,
            color: Colors.green.shade400, // Verde pastel M3 para éxito
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              )!.completedWithSize(task.compressedSizeFormatted),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade400,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      VideoTaskState.error => Row(
        children: [
          Icon(
            PhosphorIconsFill.warningCircle,
            size: 16,
            color: colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              task.errorMessage ?? AppLocalizations.of(context)!.unknownError,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      VideoTaskState.cancelled => Row(
        children: [
          Icon(
            PhosphorIconsFill.prohibit,
            size: 16,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.secondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    };
  }

  /// Construye trailing con botones de acción
  /// M3 spec: Botones explícitos para 1-2 acciones
  Widget? _buildTrailing(
    BuildContext context,
    WidgetRef ref,
    dynamic task,
    ThemeData theme,
  ) {
    final List<Widget> actionButtons = [];

    // Settings button (standard)
    if (config.showSettings && onSettingsPressed != null) {
      actionButtons.add(
        IconButton(
          icon: const Icon(PhosphorIconsFill.slidersHorizontal),
          onPressed: onSettingsPressed,
          tooltip: AppLocalizations.of(context)!.configuration,
        ),
      );
    }

    // Play button (results) - REMOVED: Thumbnail already has play functionality

    // Share button (results)
    if (config.variant == AppVideoListItemVariant.results &&
        onSharePressed != null) {
      actionButtons.add(
        IconButton(
          icon: const Icon(PhosphorIconsFill.shareNetwork),
          onPressed: onSharePressed,
          tooltip: AppLocalizations.of(context)!.share,
        ),
      );
    }

    // Cancel button (process) - Solo mostrar si está procesando
    if (config.showCancel && task.isProcessing && onCancelPressed != null) {
      actionButtons.add(
        IconButton(
          icon: const Icon(PhosphorIconsFill.xCircle),
          onPressed: onCancelPressed,
          color: theme.colorScheme.error, // M3: destructive action
          tooltip: AppLocalizations.of(context)!.cancelCompression,
        ),
      );
    }

    // Error icon (process) - Mostrar cuando hay error
    if (config.variant == AppVideoListItemVariant.process && task.hasError) {
      actionButtons.add(
        Icon(PhosphorIconsFill.warningCircle, color: theme.colorScheme.error),
      );
    }

    if (actionButtons.isEmpty) return null;

    // Si solo hay 1 botón, retornarlo directamente
    if (actionButtons.length == 1) {
      return actionButtons.first;
    }

    // Si hay 2 botones, mostrarlos con spacing
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actionButtons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;

        // Añadir spacing entre botones
        if (index > 0) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: AppSpacing.xs),
              button,
            ],
          );
        }

        return button;
      }).toList(),
    );
  }

  bool _needsThreeLines(WidgetRef ref, dynamic task) {
    // Process variant siempre usa isThreeLine para progress bar (accesibilidad M3)
    if (config.variant == AppVideoListItemVariant.process) {
      return true;
    }

    if (config.variant == AppVideoListItemVariant.results &&
        task.compressionRatio != null) {
      return true;
    }

    if (config.showEditSummary) {
      final hasEditSettings = ref.watch(videoHasEditSettingsProvider(task));
      return hasEditSettings;
    }

    return false;
  }
}
