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

  /// Obtiene el bitrate recomendado basado en la resolución y el preset de calidad
  Future<int> getRecommendedBitrate({
    required int resolutionHeight,
    required String outputFormat,
  }) async {
    try {
      final baseBitrate = _getFallbackBitrate(resolutionHeight);
      final multiplier = _getBitrateMultiplier();
      return (baseBitrate * multiplier).round();
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

  /// Obtiene bitrate de fallback basado en la resolución (Estándar para H.264)
  int _getFallbackBitrate(int resolutionHeight) {
    switch (resolutionHeight) {
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
        return 25000000; // 25 Mbps
      default:
        // Estimación lineal para resoluciones no estándar
        if (resolutionHeight < 360) return 500000;
        return 2000000;
    }
  }
}
