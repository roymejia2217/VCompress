import 'dart:io';
import 'package:vcompressor/models/video_task.dart';

/// Utilidades centralizadas para operaciones de filesystem
/// Maneja operaciones de archivos
class FileSystemHelper {
  const FileSystemHelper();

  /// Genera una ruta temporal con prefijo punto (oculta)
  /// Ejemplo: '/dir/video.mp4' -> '/dir/.video_temp.mp4'
  String generateTemporaryPath(String originalPath) {
    final directory = originalPath.substring(0, originalPath.lastIndexOf('/'));
    final fileName = originalPath.substring(originalPath.lastIndexOf('/') + 1);
    final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
    final extension = fileName.substring(fileName.lastIndexOf('.'));

    return '$directory/.${nameWithoutExt}_temp$extension';
  }

  /// Construye la ruta de salida para un archivo comprimido
  /// Incluye hash de configuración para diferenciar diferentes compresiones del mismo video
  String buildOutputPath(String dir, String srcName, VideoSettings settings) {
    final lastDotIndex = srcName.lastIndexOf('.');
    final nameWithoutExt = lastDotIndex > 0
        ? srcName.substring(0, lastDotIndex)
        : srcName;
    final cleanBase = _cleanFileName(nameWithoutExt);

    // Hash único basado en configuración completa (6-8 caracteres)
    final configHash = settings.hashCode.abs().toRadixString(36);

    // Nombre formato: "video_h4s3x.mp4"
    return '$dir/${cleanBase}_$configHash${settings.format.extension}';
  }

  /// Obtiene el tamaño de un archivo sin usar dos syscalls
  /// Una sola llamada a stat() en lugar de exists() + length()
  Future<int?> getFileSize(String filePath) async {
    try {
      // Una sola syscall en lugar de exists() + length()
      final stat = await File(filePath).stat();
      if (stat.type != FileSystemEntityType.notFound) {
        return stat.size;
      }
    } catch (e) {
      // Ignorar errores al obtener el tamaño
    }
    return null;
  }

  /// Limpia el nombre del archivo removiendo caracteres inválidos
  String _cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
