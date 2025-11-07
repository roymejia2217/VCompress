import 'package:flutter/foundation.dart';
import 'package:vcompressor/data/services/platform_hardware_service.dart';

/// Tipos de encoders de hardware
enum HardwareEncoderType { h264, h265, av1, vp9 }

/// Información de detectores de codecs de hardware
class HardwareEncoderDetector {
  const HardwareEncoderDetector();

  /// Detecta si el dispositivo soporta codificación H.264 por hardware
  static Future<bool> hasH264HardwareEncoder() async {
    try {
      if (kIsWeb) return false;

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final codecInfo = await platformService.getSupportedCodecs();
        return codecInfo.hasH264HwEncoder;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Detecta si el dispositivo soporta codificación H.265 por hardware
  static Future<bool> hasH265HardwareEncoder() async {
    try {
      if (kIsWeb) return false;

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final codecInfo = await platformService.getSupportedCodecs();
        return codecInfo.hasH265HwEncoder;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene lista de codecs H.264 disponibles
  static Future<List<String>> getH264Encoders() async {
    try {
      if (kIsWeb) return [];

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final codecInfo = await platformService.getSupportedCodecs();
        return codecInfo.h264Encoders;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene lista de codecs H.265 disponibles
  static Future<List<String>> getH265Encoders() async {
    try {
      if (kIsWeb) return [];

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final codecInfo = await platformService.getSupportedCodecs();
        return codecInfo.h265Encoders;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Detecta el mejor codec H.264 disponible
  static Future<String?> getBestH264Encoder() async {
    try {
      final encoders = await getH264Encoders();

      // Priorizar codecs de hardware
      for (final encoder in encoders) {
        if (encoder.toLowerCase().contains('mediacodec') ||
            encoder.toLowerCase().contains('nvenc')) {
          return encoder;
        }
      }

      // Si no hay hardware, usar software
      if (encoders.isNotEmpty) {
        return encoders.first;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Detecta el mejor codec H.265 disponible
  static Future<String?> getBestH265Encoder() async {
    try {
      final encoders = await getH265Encoders();

      // Priorizar codecs de hardware
      for (final encoder in encoders) {
        if (encoder.toLowerCase().contains('mediacodec') ||
            encoder.toLowerCase().contains('nvenc')) {
          return encoder;
        }
      }

      // Si no hay hardware, usar software
      if (encoders.isNotEmpty) {
        return encoders.first;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si se puede usar aceleración por hardware
  static Future<bool> canUseHardwareAcceleration() async {
    try {
      final hasH264 = await hasH264HardwareEncoder();
      final hasH265 = await hasH265HardwareEncoder();
      return hasH264 || hasH265;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información completa de codecs disponibles
  static Future<Map<String, dynamic>> getCodecInfo() async {
    try {
      if (kIsWeb) {
        return {
          'hasH264HwEncoder': false,
          'hasH265HwEncoder': false,
          'h264Encoders': [],
          'h265Encoders': [],
          'bestH264Encoder': null,
          'bestH265Encoder': null,
        };
      }

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final codecInfo = await platformService.getSupportedCodecs();
        final bestH264 = await getBestH264Encoder();
        final bestH265 = await getBestH265Encoder();

        return {
          'hasH264HwEncoder': codecInfo.hasH264HwEncoder,
          'hasH265HwEncoder': codecInfo.hasH265HwEncoder,
          'h264Encoders': codecInfo.h264Encoders,
          'h265Encoders': codecInfo.h265Encoders,
          'bestH264Encoder': bestH264,
          'bestH265Encoder': bestH265,
        };
      }

      return {
        'hasH264HwEncoder': false,
        'hasH265HwEncoder': false,
        'h264Encoders': [],
        'h265Encoders': [],
        'bestH264Encoder': null,
        'bestH265Encoder': null,
      };
    } catch (e) {
      return {
        'hasH264HwEncoder': false,
        'hasH265HwEncoder': false,
        'h264Encoders': [],
        'h265Encoders': [],
        'bestH264Encoder': null,
        'bestH265Encoder': null,
      };
    }
  }

  /// Obtiene el mejor encoder para un algoritmo específico
  static Future<String?> getOptimalEncoder(String algorithm) async {
    switch (algorithm.toLowerCase()) {
      case 'h264':
      case 'avc':
        return await getBestH264Encoder();
      case 'h265':
      case 'hevc':
        return await getBestH265Encoder();
      default:
        return null;
    }
  }

  /// Obtiene todos los encoders de hardware disponibles
  static Future<List<String>> getHardwareEncoders() async {
    try {
      final h264Encoders = await getH264Encoders();
      final h265Encoders = await getH265Encoders();
      return [...h264Encoders, ...h265Encoders];
    } catch (e) {
      return [];
    }
  }

  /// Detecta el tipo de procesador
  static Future<String> detectProcessorType() async {
    try {
      if (kIsWeb) return 'unknown';

      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        final hardwareInfo = await platformService.getHardwareInfo();
        return hardwareInfo.processorType;
      }

      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
