import 'package:vcompressor/core/constants/app_constants.dart';

enum AppNotificationType {
  success, // Verde - Operaciones exitosas
  warning, // Naranja - Advertencias
  error, // Rojo - Errores
  info, // Azul - Información general
}

enum AppNotificationPosition {
  top, // Parte superior de la pantalla
  bottom, // Parte inferior de la pantalla
  center, // Centro de la pantalla
}

/// Configuración de notificación
class AppNotificationConfig {
  final Duration duration;
  final AppNotificationPosition position;
  final bool autoDismiss;
  final bool showIcon;
  final bool showCloseButton;

  const AppNotificationConfig({
    this.duration = AppConstants.toastDuration,
    this.position = AppNotificationPosition.top,
    this.autoDismiss = true,
    this.showIcon = true,
    this.showCloseButton = false,
  });

  /// Configuraciones predefinidas
  static const AppNotificationConfig quick = AppNotificationConfig(
    duration: Duration(seconds: 2), // EXACTAMENTE 2 segundos como solicitado
    position: AppNotificationPosition.bottom,
    autoDismiss: true,
    showIcon: true,
    showCloseButton: false,
  );

  static const AppNotificationConfig persistent = AppNotificationConfig(
    duration: Duration(seconds: 5),
    position: AppNotificationPosition.bottom,
    autoDismiss: true,
    showIcon: true,
    showCloseButton: true,
  );

  static const AppNotificationConfig error = AppNotificationConfig(
    duration: Duration(seconds: 4),
    position: AppNotificationPosition.bottom,
    autoDismiss: true,
    showIcon: true,
    showCloseButton: true,
  );
}

/// Servicio inteligente de notificaciones
