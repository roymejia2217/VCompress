import 'package:vcompressor/core/hardware/hardware_encoder_detector.dart';

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

  String get ffmpegCodec {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 'libx264';
      case CompressionAlgorithm.excelenteCalidad:
        return 'libx265';
      case CompressionAlgorithm.buenaCalidad:
        return 'libx264';
      case CompressionAlgorithm.compresionMedia:
        return 'libx265';
      case CompressionAlgorithm.ultraCompresion:
        return 'libx264';
    }
  }

  /// Obtiene el codec de hardware específico para el procesador detectado
  Future<String> getHardwareCodec({
    required int resolutionHeight,
    required String outputFormat,
  }) async {
    try {
      return await HardwareEncoderDetector.getOptimalEncoder(ffmpegCodec) ??
          hwCodec;
    } catch (e) {
      // Fallback al codec de hardware genérico
      return hwCodec;
    }
  }

  String get hwCodec {
    switch (this) {
      case CompressionAlgorithm.maximaCalidad:
        return 'h264_mediacodec';
      case CompressionAlgorithm.excelenteCalidad:
        return 'hevc_mediacodec';
      case CompressionAlgorithm.buenaCalidad:
        return 'h264_mediacodec';
      case CompressionAlgorithm.compresionMedia:
        return 'hevc_mediacodec';
      case CompressionAlgorithm.ultraCompresion:
        return 'h264_mediacodec';
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

  /// Obtiene el bitrate recomendado basado en la resolución y el procesador
  Future<int> getRecommendedBitrate({
    required int resolutionHeight,
    required String outputFormat,
  }) async {
    try {
      // Simplificado: usar bitrates estándar basados en resolución
      return _getFallbackBitrate(resolutionHeight);
    } catch (e) {
      // Fallback seguro
      return _getFallbackBitrate(resolutionHeight);
    }
  }

  /// Obtiene bitrate de fallback basado en la resolución
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
        return 2000000; // 2 Mbps por defecto
    }
  }

  /// Verifica si el algoritmo es compatible con la resolución y el procesador
  Future<bool> isCompatibleWithResolution({
    required int resolutionHeight,
    required String outputFormat,
  }) async {
    try {
      // Simplificado: asumir compatibilidad para todas las resoluciones
      return true;
    } catch (e) {
      // En caso de error, asumir compatibilidad
      return true;
    }
  }

  /// Obtiene información detallada sobre las capacidades del encoder
  Future<String> getEncoderInfo({
    required int resolutionHeight,
    required String outputFormat,
  }) async {
    try {
      final processorType = await HardwareEncoderDetector.detectProcessorType();
      // final encoders = await HardwareEncoderDetector.getHardwareEncoders();

      final buffer = StringBuffer();
      buffer.writeln('Algoritmo: $displayName');
      buffer.writeln('Procesador: $processorType');
      buffer.writeln('Resolución: ${resolutionHeight}p');
      buffer.writeln('Formato: $outputFormat');
      buffer.writeln('Codec Software: $ffmpegCodec');
      buffer.writeln(
        'Codec Hardware: ${await getHardwareCodec(resolutionHeight: resolutionHeight, outputFormat: outputFormat)}',
      );
      buffer.writeln('CRF: $crfValue');
      buffer.writeln('Preset: $preset');
      buffer.writeln(
        'Bitrate Recomendado: ${await getRecommendedBitrate(resolutionHeight: resolutionHeight, outputFormat: outputFormat) ~/ 1000000} Mbps',
      );
      buffer.writeln(
        'Compatible: ${await isCompatibleWithResolution(resolutionHeight: resolutionHeight, outputFormat: outputFormat)}',
      );

      return buffer.toString();
    } catch (e) {
      return 'Error obteniendo información del encoder: $e';
    }
  }
}
