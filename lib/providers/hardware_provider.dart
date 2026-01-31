import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/core/error/app_error.dart';
import 'package:vcompressor/core/validation/app_validator.dart';
import 'package:vcompressor/utils/hardware_detector.dart';
import 'package:vcompressor/utils/cache_service.dart';

// SOLUCIÓN: AsyncNotifier con keepAlive para eliminar race conditions
class HardwareCapabilitiesNotifier extends AsyncNotifier<HardwareCapabilities> {
  @override
  Future<HardwareCapabilities> build() async {
    // Inicialización asíncrona nativa - AsyncNotifier espera automáticamente
    try {
      // Intentar cargar desde cache primero
      final cached = await _loadFromCache();
      if (cached != null) {
        final validationError = AppValidator.validateHardwareInfo(
          cpuCores: cached.cpuCores,
          hasHwAccel: cached.hasHwAccel,
          hasH264HwEncoder: cached.hasH264HwEncoder,
          hasH265HwEncoder: cached.hasH265HwEncoder,
        );

        // FIX: Validar que tenemos información real del dispositivo, no fallback
        // Si el fabricante es "Unknown" o null, el cache es inválido/incompleto
        final isRealDeviceInfo = cached.manufacturer != null &&
            cached.manufacturer != 'Unknown' &&
            cached.manufacturer != 'unknown';

        if (validationError == null && isRealDeviceInfo) {
          // Mantener cache exitoso con keepAlive
          ref.keepAlive();
          debugPrint(
            'Hardware cargado desde cache: ${cached.deviceInfo} - ${cached.cpuCores} núcleos, HW: ${cached.canUseHwAccel}',
          );
          return cached;
        } else {
          debugPrint(
            'Datos de cache inválidos (Error: ${validationError?.message}, RealDevice: $isRealDeviceInfo). Forzando redetección.',
          );
        }
      }

      // Si no hay cache válido, detectar hardware
      debugPrint('Detectando hardware del dispositivo...');
      final detected = await HardwareCapabilities.detect();

      // Validar datos detectados
      final validationError = AppValidator.validateHardwareInfo(
        cpuCores: detected.cpuCores,
        hasHwAccel: detected.hasHwAccel,
        hasH264HwEncoder: detected.hasH264HwEncoder,
        hasH265HwEncoder: detected.hasH265HwEncoder,
      );

      if (validationError != null) {
        throw AppError.hardwareDetection(validationError);
      }

      await _saveToCache(detected);

      // Mantener detección exitosa
      ref.keepAlive();
      debugPrint(
        'Hardware detectado y guardado en cache: ${detected.deviceInfo} - ${detected.cpuCores} núcleos, HW: ${detected.canUseHwAccel}',
      );
      return detected;
    } catch (e) {
      final appError = AppError.fromException(e, StackTrace.current);
      debugPrint('Error inicializando hardware: ${appError.message}');

      // En caso de error, usar valores por defecto
      return const HardwareCapabilities(
        hasHwAccel: false,
        hasH264HwEncoder: false,
        hasH265HwEncoder: false,
        cpuCores: AppConstants.defaultCpuCores,
      );
    }
  }

  Future<HardwareCapabilities?> _loadFromCache() async {
    try {
      final data = await CacheService.instance
          .getHardwareData<Map<String, dynamic>>('capabilities');

      if (data != null) {
        return HardwareCapabilities(
          hasHwAccel: data['hasHwAccel'] ?? false,
          hasH264HwEncoder: data['hasH264HwEncoder'] ?? false,
          hasH265HwEncoder: data['hasH265HwEncoder'] ?? false,
          cpuCores: data['cpuCores'] ?? 4,
          gpuInfo: data['gpuInfo'],
          processorType: data['processorType'],
          deviceModel: data['deviceModel'],
          manufacturer: data['manufacturer'],
        );
      }
    } catch (e) {
      debugPrint('Error cargando cache de hardware: $e');
    }
    return null;
  }

  Future<void> _saveToCache(HardwareCapabilities capabilities) async {
    try {
      final data = {
        'hasHwAccel': capabilities.hasHwAccel,
        'hasH264HwEncoder': capabilities.hasH264HwEncoder,
        'hasH265HwEncoder': capabilities.hasH265HwEncoder,
        'cpuCores': capabilities.cpuCores,
        'gpuInfo': capabilities.gpuInfo,
        'processorType': capabilities.processorType,
        'deviceModel': capabilities.deviceModel,
        'manufacturer': capabilities.manufacturer,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await CacheService.instance.setHardwareData('capabilities', data);
    } catch (e) {
      debugPrint('Error guardando cache de hardware: $e');
    }
  }

  // Método para forzar nueva detección (útil para debugging)
  Future<void> forceRedetect() async {
    try {
      final detected = await HardwareCapabilities.detect();
      state = AsyncData(detected);
      await _saveToCache(detected);
    } catch (e) {
      // Mantener estado actual en caso de error
    }
  }

  // Método para limpiar cache
  Future<void> clearCache() async {
    try {
      await CacheService.instance.remove('hardware_capabilities');
    } catch (e) {
      debugPrint('Error limpiando cache de hardware: $e');
    }
  }
}

// Provider principal para las capacidades de hardware
final hardwareCapabilitiesProvider =
    AsyncNotifierProvider<HardwareCapabilitiesNotifier, HardwareCapabilities>(
      () => HardwareCapabilitiesNotifier(),
    );

// Provider para el estado de carga - se actualiza automáticamente
final hardwareLoadingProvider = Provider<bool>((ref) {
  final capabilitiesAsync = ref.watch(hardwareCapabilitiesProvider);
  return capabilitiesAsync.isLoading;
});

// Provider combinado que indica si el hardware está listo
final hardwareReadyProvider = Provider<bool>((ref) {
  final capabilitiesAsync = ref.watch(hardwareCapabilitiesProvider);
  return capabilitiesAsync.hasValue;
});
