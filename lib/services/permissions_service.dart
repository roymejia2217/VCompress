import 'dart:io' show Platform;

import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

/// Servicio simple de permisos - KISS approach
/// Android decide automáticamente qué permisos usar según la versión
class PermissionsService {
  PermissionsService._(); // Constructor privado

  /// Solicita permisos de almacenamiento de manera estática
  /// Android 13+: usa READ_MEDIA_VIDEO automáticamente
  /// Android 10-12: usa READ_EXTERNAL_STORAGE automáticamente
  static Future<bool> requestStoragePermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final statuses = await [
        Permission.videos, // READ_MEDIA_VIDEO (Android 13+)
        Permission.storage, // READ_EXTERNAL_STORAGE (Android 10-12)
      ].request();

      // Cualquiera de los dos granted es suficiente
      return statuses[Permission.videos]!.isGranted ||
          statuses[Permission.storage]!.isGranted;
    }
    return Future.value(true);
  }

  /// Abre configuración de la app usando app_settings (confiable en Android/iOS)
  static Future<void> openSettings() async {
    await AppSettings.openAppSettings();
  }
}
