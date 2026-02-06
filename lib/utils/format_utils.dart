import 'package:vcompressor/l10n/app_localizations.dart';

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

  /// Formatea tiempo estimado restante
  /// Requiere [AppLocalizations] para texto localizado
  static String formatTimeEstimate(
    Duration remaining,
    AppLocalizations l10n,
  ) {
    String timeString;
    if (remaining.inSeconds < 60) {
      timeString = '${remaining.inSeconds}s';
    } else if (remaining.inMinutes < 60) {
      timeString = '${remaining.inMinutes}m';
    } else {
      timeString = '${remaining.inHours}h';
    }
    return l10n.timeRemaining(timeString);
  }
}
