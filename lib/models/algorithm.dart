import 'package:vcompressor/models/video_codec.dart';

enum CompressionAlgorithm {
  maximaCalidad('Máxima Calidad'),
  excelenteCalidad('Excelente Calidad'),
  buenaCalidad('Buena Calidad'),
  compresionMedia('Compresión Media'),
  ultraCompresion('Ultra Compresión');

  const CompressionAlgorithm(this.displayName);
  final String displayName;
}

extension CompressionAlgorithmX on CompressionAlgorithm {
  String get briefDescription {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 'Calidad máxima. Archivos grandes pero perfectos.';
      case CompressionAlgorithm.excelenteCalidad:
        return 'Excelente calidad. Tamaño reducido significativamente.';
      case CompressionAlgorithm.buenaCalidad:
        return 'Buena calidad. Compresión rápida y eficiente.';
      case CompressionAlgorithm.compresionMedia:
        return 'Calidad aceptable. Archivos muy pequeños.';
      case CompressionAlgorithm.ultraCompresion:
        return 'Calidad básica. Máxima compresión posible.';
    }
  }

  int get crfValue {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 18;
      case CompressionAlgorithm.excelenteCalidad:
        return 23;
      case CompressionAlgorithm.buenaCalidad:
        return 28;
      case CompressionAlgorithm.compresionMedia:
        return 35;
      case CompressionAlgorithm.ultraCompresion:
        return 40;
    }
  }

  String get preset {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 'slow';
      case CompressionAlgorithm.excelenteCalidad:
        return 'medium';
      case CompressionAlgorithm.buenaCalidad:
        return 'fast';
      case CompressionAlgorithm.compresionMedia:
        return 'veryfast';
      case CompressionAlgorithm.ultraCompresion:
        return 'ultrafast';
    }
  }

  /// Obtiene el bitrate recomendado de manera INTELIGENTE
  /// Ajusta dinámicamente según resolución, codec (eficiencia) y FPS (fluidez)
  Future<int> getRecommendedBitrate({
    required int resolutionHeight,
    required VideoCodec codec,
    double? fps,
    String? outputFormat, // Mantenido por compatibilidad
  }) async {
    try {
      // 1. Bitrate Base (H.264 @ 30fps)
      double bitrate = _getFallbackBitrate(resolutionHeight).toDouble();

      // 2. Ajuste por Algoritmo (Calidad deseada)
      bitrate *= _getBitrateMultiplier();

      // 3. Ajuste por Eficiencia del Codec
      // H.265 y VP9 necesitan menos bits para la misma calidad
      switch (codec) {
        case VideoCodec.h265:
          bitrate *= 0.65; // 35% de ahorro (Estándar industrial HEVC)
        case VideoCodec.vp9:
          bitrate *= 0.70; // 30% de ahorro
        case VideoCodec.h264:
        case VideoCodec.auto:
          bitrate *= 1.0; // Base reference
      }

      // 4. Ajuste por Frame Rate (FPS)
      // Más cuadros = más datos necesarios. Normalizado a 30fps.
      if (fps != null && fps > 0) {
        // Clamp para evitar extremos (mínimo 15fps, máximo 120fps efectivos para cálculo)
        final safeFps = fps.clamp(15.0, 120.0);
        final fpsFactor = safeFps / 30.0;
        
        // Aplicamos el factor con un ligero "damping" (amortiguación)
        // No escalar linealmente puro para ahorrar algo de espacio en 60fps
        // (los cuadros intermedios suelen ser predictivos/delta)
        // Usamos potencia 0.75 para suavizar la curva
        // Ej: 60fps -> factor 2.0 -> aplicado ^0.75 ≈ 1.68x bitrate
        // Ej: 120fps -> factor 4.0 -> aplicado ^0.75 ≈ 2.8x bitrate
        // bitrate *= pow(fpsFactor, 0.75); -> Simplificado a lineal por seguridad de calidad:
        // Preferimos calidad sobre ahorro extremo en FPS altos.
        bitrate *= fpsFactor; 
      }

      return bitrate.round();
    } catch (e) {
      return _getFallbackBitrate(resolutionHeight);
    }
  }

  /// Multiplicador de bitrate basado en la calidad deseada
  double _getBitrateMultiplier() {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 1.5; // +50% bitrate
      case CompressionAlgorithm.excelenteCalidad:
        return 1.0; // Bitrate estándar
      case CompressionAlgorithm.buenaCalidad:
        return 0.75; // -25% bitrate
      case CompressionAlgorithm.compresionMedia:
        return 0.5; // -50% bitrate
      case CompressionAlgorithm.ultraCompresion:
        return 0.25; // -75% bitrate (Máxima compresión)
    }
  }

  /// Obtiene bitrate de fallback basado en la resolución (Estándar H.264 @ 30fps)
  /// Valores conservadores para asegurar calidad visual
  int _getFallbackBitrate(int resolutionHeight) {
    switch (resolutionHeight) {
      case 144:
        return 100000; // 100 Kbps
      case 240:
        return 500000; // 500 Kbps
      case 360:
        return 1000000; // 1 Mbps
      case 480:
        return 2000000; // 2 Mbps
      case 720:
        return 4000000; // 4 Mbps
      case 1080:
        return 8000000; // 8 Mbps
      case 1440:
        return 12000000; // 12 Mbps
      case 2160:
        return 25000000; // 25 Mbps (4K)
      default:
        // Estimación lineal para resoluciones no estándar
        if (resolutionHeight < 360) return 500000;
        // Aproximación simple: ~8Kbps por línea vertical (muy grosero pero funcional fallback)
        return resolutionHeight * 8000; 
    }
  }
}
