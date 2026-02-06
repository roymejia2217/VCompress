

import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/core/result/result.dart';
import 'package:vcompressor/core/error/app_error.dart';

abstract class VideoProcessorService {
  Future<Result<void, AppError>> processVideo({
    required VideoTask task,
    required String outputPath,
    required void Function(double) onProgress,
    required void Function(Duration?) onTimeEstimate,
    bool useTemporaryFile = false,
  });

  void cancelCurrentProcess();

  bool get isProcessing;
}
