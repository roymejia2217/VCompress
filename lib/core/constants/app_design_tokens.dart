import 'package:flutter/widgets.dart';

/// Design tokens siguiendo especificaciones Material 3
///
/// **KISS/DRY/YAGNI:** Single source of truth para todas las constantes de diseño.
/// Static constants son más eficientes que ThemeExtension para valores inmutables.
///
/// **USO:**
/// ```dart
/// Container(
///   padding: AppPadding.m,
///   decoration: BoxDecoration(
///     borderRadius: BorderRadius.circular(AppRadius.m),
///   ),
/// )
/// ```
class AppSpacing {
  /// Extra small: 4dp - Base grid M3
  static const double xs = 4.0;

  /// Small: 8dp - Espaciado pequeño estándar
  static const double s = 8.0;

  /// Medium: 16dp - Espaciado estándar (M3 default)
  static const double m = 16.0;

  /// Large: 24dp - Espaciado grande entre secciones
  static const double l = 24.0;

  /// Extra large: 32dp - Espaciado máximo
  static const double xl = 32.0;

  const AppSpacing._();
}

/// Border radius siguiendo Material 3 Corner Tokens
class AppRadius {
  /// Extra small: 4dp - Progress bars, badges
  static const double xs = 4.0;

  /// Small: 8dp - Chips, pequeños containers
  static const double s = 8.0;

  /// Medium: 12dp - Botones, cards, inputs (M3 default)
  static const double m = 12.0;

  /// Large: 16dp - Cards grandes, modales
  static const double l = 16.0;

  /// Extra large: 28dp - Dialogs, bottom sheets
  static const double xl = 28.0;

  const AppRadius._();
}

/// Tamaños de iconos siguiendo Material 3 Icon Tokens
class AppIconSize {
  /// Small: 16dp - Iconos pequeños en botones secundarios
  static const double s = 16.0;

  /// Medium: 20dp - Iconos medianos en acciones regulares
  static const double m = 20.0;

  /// Large: 24dp - Iconos default M3 (acciones principales)
  static const double l = 24.0;

  const AppIconSize._();
}

/// Padding helpers usando AppSpacing
class AppPadding {
  /// Extra small: 4dp all sides
  static const EdgeInsets xs = EdgeInsets.all(AppSpacing.xs);

  /// Small: 8dp all sides
  static const EdgeInsets s = EdgeInsets.all(AppSpacing.s);

  /// Medium: 16dp all sides
  static const EdgeInsets m = EdgeInsets.all(AppSpacing.m);

  /// Large: 24dp all sides
  static const EdgeInsets l = EdgeInsets.all(AppSpacing.l);

  /// Extra large: 32dp all sides
  static const EdgeInsets xl = EdgeInsets.all(AppSpacing.xl);

  const AppPadding._();
}

/// Outline widths para borders
class AppOutline {
  /// Width estándar: 1.5px - Borders, outlines
  static const double width = 1.5;

  /// Width thick: 2.0px - Borders enfatizados
  static const double widthThick = 2.0;

  const AppOutline._();
}
