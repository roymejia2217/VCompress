import 'package:flutter_test/flutter_test.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/models/algorithm.dart';
import 'package:vcompressor/models/video_codec.dart';

void main() {
  group('VideoSettings Configuration', () {
    test('should create default settings', () {
      // Act
      final settings = VideoSettings.defaults();

      // Assert
      expect(settings.algorithm, equals(CompressionAlgorithm.excelenteCalidad));
      expect(settings.codec, equals(VideoCodec.h264));
      expect(settings.scale, equals(1.0));
      expect(settings.removeAudio, isFalse);
      expect(settings.format, equals(OutputFormat.mp4));
      expect(settings.editSettings.enableVolume, isFalse);
      expect(settings.editSettings.speed, equals(1.0));
    });

    test('should create settings with custom values', () {
      // Act
      const settings = VideoSettings(
        algorithm: CompressionAlgorithm.buenaCalidad,
        codec: VideoCodec.h265,
        scale: 0.7,
        removeAudio: true,
        format: OutputFormat.mkv,
      );

      // Assert
      expect(settings.algorithm, equals(CompressionAlgorithm.buenaCalidad));
      expect(settings.codec, equals(VideoCodec.h265));
      expect(settings.scale, equals(0.7));
      expect(settings.removeAudio, isTrue);
      expect(settings.format, equals(OutputFormat.mkv));
    });

    test('should copy settings with modifications', () {
      // Arrange
      final original = VideoSettings.defaults();

      // Act
      final modified = original.copyWith(
        algorithm: CompressionAlgorithm.maximaCalidad,
        scale: 0.5,
        removeAudio: true,
      );

      // Assert
      expect(modified.algorithm, equals(CompressionAlgorithm.maximaCalidad));
      expect(modified.scale, equals(0.5));
      expect(modified.removeAudio, isTrue);
      expect(modified.format, equals(original.format)); // Unchanged
      expect(modified.codec, equals(original.codec)); // Unchanged
    });

    test('should provide compressionSettings map', () {
      // Arrange
      final settings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.buenaCalidad,
        scale: 0.8,
        codec: VideoCodec.h264,
      );

      // Act
      final compression = settings.compressionSettings;

      // Assert
      // 'algorithm' stores the algorithm name
      expect(compression['video']['algorithm'], equals('buenaCalidad'));
      // 'codec' stores the codec enum name (e.g., 'h264')
      expect(compression['video']['codec'], equals('h264'));
      expect(compression['video']['scale'], equals(0.8));
      expect(compression['video']['removeAudio'], isFalse);
      expect(compression['edit'], isNotEmpty);
    });

    test('should provide videoConfig getter', () {
      // Arrange
      final settings = VideoSettings.defaults().copyWith(
        algorithm: CompressionAlgorithm.ultraCompresion,
        removeAudio: true,
        codec: VideoCodec.h265,
      );

      // Assert
      expect(settings.videoConfig['algorithm'], equals('ultraCompresion'));
      expect(settings.videoConfig['codec'], equals('h265'));
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
        codec: VideoCodec.h264,
        scale: 1.0,
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
        algorithm: CompressionAlgorithm.buenaCalidad, // preset: 'fast'
        scale: 0.5,
        removeAudio: true,
        codec: VideoCodec.h264, // libx264
      );

      // Act
      final command = settings.ffmpegCommand;

      // Assert
      expect(command, contains('libx264')); // Codec
      expect(command, contains('-preset fast')); // Preset for buenaCalidad
      // scale filter for 0.5: scale=trunc(iw*0.50/2)*2:trunc(ih*0.50/2)*2
      expect(command, contains('scale=trunc(iw*0.50/2)*2:trunc(ih*0.50/2)*2'));
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
