import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';
import 'package:vcompressor/core/extensions/theme_extensions.dart';

/// Sistema completo de notificaciones Material 3 para VCompressor
///
/// **CARACTERÍSTICAS:**
/// - Colores semánticos dinámicos con estados de video
/// - Material 3 SnackBar patterns con floating behavior
/// - Accesibilidad completa con semantic labels
/// - Soporte para acciones y tipos múltiples
///
/// **USO:**
/// ```dart
/// // Notificación simple
/// AppNotification.showSuccess(context, 'Video comprimido exitosamente');
///
/// // Con acción
/// AppNotification.showError(
///   context,
///   'Error al comprimir',
///   actionLabel: 'Reintentar',
///   onAction: () => retryCompression(),
/// );
/// ```

enum NotificationType { success, error, warning, info }

class AppNotification {
  /// Muestra una notificación Material 3
  static void show(
    BuildContext context, {
    required String message,
    required NotificationType type,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colorScheme = context.colorScheme;

    // Color y icono según tipo
    final config = _getNotificationConfig(type, colorScheme);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _NotificationContent(
          message: message,
          icon: config.icon,
          iconColor: config.iconColor,
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating, // Material 3 floating
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        margin: AppPadding.m,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.actionColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  // Helpers específicos por tipo
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 6), // Más tiempo para errores
  }) {
    show(
      context,
      message: message,
      type: NotificationType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static _NotificationConfig _getNotificationConfig(
    NotificationType type,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          icon: PhosphorIconsFill.checkCircle,
          iconColor: Colors.white,
          backgroundColor: Colors.green.shade400,
          actionColor: Colors.white,
        );
      case NotificationType.error:
        return _NotificationConfig(
          icon: PhosphorIconsFill.xCircle,
          iconColor: colorScheme.onError,
          backgroundColor: colorScheme.error,
          actionColor: colorScheme.onError,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          icon: PhosphorIconsFill.warning,
          iconColor: Colors.white,
          backgroundColor: Colors.orange.shade400,
          actionColor: Colors.white,
        );
      case NotificationType.info:
        return _NotificationConfig(
          icon: PhosphorIconsFill.info,
          iconColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          actionColor: colorScheme.onPrimary,
        );
    }
  }
}

// Config interna
class _NotificationConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color actionColor;

  const _NotificationConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.actionColor,
  });
}

// Widget const para contenido
class _NotificationContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const _NotificationContent({
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppIconSize.m),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(message, style: TextStyle(color: colorScheme.onSurface)),
        ),
      ],
    );
  }
}

// Extension para acceso simplificado
extension AppNotificationExtension on BuildContext {
  void showSuccessNotification(String message) {
    AppNotification.showSuccess(this, message);
  }

  void showErrorNotification(String message) {
    AppNotification.showError(this, message);
  }

  void showWarningNotification(String message) {
    AppNotification.showWarning(this, message);
  }

  void showInfoNotification(String message) {
    AppNotification.showInfo(this, message);
  }
}
