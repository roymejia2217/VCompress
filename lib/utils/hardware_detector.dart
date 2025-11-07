import 'package:flutter/foundation.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/validation/app_validator.dart';
import 'package:vcompressor/data/services/platform_hardware_service.dart';

/// Información de capacidades de hardware del dispositivo
class HardwareCapabilities {
  final bool hasHwAccel;
  final bool hasH264HwEncoder;
  final bool hasH265HwEncoder;
  final int cpuCores;
  final String? gpuInfo;
  final String? processorType;
  final String? deviceModel;
  final String? manufacturer;

  const HardwareCapabilities({
    required this.hasHwAccel,
    required this.hasH264HwEncoder,
    required this.hasH265HwEncoder,
    required this.cpuCores,
    this.gpuInfo,
    this.processorType,
    this.deviceModel,
    this.manufacturer,
  });

  /// Detecta las capacidades de hardware del dispositivo
  static Future<HardwareCapabilities> detect() async {
    try {
      if (kIsWeb) {
        // Valores por defecto para web
        return const HardwareCapabilities(
          hasHwAccel: false,
          hasH264HwEncoder: false,
          hasH265HwEncoder: false,
          cpuCores: AppConstants.defaultCpuCores,
        );
      }

      // Usar platform channel para detectar hardware real
      const platformService = PlatformHardwareService();
      if (platformService.isAvailable) {
        return await _detectWithPlatformChannel(platformService);
      }

      // Fallback a valores por defecto
      return const HardwareCapabilities(
        hasHwAccel: false,
        hasH264HwEncoder: false,
        hasH265HwEncoder: false,
        cpuCores: AppConstants.defaultCpuCores,
      );
    } catch (e) {
      // En caso de error, usar valores por defecto
      return const HardwareCapabilities(
        hasHwAccel: false,
        hasH264HwEncoder: false,
        hasH265HwEncoder: false,
        cpuCores: AppConstants.defaultCpuCores,
      );
    }
  }

  /// Detecta hardware usando platform channel
  static Future<HardwareCapabilities> _detectWithPlatformChannel(
    PlatformHardwareService platformService,
  ) async {
    try {
      // Obtener información de hardware
      final hardwareInfo = await platformService.getHardwareInfo();

      // Obtener información de codecs
      final codecInfo = await platformService.getSupportedCodecs();

      // Validar información obtenida
      final cpuValidationError = AppValidator.validateThreadCount(
        hardwareInfo.cpuCores,
      );
      if (cpuValidationError != null) {
        throw AppError.hardwareDetection(cpuValidationError);
      }

      // Crear capacidades de hardware
      final capabilities = HardwareCapabilities(
        hasHwAccel: codecInfo.hasH264HwEncoder || codecInfo.hasH265HwEncoder,
        hasH264HwEncoder: codecInfo.hasH264HwEncoder,
        hasH265HwEncoder: codecInfo.hasH265HwEncoder,
        cpuCores: hardwareInfo.cpuCores,
        gpuInfo: hardwareInfo.gpuInfo,
        processorType: hardwareInfo.processorType,
        deviceModel: hardwareInfo.model,
        manufacturer: hardwareInfo.manufacturer,
      );

      // Validar capacidades finales
      final validationError = AppValidator.validateHardwareInfo(
        cpuCores: capabilities.cpuCores,
        hasHwAccel: capabilities.hasHwAccel,
        hasH264HwEncoder: capabilities.hasH264HwEncoder,
        hasH265HwEncoder: capabilities.hasH265HwEncoder,
      );

      if (validationError != null) {
        throw AppError.hardwareDetection(validationError);
      }

      return capabilities;
    } catch (e) {
      // Re-lanzar como AppError si no lo es ya
      if (e is AppError) rethrow;
      throw AppError.hardwareDetection(e.toString());
    }
  }

  /// Verifica si se puede usar aceleración por hardware
  bool get canUseHwAccel => hasHwAccel;

  /// Obtiene información del dispositivo
  String get deviceInfo {
    if (deviceModel != null && manufacturer != null) {
      return '$manufacturer $deviceModel';
    }
    return 'Unknown Device';
  }

  /// Obtiene número óptimo de hilos para procesamiento
  int get optimalThreadCount {
    // Validar número de hilos
    final cpuValidationError = AppValidator.validateThreadCount(cpuCores);
    if (cpuValidationError != null) {
      return AppConstants.defaultCpuCores;
    }

    // Usar 75% de los núcleos disponibles, mínimo 1, máximo 8
    final optimal = (cpuCores * 0.75).round();
    return optimal.clamp(1, 8);
  }

  /// Alias para optimalThreadCount (compatibilidad)
  int get optimalThreads => optimalThreadCount;

  /// Método estático para obtener capacidades (compatibilidad)
  static Future<HardwareCapabilities> getCapabilities() async {
    return await detect();
  }
}
