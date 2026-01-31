import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vcompressor/core/logging/app_logger.dart';

/// Información de hardware del dispositivo
class PlatformHardwareInfo {
  final String manufacturer;
  final String model;
  final String brand;
  final String product;
  final String device;
  final String board;
  final String hardware;
  final int cpuCores;
  final String cpuArchitecture;
  final String processorType;
  final String gpuInfo;
  final int totalMemory;
  final int availableMemory;

  const PlatformHardwareInfo({
    required this.manufacturer,
    required this.model,
    required this.brand,
    required this.product,
    required this.device,
    required this.board,
    required this.hardware,
    required this.cpuCores,
    required this.cpuArchitecture,
    required this.processorType,
    required this.gpuInfo,
    required this.totalMemory,
    required this.availableMemory,
  });

  factory PlatformHardwareInfo.fromMap(Map<String, dynamic> map) {
    return PlatformHardwareInfo(
      manufacturer: map['manufacturer'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      brand: map['brand'] ?? 'Unknown',
      product: map['product'] ?? 'Unknown',
      device: map['device'] ?? 'Unknown',
      board: map['board'] ?? 'Unknown',
      hardware: map['hardware'] ?? 'Unknown',
      cpuCores: map['cpuCores'] ?? 4,
      cpuArchitecture: map['cpuArchitecture'] ?? 'Unknown',
      processorType: map['processorType'] ?? 'Unknown',
      gpuInfo: map['gpuInfo'] ?? 'Unknown',
      totalMemory: map['totalMemory'] ?? 0,
      availableMemory: map['availableMemory'] ?? 0,
    );
  }

  String get deviceInfo => '$manufacturer $model';
}

/// Información de codecs soportados
class PlatformCodecInfo {
  final List<String> h264Encoders;
  final List<String> h265Encoders;
  final List<String> h264Decoders;
  final List<String> h265Decoders;
  final bool hasH264HwEncoder;
  final bool hasH265HwEncoder;

  const PlatformCodecInfo({
    required this.h264Encoders,
    required this.h265Encoders,
    required this.h264Decoders,
    required this.h265Decoders,
    required this.hasH264HwEncoder,
    required this.hasH265HwEncoder,
  });

  factory PlatformCodecInfo.fromMap(Map<String, dynamic> map) {
    return PlatformCodecInfo(
      h264Encoders: List<String>.from(map['h264Encoders'] ?? []),
      h265Encoders: List<String>.from(map['h265Encoders'] ?? []),
      h264Decoders: List<String>.from(map['h264Decoders'] ?? []),
      h265Decoders: List<String>.from(map['h265Decoders'] ?? []),
      hasH264HwEncoder: map['hasH264HwEncoder'] ?? false,
      hasH265HwEncoder: map['hasH265HwEncoder'] ?? false,
    );
  }
}

/// Servicio para comunicación con código nativo de Android
class PlatformHardwareService {
  static const MethodChannel _channel = MethodChannel(
    'com.rjmejia.vcompressor/hardware_detection',
  );

  const PlatformHardwareService();

  /// Verifica si el servicio está disponible (solo en Android)
  bool get isAvailable => !kIsWeb && Platform.isAndroid;

  /// Obtiene información de hardware del dispositivo
  Future<PlatformHardwareInfo> getHardwareInfo() async {
    try {
      if (!isAvailable) {
        throw UnsupportedError('Platform hardware service not available');
      }

      AppLogger.debug(
        'Obteniendo información de hardware desde platform channels',
        tag: 'PlatformHardware',
      );

      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getHardwareInfo',
      );

      if (result == null) {
        throw Exception('No hardware info received from platform');
      }

      final hardwareInfo = PlatformHardwareInfo.fromMap(
        Map<String, dynamic>.from(result),
      );

      AppLogger.info(
        'Hardware detectado: ${hardwareInfo.deviceInfo} - ${hardwareInfo.processorType}',
        tag: 'PlatformHardware',
      );

      return hardwareInfo;
    } catch (e) {
      AppLogger.error(
        'Error obteniendo información de hardware: $e',
        tag: 'PlatformHardware',
      );
      rethrow;
    }
  }

  /// Obtiene información de codecs soportados
  Future<PlatformCodecInfo> getSupportedCodecs() async {
    try {
      if (!isAvailable) {
        throw UnsupportedError('Platform hardware service not available');
      }

      AppLogger.debug(
        'Obteniendo codecs soportados desde platform channels',
        tag: 'PlatformHardware',
      );

      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getSupportedCodecs',
      );

      if (result == null) {
        throw Exception('No codec info received from platform');
      }

      final codecInfo = PlatformCodecInfo.fromMap(
        Map<String, dynamic>.from(result),
      );

      AppLogger.info(
        'Codecs detectados: H.264: ${codecInfo.hasH264HwEncoder}, H.265: ${codecInfo.hasH265HwEncoder}',
        tag: 'PlatformHardware',
      );

      return codecInfo;
    } catch (e) {
      AppLogger.error('Error obteniendo codecs: $e', tag: 'PlatformHardware');
      rethrow;
    }
  }

  /// Obtiene la versión de SDK de Android (minSdk 24+)
  Future<int> getAndroidVersion() async {
    try {
      final result = await _channel.invokeMethod<int>('getAndroidVersion');
      return result ?? 24; // Fallback a minSdk
    } on PlatformException catch (e) {
      AppLogger.error(
        'Error obteniendo versión de Android: ${e.message}',
        tag: 'PlatformHardware',
      );
      return 24; // Fallback seguro
    } catch (e) {
      AppLogger.error(
        'Error inesperado obteniendo versión: $e',
        tag: 'PlatformHardware',
      );
      return 24; // Fallback seguro
    }
  }
}
