import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';
import 'package:vcompressor/core/extensions/theme_extensions.dart';

/// Sistema completo de iconografía Material 3 para VCompressor
///
/// **CARACTERÍSTICAS:**
/// - Iconos con semantic colors dinámicos
/// - Factory constructors para diferentes contextos
/// - Accesibilidad con semantic labels
/// - Optimización const para mejor performance
///
/// **USO:**
/// ```dart
/// // Icono simple
/// AppIcon.small(icon: PhosphorIcons.play)
///
/// // Icono de estado
/// AppIcon.status(status: VideoTaskStatus.completed)
///
/// // Icono con color primario
/// AppIcon.large(icon: PhosphorIcons.settings, usePrimary: true)
/// ```

class AppIcon extends StatelessWidget {
  final IconData icon;
  final AppIconConfig config;
  final Color? color;
  final String? semanticLabel;

  const AppIcon({
    super.key,
    required this.icon,
    this.config = const AppIconConfig.medium(),
    this.color,
    this.semanticLabel,
  });

  // Factory constructors para diferentes contextos
  const AppIcon.small({
    Key? key,
    required IconData icon,
    Color? color,
    String? semanticLabel,
  }) : this(
         key: key,
         icon: icon,
         config: const AppIconConfig.small(),
         color: color,
         semanticLabel: semanticLabel,
       );

  const AppIcon.large({
    Key? key,
    required IconData icon,
    Color? color,
    String? semanticLabel,
  }) : this(
         key: key,
         icon: icon,
         config: const AppIconConfig.large(),
         color: color,
         semanticLabel: semanticLabel,
       );

  const AppIcon.extraLarge({
    Key? key,
    required IconData icon,
    Color? color,
    String? semanticLabel,
  }) : this(
         key: key,
         icon: icon,
         config: const AppIconConfig.extraLarge(),
         color: color,
         semanticLabel: semanticLabel,
       );

  // Factory para íconos de estado (KISS - colores en build())
  factory AppIcon.status({
    Key? key,
    required VideoTaskState status,
    AppIconConfig? config,
    String? semanticLabel,
  }) {
    final icon = switch (status) {
      VideoTaskState.pending => PhosphorIconsFill.clock,
      VideoTaskState.processing => PhosphorIconsFill.arrowsClockwise,
      VideoTaskState.completed => PhosphorIconsFill.checkCircle,
      VideoTaskState.error => PhosphorIconsFill.xCircle,
      VideoTaskState.cancelled => PhosphorIconsFill.prohibit,
    };

    return AppIcon(
      key: key,
      icon: icon,
      config: config ?? const AppIconConfig.medium(),
      color: null, // Color se determina en build() con ColorScheme
      semanticLabel: semanticLabel ?? _getStatusLabel(status),
    );
  }

  static String _getStatusLabel(VideoTaskState status) {
    switch (status) {
      case VideoTaskState.pending:
        return 'Pendiente';
      case VideoTaskState.processing:
        return 'Procesando';
      case VideoTaskState.completed:
        return 'Completado';
      case VideoTaskState.error:
        return 'Error';
      case VideoTaskState.cancelled:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    // KISS: Determinar color basado en el icono (estado)
    final iconColor = color ?? _getStatusColor(icon, colorScheme);

    // Accesibilidad con Semantics
    return Semantics(
      label: semanticLabel,
      child: Icon(icon, size: config.size, color: iconColor),
    );
  }

  // Helper para colores de estado (KISS)
  Color _getStatusColor(IconData icon, ColorScheme colorScheme) {
    // Mapear iconos a colores M3
    if (icon == PhosphorIconsFill.clock) return colorScheme.onSurfaceVariant;
    if (icon == PhosphorIconsFill.arrowsClockwise) return colorScheme.primary;
    if (icon == PhosphorIconsFill.checkCircle) return Colors.green.shade400;
    if (icon == PhosphorIconsFill.xCircle) return colorScheme.error;
    if (icon == PhosphorIconsFill.prohibit) return colorScheme.secondary;

    // Fallback para otros iconos
    return config.usePrimaryColor ? colorScheme.primary : colorScheme.onSurface;
  }
}

// Config class con const constructors
class AppIconConfig {
  final double size;
  final bool usePrimaryColor;

  const AppIconConfig({required this.size, this.usePrimaryColor = false});

  // Predefined configs siguiendo Material 3 sizing
  const AppIconConfig.small() : size = AppIconSize.s, usePrimaryColor = false;
  const AppIconConfig.medium() : size = AppIconSize.m, usePrimaryColor = false;
  const AppIconConfig.large() : size = AppIconSize.l, usePrimaryColor = false;
  const AppIconConfig.extraLarge() : size = 32, usePrimaryColor = false;

  // Configs para casos específicos
  const AppIconConfig.successProcess() : size = 64, usePrimaryColor = false;

  const AppIconConfig.primary() : size = AppIconSize.m, usePrimaryColor = true;
}

// Helper para iconos comunes de la app
class AppIcons {
  static const video = Icons.video_library;
  static const processing = Icons.sync;
  static const completed = Icons.check_circle;
  static const error = Icons.error;
  static const warning = Icons.warning;
  static const info = Icons.info;
  static const cancel = Icons.cancel;
  static const play = Icons.play_circle_outline;
  static const pause = Icons.pause_circle_outline;
  static const share = Icons.share;
  static const delete = Icons.delete;
  static const settings = Icons.settings;
  static const add = Icons.add;

  const AppIcons._();
}
