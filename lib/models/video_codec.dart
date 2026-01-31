import 'package:flutter/material.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

enum VideoCodec {
  h264,
  h265,
  vp9, // Principalmente para WebM
  auto; // Dejar que FFmpeg decida (o usar default)

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case VideoCodec.h264:
        return l10n.h264;
      case VideoCodec.h265:
        return l10n.h265;
      case VideoCodec.vp9:
        return 'VP9';
      case VideoCodec.auto:
        return 'Auto';
    }
  }

  /// Nombre del encoder de software en FFmpeg
  String get ffmpegName {
    switch (this) {
      case VideoCodec.h264:
        return 'libx264';
      case VideoCodec.h265:
        return 'libx265';
      case VideoCodec.vp9:
        return 'libvpx-vp9';
      case VideoCodec.auto:
        return 'libx264'; // Default safe
    }
  }
}
