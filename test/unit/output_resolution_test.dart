import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/video_task.dart';

/// Pruebas unitarias para OutputResolution
/// Asegura la estabilidad de label y evita errores silenciosos
void main() {
  group('OutputResolution', () {
    test('label is stable and non-empty for all values', () {
      // Verificar que todos los valores del enum tienen label válido
      for (final resolution in OutputResolution.values) {
        expect(
          resolution.label.isNotEmpty,
          true,
          reason: 'label should not be empty for ${resolution.name}',
        );
        expect(
          resolution.label.trim(),
          resolution.label,
          reason:
              'label should not have leading/trailing whitespace for ${resolution.name}',
        );
      }
    });

    test('label values are unique', () {
      // Verificar que no hay labels duplicados
      final labels = OutputResolution.values.map((r) => r.label).toList();
      final uniqueLabels = labels.toSet();

      expect(
        labels.length,
        uniqueLabels.length,
        reason: 'All label values should be unique',
      );
    });

    test('specific label values are correct', () {
      // Verificar valores específicos para detectar regresiones
      expect(OutputResolution.original.label, 'Original');
      expect(OutputResolution.p1080.label, '1080p');
      expect(OutputResolution.p720.label, '720p');
      expect(OutputResolution.p480.label, '480p');
      expect(OutputResolution.p360.label, '360p');
      expect(OutputResolution.p240.label, '240p');
      expect(OutputResolution.p144.label, '144p');
    });

    test('scaleHeightArg is available for all values', () {
      // Verificar que todas las extensiones funcionan correctamente
      for (final resolution in OutputResolution.values) {
        // scaleHeightArg puede ser null para 'original', pero no debe fallar
        expect(
          () => resolution.scaleHeightArg,
          returnsNormally,
          reason: 'scaleHeightArg should be accessible for ${resolution.name}',
        );
      }
    });

    test('specific scaleHeightArg values are correct', () {
      // Verificar valores específicos
      expect(OutputResolution.original.scaleHeightArg, null);
      expect(OutputResolution.p1080.scaleHeightArg, '1080');
      expect(OutputResolution.p720.scaleHeightArg, '720');
      expect(OutputResolution.p480.scaleHeightArg, '480');
      expect(OutputResolution.p360.scaleHeightArg, '360');
      expect(OutputResolution.p240.scaleHeightArg, '240');
      expect(OutputResolution.p144.scaleHeightArg, '144');
    });

    test('all resolutions have consistent properties', () {
      // Verificar que todas las resoluciones tienen propiedades consistentes
      for (final resolution in OutputResolution.values) {
        // Verificar que label no está vacío
        expect(resolution.label.isNotEmpty, true);
        // Verificar que scaleHeightArg es accesible
        expect(() => resolution.scaleHeightArg, returnsNormally);
        // Para resoluciones específicas, debe tener un valor numérico
        if (resolution != OutputResolution.original) {
          expect(resolution.scaleHeightArg, isNotNull);
          expect(int.tryParse(resolution.scaleHeightArg!), isNotNull);
        }
      }
    });
  });
}
