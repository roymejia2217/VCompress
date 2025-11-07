
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/data/services/video_metadata_service.dart';
import 'package:vcompressor/data/services/video_metadata_service_mobile.dart';
import 'package:vcompressor/data/services/video_processor_service.dart';
import 'package:vcompressor/data/services/video_processor_service_mobile.dart';

final videoProcessorServiceProvider = Provider<VideoProcessorService>((ref) {
  return VideoProcessorServiceMobile(ref);
});

final videoMetadataServiceProvider = Provider<VideoMetadataService>((ref) {
  return VideoMetadataServiceMobile();
});
