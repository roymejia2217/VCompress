import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';

void main() {
  group('VideoSettings Configuration', () {
    test('should create default settings', () {
      // Act
      final settings = VideoSettings.defaults();

      // Assert
      expect(settings.algorithm, equals(CompressionAlgorithm.excelenteCalidad));
      expect(settings.resolution, equals(OutputResolution.original));
      expect(settings.removeAudio, isFalse);
      expect(settings.format, equals(OutputFormat.mp4));
      expect(settings.editSettings.enableVolume, isFalse);
      expect(settings.editSettings.speed, equals(1.0));
    });

    test('should create settings with custom values', () {
      // Act
      const settings = VideoSettings(
        algorithm: CompressionAlgorithm.buenaCalidad,
        resolution: OutputResolution.p720,
        removeAudio: true,
        format: OutputFormat.mkv,
      );

      // Assert
      expect(settings.algorithm, equals(CompressionAlgorithm.buenaCalidad));
      expect(settings.resolution, equals(OutputResolution.p720));
      expect(settings.removeAudio, isTrue);
      expect(settings.format, equals(OutputFormat.mkv));
    });

    test('should copy settings with modifications', () {
      // Arrange
      final original = VideoSettings.defaults();

      // Act
      final modified = original.copyWith(
        algorithm: CompressionAlgorithm.maximaCalidad,
        resolution: OutputResolution.p1080,
        removeAudio: true,
      );

      // Assert
      expect(modified.algorithm, equals(CompressionAlgorithm.maximaCalidad));
      expect(modified.resolution, equals(OutputResolution.p1080));
      expect(modified.removeAudio, isTrue);
      expect(modified.format, equals(original.format)); // Unchanged
    });

    test('should provide compressionSettings map', () {
      // Arrange
      final settings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.buenaCalidad,
        resolution: OutputResolution.p720,
      );

      // Act
      final compression = settings.compressionSettings;

      // Assert
      expect(compression['video']['codec'], equals('buenaCalidad'));
      expect(compression['video']['resolution'], equals('720'));
      expect(compression['video']['removeAudio'], isFalse);
      expect(compression['edit'], isNotEmpty);
    });

    test('should provide videoConfig getter', () {
      // Arrange
      final settings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
        removeAudio: true,
      );

      // Assert
      expect(settings.videoConfig['codec'], equals('ultraCompresion'));
      expect(settings.videoConfig['removeAudio'], isTrue);
    });

    test('should provide editConfig getter', () {
      // Arrange
      const editSettings = VideoEditSettings(
        enableVolume: true,
        volumeLevel: 1.5,
        isMuted: false,
        speed: 2.0,
        enableSpeed: true,
      );
      final settings = VideoSettings.defaults().copyWith(
        editSettings: editSettings,
      );

      // Act
      final editConfig = settings.editConfig;

      // Assert
      expect(editConfig['enableVolume'], isTrue);
      expect(editConfig['volumeLevel'], equals(1.5));
      expect(editConfig['speed'], equals(2.0));
      expect(editConfig['enableSpeed'], isTrue);
    });

    test('should identify high quality settings correctly', () {
      // Arrange & Act
      final highQuality = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.excelenteCalidad,
      );
      final lowQuality = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
      );

      // Assert
      expect(highQuality.isHighQuality, isTrue);
      expect(lowQuality.isHighQuality, isFalse);
    });

    test('should identify low quality settings correctly', () {
      // Arrange & Act
      final lowQuality = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
      );
      const mediumQuality = VideoSettings(
        algorithm: CompressionAlgorithm.compresionMedia,
        resolution: OutputResolution.original,
        removeAudio: false,
        format: OutputFormat.mp4,
      );

      // Assert
      expect(lowQuality.isLowQuality, isTrue);
      expect(mediumQuality.isLowQuality, isFalse);
    });

    test('should generate FFmpeg command based on settings', () {
      // Arrange
      final settings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.buenaCalidad,
        resolution: OutputResolution.p720,
        removeAudio: true,
      );

      // Act
      final command = settings.ffmpegCommand;

      // Assert
      expect(command, contains('buenaCalidad'));
      expect(command, contains('scale=-2:720'));
      expect(command, contains('-an')); // no audio
      expect(command, contains('-f mp4'));
    });

    test('should handle edit settings with volume and speed', () {
      // Arrange
      const editSettings = VideoEditSettings(
        enableVolume: true,
        volumeLevel: 0.8,
        isMuted: false,
        enableSpeed: true,
        speed: 1.5,
      );
      final settings = VideoSettings.defaults().copyWith(
        editSettings: editSettings,
      );

      // Act
      final editConfig = settings.editConfig;

      // Assert
      expect(editConfig['volumeLevel'], equals(0.8));
      expect(editConfig['speed'], equals(1.5));
      expect(editConfig['enableSpeed'], isTrue);
    });

    test('should handle muted settings', () {
      // Arrange
      const editSettings = VideoEditSettings(
        isMuted: true,
        volumeLevel: 1.0,
      );

      // Act
      final effectiveVolume = editSettings.getEffectiveVolume();

      // Assert
      expect(effectiveVolume, equals(0.0));
    });

    test('should calculate effective volume correctly', () {
      // Arrange & Act
      const unmuted = VideoEditSettings(
        isMuted: false,
        volumeLevel: 1.5,
      );
      const muted = VideoEditSettings(
        isMuted: true,
        volumeLevel: 1.5,
      );

      // Assert
      expect(unmuted.getEffectiveVolume(), equals(1.5));
      expect(muted.getEffectiveVolume(), equals(0.0));
    });

    test('should detect settings equality', () {
      // Arrange
      final settings1 = VideoSettings.defaults();
      final settings2 = VideoSettings.defaults();
      final settings3 = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.maximaCalidad,
      );

      // Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('should provide consistent hash code', () {
      // Arrange
      final settings1 = VideoSettings.defaults();
      final settings2 = VideoSettings.defaults();

      // Act & Assert
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should handle edit settings equality', () {
      // Arrange
      const editSettings1 = VideoEditSettings(
        enableVolume: true,
        volumeLevel: 1.0,
      );
      const editSettings2 = VideoEditSettings(
        enableVolume: true,
        volumeLevel: 1.0,
      );
      const editSettings3 = VideoEditSettings(
        enableVolume: false,
        volumeLevel: 1.0,
      );

      // Assert
      expect(editSettings1, equals(editSettings2));
      expect(editSettings1, isNot(equals(editSettings3)));
    });

    test('should copy edit settings with modifications', () {
      // Arrange
      const original = VideoEditSettings(
        enableVolume: false,
        volumeLevel: 1.0,
        isMuted: false,
      );

      // Act
      final modified = original.copyWith(
        enableVolume: true,
        volumeLevel: 1.5,
      );

      // Assert
      expect(modified.enableVolume, isTrue);
      expect(modified.volumeLevel, equals(1.5));
      expect(modified.isMuted, isFalse); // Unchanged
    });
  });

  group('VideoEditSettings FPS Configuration', () {
    test('should enable and set target FPS', () {
      // Arrange & Act
      const settings = VideoEditSettings(
        enableFps: true,
        targetFps: 30,
      );

      // Assert
      expect(settings.enableFps, isTrue);
      expect(settings.targetFps, equals(30));
    });

    test('should support square format conversion', () {
      // Arrange & Act
      const settings = VideoEditSettings(
        enableSquareFormat: true,
      );

      // Assert
      expect(settings.enableSquareFormat, isTrue);
    });

    test('should support mirror/flip effect', () {
      // Arrange & Act
      const settings = VideoEditSettings(
        enableMirror: true,
      );

      // Assert
      expect(settings.enableMirror, isTrue);
    });

    test('should support file replacement flag', () {
      // Arrange & Act
      const settings = VideoEditSettings(
        replaceOriginalFile: true,
      );

      // Assert
      expect(settings.replaceOriginalFile, isTrue);
    });
  });
}
