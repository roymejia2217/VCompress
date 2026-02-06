import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';


/// Sistema ÚNICO de AppBars para toda la aplicación
/// Implementa Material Design 3 con centrado vertical correcto
///
/// VARIANTES:
/// - AppAppBar.home(): Página principal (SIN botón de regresar)
/// - AppAppBar.withReturn(): Páginas secundarias (CON botón de regresar)
///
/// KISS + DRY: Solo 2 factory constructors reutilizables
/// Icono back CONSTANTE: PhosphorIconsRegular.arrowUUpLeft para todos los casos
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget; // Widget opcional para subtítulo dinámico
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final IconData? backIcon; // Icono personalizado para botón back
  final VoidCallback? onBackPressed; // Acción personalizada para back

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.backIcon,
    this.onBackPressed,
  });

  /// Factory para HomePage (sin botón de regresar)
  /// USO: AppAppBar.home(
  ///   title: 'VCompress',
  ///   subtitle: 'Comprime videos sin perder calidad',
  ///   actions: [...],
  /// )
  const AppAppBar.home({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  }) : leading = null,
       subtitleWidget = null,
       backgroundColor = null,
       centerTitle = false,
       automaticallyImplyLeading = false, // SIN botón back
       titleSpacing = AppSpacing.m,
       backIcon = null,
       onBackPressed = null;

  /// Factory para páginas con botón de regresar (Settings, Process, etc.)
  /// ICONO CONSTANTE: PhosphorIconsRegular.arrowUUpLeft (flecha diagonal)
  /// USO básico: AppAppBar.withReturn(title: 'Configuración', subtitle: '...')
  /// USO dinámico: AppAppBar.withReturn(title: '...', subtitleWidget: ValueListenableBuilder(...))
  const AppAppBar.withReturn({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.actions,
    this.onBackPressed, // Acción opcional (default: Navigator.pop)
  }) : leading = null,
       backgroundColor = null,
       centerTitle = false,
       automaticallyImplyLeading = false, // Manual con leading custom
       titleSpacing = null,
       backIcon = PhosphorIconsRegular.arrowUUpLeft; // CONSTANTE

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Material 3: surfaceContainerHigh para color grisáceo distintivo
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHigh;

    // Crear leading con IconButton nativo si está definido (M3 consistency)
    final effectiveLeading =
        leading ??
        (backIcon != null
            ? IconButton(
                icon: Icon(backIcon!),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                tooltip: 'Volver',
              )
            : null);
            
    final hasSubtitle = subtitle != null || subtitleWidget != null;

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      centerTitle: centerTitle,
      leading: effectiveLeading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: titleSpacing,
      toolbarHeight: hasSubtitle ? 80.0 : kToolbarHeight,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // Align: centra vertical, mantiene alineación horizontal izquierda
      title: hasSubtitle
          ? Align(
              alignment: Alignment.centerLeft,
              child: _buildTitleWithSubtitle(context, colorScheme),
            )
          : _buildBasicTitle(context, colorScheme),
    );
  }

  /// Construye título básico sin subtítulo
  Widget _buildBasicTitle(BuildContext context, ColorScheme colorScheme) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Construye título con subtítulo (Material 3 Small with subtitle)
  Widget _buildTitleWithSubtitle(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alineación izquierda M3
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitleWidget != null)
           Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.0,
              ),
              child: subtitleWidget!,
            ),
           )
        else if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize {
    final hasSubtitle = subtitle != null || subtitleWidget != null;
    return Size.fromHeight(hasSubtitle ? 80 : kToolbarHeight);
  }
}
