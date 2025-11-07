import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/ui/widgets/app_icons.dart';
import 'package:vcompressor/ui/widgets/video_config_modal.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart' as tokens;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

/// Modal de decisión para configuración batch
/// SOLID: Single Responsibility - solo presenta opción al usuario
/// Aparece automáticamente cuando se agregan múltiples videos
class BatchConfigDecisionModal extends ConsumerWidget {
  final int videoCount;

  const BatchConfigDecisionModal({super.key, required this.videoCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Migrado: Usar constantes estáticas en lugar de AppThemeVars deprecated

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          Row(
            children: [
              const AppIcon(
                icon: PhosphorIconsFill.video,
                config: AppIconConfig.large(),
              ),
              const SizedBox(width: tokens.AppSpacing.s),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.configureVideosNow(videoCount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: tokens.AppSpacing.m),

          // Botón: Configuración rápida
          FilledButton.icon(
            onPressed: () async {
              // Cerrar este modal
              Navigator.of(context).pop();

              // Mostrar modal de configuración batch (task = null)
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const VideoConfigModal(), // Batch mode
              );
            },
            icon: const Icon(PhosphorIconsFill.lightning),
            label: Text(AppLocalizations.of(context)!.useSameConfiguration),
          ),
          const SizedBox(height: tokens.AppSpacing.s),

          // Botón: Configurar individualmente
          FilledButton.tonalIcon(
            onPressed: () {
              // Solo cerrar - usuario configurará cada video manualmente
              Navigator.of(context).pop();
            },
            icon: const Icon(PhosphorIconsRegular.sliders),
            label: Text(AppLocalizations.of(context)!.configureIndividually),
          ),
        ],
      ),
    );
  }
}
