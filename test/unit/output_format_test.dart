import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/video_task.dart';

/// Pruebas unitarias para OutputFormat
/// Asegura la estabilidad de label y evita errores silenciosos
void main() {
  group('OutputFormat', () {
    test('label is stable and non-empty for all values', () {
      // Verificar que todos los valores del enum tienen label válido
      for (final format in OutputFormat.values) {
        expect(
          format.label.isNotEmpty,
          true,
          reason: 'label should not be empty for ${format.name}',
        );
        expect(
          format.label.trim(),
          format.label,
          reason:
              'label should not have leading/trailing whitespace for ${format.name}',
        );
      }
    });

    test('label values are unique', () {
      // Verificar que no hay labels duplicados
      final labels = OutputFormat.values.map((f) => f.label).toList();
      final uniqueLabels = labels.toSet();

      expect(
        labels.length,
        uniqueLabels.length,
        reason: 'All label values should be unique',
      );
    });

    test('specific label values are correct', () {
      // Verificar valores específicos para detectar regresiones
      expect(OutputFormat.mp4.label, 'MP4');
      expect(OutputFormat.avi.label, 'AVI');
      expect(OutputFormat.mov.label, 'MOV');
      expect(OutputFormat.mkv.label, 'MKV');
      expect(OutputFormat.webm.label, 'WebM');
    });

    test('extension is available for all values', () {
      // Verificar que todas las extensiones funcionan correctamente
      for (final format in OutputFormat.values) {
        expect(
          format.extension.isNotEmpty,
          true,
          reason: 'extension should not be empty for ${format.name}',
        );
        expect(
          format.extension.startsWith('.'),
          true,
          reason: 'extension should start with dot for ${format.name}',
        );
      }
    });

    test('specific extension values are correct', () {
      // Verificar valores específicos
      expect(OutputFormat.mp4.extension, '.mp4');
      expect(OutputFormat.avi.extension, '.avi');
      expect(OutputFormat.mov.extension, '.mov');
      expect(OutputFormat.mkv.extension, '.mkv');
      expect(OutputFormat.webm.extension, '.webm');
    });

    test('briefDescription is available for all values', () {
      // Verificar que todas las descripciones están disponibles
      for (final format in OutputFormat.values) {
        expect(
          format.briefDescription.isNotEmpty,
          true,
          reason: 'briefDescription should not be empty for ${format.name}',
        );
      }
    });
  });
}
