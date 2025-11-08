import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/ui/widgets/app_app_bar.dart';
import 'package:vcompressor/ui/widgets/app_icons.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart' as tokens;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/ui/widgets/app_spacing.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final saveDirAsync = ref.watch(saveDirProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppAppBar.withReturn(
        title: l10n.settings,
        subtitle: l10n.settingsSubtitle,
      ),
      body: ListView(
        padding: tokens.AppPadding.m,
        children: [
          // Sección de Tema - Material 3 Pattern con Card Outlined
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: tokens.AppPadding.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appearance,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: tokens.AppSpacing.s),
                  // Material 3: SegmentedButton con propiedades consistentes
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      style: const ButtonStyle(
                        visualDensity:
                            VisualDensity.standard, // M3 compact density
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.light),
                          icon: const AppIcon.small(
                            icon: PhosphorIconsFill.sun,
                          ),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l10n.dark),
                          icon: const AppIcon.small(
                            icon: PhosphorIconsFill.moon,
                          ),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.system),
                          icon: const AppIcon.small(
                            icon: PhosphorIconsFill.globeSimple,
                          ),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (s) => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(s.first),
                      showSelectedIcon:
                          false, // Sin checkmark para compacidad
                    ),
                  ),
                ],
              ),
            ),
          ),

          const AppSpacing(AppSpacingSize.l),

          // Sección de Idioma - Material 3 Pattern con Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: tokens.AppPadding.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: tokens.AppSpacing.s),
                  // DropdownMenu para idiomas (escalable para 10+ idiomas)
                  DropdownMenu<Locale>(
                    expandedInsets: EdgeInsets.zero,
                    enableSearch: true,
                    initialSelection: locale,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry<Locale>(
                        value: Locale('es'),
                        label: 'Español',
                      ),
                      DropdownMenuEntry<Locale>(
                        value: Locale('en'),
                        label: 'English',
                      ),
                      DropdownMenuEntry<Locale>(
                        value: Locale('fr'),
                        label: 'Français',
                      ),
                      DropdownMenuEntry<Locale>(
                        value: Locale('it'),
                        label: 'Italiano',
                      ),
                    ],
                    onSelected: (value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const AppSpacing(AppSpacingSize.l),

          // Sección de Almacenamiento - Material 3 Pattern con Card Outlined
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: tokens.AppPadding.m,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.storage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: tokens.AppSpacing.s),
                  saveDirAsync.when(
                    // Estado de datos
                    data: (saveDir) => Column(
                      children: [
                        Semantics(
                          label:
                              'Carpeta de guardado configurada como $saveDir',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.saveFolder),
                            subtitle: Text(
                              saveDir,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: tokens.AppSpacing.s),
                        Semantics(
                          label: 'Cambiar carpeta de guardado',
                          hint: 'Activa para seleccionar nueva carpeta',
                          button: true,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              alignment: Alignment.center,
                              child: AppIcon.small(
                                icon: PhosphorIconsFill.folderOpen,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            title: Text(l10n.changeFolder),
                            trailing: const AppIcon.small(
                              icon: PhosphorIconsRegular.caretRight,
                            ),
                            onTap: () async {
                              await ref
                                  .read(saveDirNotifierProvider.notifier)
                                  .pickDirectory();
                            },
                          ),
                        ),
                      ],
                    ),
                    // Estado de carga
                    loading: () => const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularProgressIndicator(),
                      title: Text('Cargando configuración...'),
                    ),
                    // Estado de error
                    error: (error, stack) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const AppIcon.small(
                            icon: PhosphorIconsRegular.xCircle,
                            color: Colors.red,
                          ),
                          title: const Text('Error al cargar configuración'),
                          subtitle: Text(error.toString()),
                        ),
                        const SizedBox(height: tokens.AppSpacing.xs),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const AppIcon.small(
                            icon: PhosphorIconsRegular.arrowClockwise,
                          ),
                          title: const Text('Reintentar'),
                          onTap: () => ref.invalidate(saveDirProvider),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
