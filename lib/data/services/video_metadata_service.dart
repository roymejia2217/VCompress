
class VideoMetadata {
  final int? fileSize;
  final String? thumbnailPath;
  final int? width;
  final int? height;
  final double? duration;
  final double? fps; // FPS del video original

  const VideoMetadata({
    this.fileSize,
    this.thumbnailPath,
    this.width,
    this.height,
    this.duration,
    this.fps,
  });
}

abstract class VideoMetadataService {
  Future<VideoMetadata> extractMetadata(String videoPath);
}
