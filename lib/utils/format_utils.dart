/// Utilidades centralizadas para formateo de datos
class FormatUtils {
  FormatUtils._(); // Constructor privado para clase estática

  /// Formatea bytes a una representación legible (B, KB, MB, GB)
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Formatea duración en segundos a representación legible
  static String formatDuration(double seconds) {
    if (seconds < 60) {
      return '${seconds.toInt()}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '${minutes}m ${remainingSeconds.toInt()}s'
          : '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final remainingMinutes = (seconds % 3600) ~/ 60;
      return remainingMinutes > 0
          ? '${hours}h ${remainingMinutes}m'
          : '${hours}h';
    }
  }

  /// Formatea porcentaje de compresión
  static String formatCompressionRatio(double ratio) {
    return '${ratio.toStringAsFixed(1)}%';
  }

  /// Formatea velocidad de procesamiento
  static String formatSpeed(double speed) {
    if (speed == 1.0) return 'Normal';
    if (speed < 1.0) return '${speed.toStringAsFixed(2)}x más lento';
    return '${speed.toStringAsFixed(1)}x más rápido';
  }

  /// Limpia nombres de archivo reemplazando caracteres problemáticos
  static String cleanFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'\s+'), '-') // Reemplazar espacios con guiones
        .replaceAll(
          RegExp(r'[^\w\-\.]'),
          '',
        ) // Remover caracteres especiales excepto guiones y puntos
        .replaceAll(
          RegExp(r'-+'),
          '-',
        ) // Reemplazar múltiples guiones con uno solo
        .replaceAll(RegExp(r'^-|-$'), ''); // Remover guiones al inicio y final
  }

  /// Formatea tiempo estimado restante
  static String formatTimeEstimate(Duration remaining) {
    if (remaining.inSeconds < 60) {
      return '${remaining.inSeconds}s restantes';
    } else if (remaining.inMinutes < 60) {
      return '${remaining.inMinutes}m restantes';
    } else {
      return '${remaining.inHours}h restantes';
    }
  }
}
