import 'package:vcompressor/models/video_task.dart';

/// Alias de resoluciones para compatibilidad con tests
/// Mapea a OutputResolution del sistema principal
class Resolution {
  /// 480p - Calidad básica
  static const sd480 = OutputResolution.p480;

  /// 720p HD - Calidad estándar
  static const hd720 = OutputResolution.p720;

  /// 1080p Full HD - Alta calidad
  static const hd1080 = OutputResolution.p1080;

  /// Original - Mantener resolución original
  static const original = OutputResolution.original;
}
