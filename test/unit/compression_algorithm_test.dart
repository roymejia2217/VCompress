import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/algorithm.dart';

/// Pruebas unitarias para CompressionAlgorithm
/// Asegura la estabilidad de displayName y evita errores silenciosos
void main() {
  group('CompressionAlgorithm', () {
    test('displayName is stable and non-empty for all values', () {
      // Verificar que todos los valores del enum tienen displayName válido
      for (final algorithm in CompressionAlgorithm.values) {
        expect(
          algorithm.displayName.isNotEmpty,
          true,
          reason: 'displayName should not be empty for ${algorithm.name}',
        );
        expect(
          algorithm.displayName.trim(),
          algorithm.displayName,
          reason:
              'displayName should not have leading/trailing whitespace for ${algorithm.name}',
        );
      }
    });

    test('displayName values are unique', () {
      // Verificar que no hay displayNames duplicados
      final displayNames = CompressionAlgorithm.values
          .map((a) => a.displayName)
          .toList();
      final uniqueNames = displayNames.toSet();

      expect(
        displayNames.length,
        uniqueNames.length,
        reason: 'All displayName values should be unique',
      );
    });

    test('specific displayName values are correct', () {
      // Verificar valores específicos para detectar regresiones
      expect(CompressionAlgorithm.maximaCalidad.displayName, 'Máxima Calidad');
      expect(
        CompressionAlgorithm.excelenteCalidad.displayName,
        'Excelente Calidad',
      );
      expect(CompressionAlgorithm.buenaCalidad.displayName, 'Buena Calidad');
      expect(
        CompressionAlgorithm.compresionMedia.displayName,
        'Compresión Media',
      );
      expect(
        CompressionAlgorithm.ultraCompresion.displayName,
        'Ultra Compresión',
      );
    });

    test('briefDescription is available for all values', () {
      // Verificar que todas las extensiones funcionan correctamente
      for (final algorithm in CompressionAlgorithm.values) {
        expect(
          algorithm.briefDescription.isNotEmpty,
          true,
          reason: 'briefDescription should not be empty for ${algorithm.name}',
        );
      }
    });

    test('ffmpegCodec is available for all values', () {
      // Verificar que todos los codecs están definidos
      for (final algorithm in CompressionAlgorithm.values) {
        expect(
          algorithm.ffmpegCodec.isNotEmpty,
          true,
          reason: 'ffmpegCodec should not be empty for ${algorithm.name}',
        );
        expect(
          ['libx264', 'libx265'].contains(algorithm.ffmpegCodec),
          true,
          reason: 'ffmpegCodec should be valid for ${algorithm.name}',
        );
      }
    });
  });
}
