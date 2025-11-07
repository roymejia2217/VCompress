import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart' as tokens;
import 'package:vcompressor/ui/widgets/app_icons.dart';
import 'package:vcompressor/ui/widgets/notifications/notifications.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Importar AppIconSizes para tamaños de iconos
import 'package:vcompressor/core/constants/app_design_tokens.dart';

/// Enumeraciones para el sistema unificado de reproducción de videos
enum VideoPlayerType {
  external, // Abrir con aplicación externa (open_file)
  thumbnail, // Thumbnail con reproducción externa (usado en listas)
}

/// Contexto de reproducción para seleccionar ruta correcta del video
enum VideoPlaybackContext {
  original, // Usar inputPath (video original sin procesar)
  processed, // Usar outputPath (video procesado/comprimido)
  auto, // Automático: outputPath si existe, sino inputPath
}

enum VideoPlayerSize {
  small, // 60x60 (thumbnail pequeño)
  medium, // 120x120 (thumbnail mediano)
  large, // 200x200 (thumbnail grande)
}

/// Configuración del reproductor de video
class VideoPlayerConfig {
  final VideoPlayerType type;
  final VideoPlayerSize size;
  final bool showPlayIcon;
  final bool showOverlay;
  final Color? overlayColor;
  final double overlayOpacity;
  final bool enableTapToPlay;
  final VideoPlaybackContext playbackContext; // Contexto para seleccionar ruta

  const VideoPlayerConfig({
    this.type = VideoPlayerType.external,
    this.size = VideoPlayerSize.medium,
    this.showPlayIcon = true,
    this.showOverlay = true,
    this.overlayColor,
    this.overlayOpacity = 0.3,
    this.enableTapToPlay = true,
    this.playbackContext = VideoPlaybackContext.auto,
  });

  /// Configuraciones predefinidas
  /// thumbnail: Thumbnail pequeño con reproducción externa (usado en listas)
  static const VideoPlayerConfig thumbnail = VideoPlayerConfig(
    type: VideoPlayerType.thumbnail,
    size: VideoPlayerSize.small,
    showPlayIcon: true,
    showOverlay: true,
    overlayOpacity: 0.2,
    enableTapToPlay: true,
    playbackContext:
        VideoPlaybackContext.processed, // Video procesado en listas
  );

  ///  Factory constructor dinámico basado en VideoTask
  factory VideoPlayerConfig.thumbnailForTask(
    VideoTask task, {
    bool isHomePage = false, // Named optional parameter
  }) {
    // Lógica condicional basada en contexto
    final VideoPlaybackContext context;

    if (task.settings.editSettings.replaceOriginalFile) {
      // Si se reemplaza: mostrar original en todas las páginas
      context = VideoPlaybackContext.original;
    } else if (isHomePage) {
      // Home page: mostrar original (no procesado aún)
      context = VideoPlaybackContext.original;
    } else {
      // Results page: mostrar procesado
      context = VideoPlaybackContext.processed;
    }

    return VideoPlayerConfig(
      type: VideoPlayerType.thumbnail,
      size: VideoPlayerSize.small,
      showPlayIcon: true,
      showOverlay: true,
      overlayOpacity: 0.2,
      enableTapToPlay: true,
      playbackContext: context,
    );
  }

  /// staticThumbnail: Thumbnail estático sin play icon (usado durante procesamiento)
  /// Material 3: Disabled elements NO deben mostrar affordances interactivas
  static const VideoPlayerConfig staticThumbnail = VideoPlayerConfig(
    type: VideoPlayerType.thumbnail,
    size: VideoPlayerSize.small,
    showPlayIcon: false, // Sin botón play
    showOverlay: false, // Sin overlay
    overlayOpacity: 0.0,
    enableTapToPlay: false, // No clickable
    playbackContext: VideoPlaybackContext.auto,
  );

  /// external: Thumbnail mediano con reproducción externa (usado en galerías)
  static const VideoPlayerConfig external = VideoPlayerConfig(
    type: VideoPlayerType.external,
    size: VideoPlayerSize.medium,
    showPlayIcon: true,
    showOverlay: true,
    overlayOpacity: 0.3,
    enableTapToPlay: true,
    playbackContext: VideoPlaybackContext.auto, // Automático para galerías
  );

  /// results: Configuración para página de resultados (video procesado)
  static const VideoPlayerConfig results = VideoPlayerConfig(
    type: VideoPlayerType.external,
    size: VideoPlayerSize.small,
    showPlayIcon: true,
    showOverlay: true,
    overlayOpacity: 0.2,
    enableTapToPlay: true,
    playbackContext:
        VideoPlaybackContext.processed, // Video procesado en resultados
  );

  /// Crea una copia de la configuración con valores modificados
  /// SOLID: Single Responsibility - solo maneja clonación de configuración
  VideoPlayerConfig copyWith({
    VideoPlayerType? type,
    VideoPlayerSize? size,
    bool? showPlayIcon,
    bool? showOverlay,
    Color? overlayColor,
    double? overlayOpacity,
    bool? enableTapToPlay,
    VideoPlaybackContext? playbackContext,
  }) {
    return VideoPlayerConfig(
      type: type ?? this.type,
      size: size ?? this.size,
      showPlayIcon: showPlayIcon ?? this.showPlayIcon,
      showOverlay: showOverlay ?? this.showOverlay,
      overlayColor: overlayColor ?? this.overlayColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      enableTapToPlay: enableTapToPlay ?? this.enableTapToPlay,
      playbackContext: playbackContext ?? this.playbackContext,
    );
  }
}

/// Sistema ÚNICO de reproducción de videos para toda la aplicación
/// Reemplaza: lógica de reproducción dispersa en diferentes archivos
class AppVideoPlayer {
  /// Reproduce un video usando la configuración especificada
  static Future<void> playVideo(
    BuildContext context, {
    required String videoPath,
    required String title,
    VideoPlayerConfig config = const VideoPlayerConfig(),
    VoidCallback? onError,
  }) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        throw AppError.fileNotFound(videoPath);
      }

      if (!context.mounted) return;

      switch (config.type) {
        case VideoPlayerType.external:
          await _playWithExternalApp(context, file);
          break;
        case VideoPlayerType.thumbnail:
          // Thumbnail también reproduce con aplicación externa por consistencia
          await _playWithExternalApp(context, file);
          break;
      }
    } catch (e) {
      final appError = AppError.fromException(e, StackTrace.current);
      final errorMessage = appError.userMessage;
      if (context.mounted) {
        _showErrorNotification(context, errorMessage);
      }
      onError?.call();
    }
  }

  /// Reproduce un video de una tarea usando la configuración especificada
  static Future<void> playVideoTask(
    BuildContext context, {
    required VideoTask task,
    VideoPlayerConfig config = const VideoPlayerConfig(),
    VoidCallback? onError,
  }) async {
    // Seleccionar ruta según contexto de reproducción
    final String videoPath = _selectVideoPath(task, config.playbackContext);

    await playVideo(
      context,
      videoPath: videoPath,
      title: task.fileName,
      config: config,
      onError: onError,
    );
  }

  ///  SOLUCIÓN: Memoización para evitar logs excesivos
  static final Map<String, String> _pathCache = {};

  /// Selecciona la ruta correcta del video según el contexto de reproducción
  static String _selectVideoPath(VideoTask task, VideoPlaybackContext context) {
    // Generar clave única para el cache
    final cacheKey =
        '${task.id}_${context.name}_${task.settings.editSettings.replaceOriginalFile}_${task.isCompleted}';

    // Verificar cache primero
    if (_pathCache.containsKey(cacheKey)) {
      return _pathCache[cacheKey]!;
    }

    // Switch expression (Dart 3.0+) - más conciso y seguro
    final selectedPath = switch (context) {
      VideoPlaybackContext.original => task.originalPath ?? task.inputPath,
      VideoPlaybackContext.processed => _getProcessedPath(task),
      VideoPlaybackContext.auto => task.outputPath ?? task.inputPath,
    };

    // Solo loggear cuando la ruta cambia (no en cada rebuild)
    if (!_pathCache.containsKey(cacheKey) ||
        _pathCache[cacheKey] != selectedPath) {
      AppLogger.debug({
        'event': 'video_path_selection',
        'file_name': task.fileName,
        'context': context.name,
        'replace_original': task.settings.editSettings.replaceOriginalFile,
        'input_path': task.inputPath,
        'original_path': task.originalPath,
        'output_path': task.outputPath,
        'selected_path': selectedPath,
      });
    }

    // Guardar en cache
    _pathCache[cacheKey] = selectedPath;

    // Limpiar cache si se vuelve muy grande (prevenir memory leaks)
    if (_pathCache.length > 100) {
      _pathCache.clear();
    }

    return selectedPath;
  }

  /// Helper para lógica de processed path
  static String _getProcessedPath(VideoTask task) {
    // CORRECTO - Lógica completa con null safety
    if (task.settings.editSettings.replaceOriginalFile) {
      // Si se reemplaza original Y ya está completado
      if (task.isCompleted) {
        // El inputPath ahora contiene el video procesado (original reemplazado)
        return task.inputPath;
      }
      // Durante procesamiento, usar inputPath (original antes de reemplazo)
      return task.inputPath;
    }

    // Si NO se reemplaza, usar outputPath o fallback a originalPath
    return task.outputPath ?? task.originalPath ?? task.inputPath;
  }

  /// Reproduce con aplicación externa
  static Future<void> _playWithExternalApp(
    BuildContext context,
    File file,
  ) async {
    final result = await OpenFile.open(file.path);

    if (result.type != ResultType.done) {
      throw AppError.validationError(
        'video_player',
        'No se encontró una aplicación para reproducir videos',
      );
    }
  }

  /// Muestra notificación de error
  static void _showErrorNotification(BuildContext context, String message) {
    AppNotification.showError(
      context,
      message,
      duration: const Duration(seconds: 3),
    );
  }

  /// Crea un widget de thumbnail con icono de play
  static Widget buildThumbnail({
    required String? thumbnailPath,
    required String videoPath,
    required String title,
    VideoPlayerConfig config = const VideoPlayerConfig(),
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    return _AppVideoThumbnail(
      thumbnailPath: thumbnailPath,
      videoPath: videoPath,
      title: title,
      config: config,
      onTap: onTap,
      width: width,
      height: height,
    );
  }

  /// Crea un widget de thumbnail para una tarea de video
  static Widget buildTaskThumbnail({
    required VideoTask task,
    VideoPlayerConfig config = const VideoPlayerConfig(),
    VoidCallback? onTap,
    double? width,
    double? height,
  }) {
    // SOLID: Usar la lógica centralizada de selección de ruta
    final videoPath = _selectVideoPath(task, config.playbackContext);

    return buildThumbnail(
      thumbnailPath: task.thumbnailPath,
      videoPath: videoPath,
      title: task.fileName,
      config: config,
      onTap: onTap,
      width: width,
      height: height,
    );
  }

  /// Thumbnail de error
  // static Widget _buildErrorThumbnail(double? width, double? height) {
  //   return Container(
  //     width: width ?? 60,
  //     height: height ?? 60,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: const Icon(PhosphorIcons.warningCircle(), color: Colors.grey),
  //   );
  // }
}

/// Widget interno para thumbnail con icono de play
class _AppVideoThumbnail extends StatelessWidget {
  final String? thumbnailPath;
  final String videoPath;
  final String title;
  final VideoPlayerConfig config;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const _AppVideoThumbnail({
    required this.thumbnailPath,
    required this.videoPath,
    required this.title,
    required this.config,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Migrado: Usar constantes estáticas en lugar de AppThemeVars deprecated
    final size = _getSize();

    return GestureDetector(
      onTap: config.enableTapToPlay
          ? () {
              onTap?.call();
              AppVideoPlayer.playVideo(
                context,
                videoPath: videoPath,
                title: title,
                config: config,
              );
            }
          : null,
      child: Container(
        width: width ?? size,
        height: height ?? size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.AppRadius.s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.AppRadius.s),
          child: Stack(
            children: [
              // Thumbnail o placeholder
              _buildThumbnailImage(context),

              // Overlay con icono de play
              if (config.showOverlay && config.showPlayIcon)
                _buildPlayOverlay(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailImage(BuildContext context) {
    if (thumbnailPath != null) {
      // PERFORMANCE: Cache dinámico basado en tamaño real del thumbnail
      // Para thumbnails pequeños (60-80px): cache ~120-160px (2x para Retina)
      // Para video player grande: cache ~512x288
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final effectiveWidth = width ?? _getSize();
      final effectiveHeight = height ?? _getSize();

      final cacheWidth = (effectiveWidth * devicePixelRatio).round();
      final cacheHeight = (effectiveHeight * devicePixelRatio).round();

      return Image.file(
        File(thumbnailPath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth, // Dinámico según tamaño display
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    } else {
      return _buildPlaceholder(context);
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const AppIcon(icon: AppIcons.video, config: AppIconConfig.large()),
    );
  }

  Widget _buildPlayOverlay(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: (config.overlayColor ?? colorScheme.scrim).withValues(
          alpha: config.overlayOpacity,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(tokens.AppSpacing.s),
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIconsFill.play,
            size: AppIconSize.m,
            color: colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }

  double _getSize() {
    switch (config.size) {
      case VideoPlayerSize.small:
        return 60;
      case VideoPlayerSize.medium:
        return 120;
      case VideoPlayerSize.large:
        return 200;
    }
  }
}
