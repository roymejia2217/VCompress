import 'package:flutter/material.dart';

/// Extension para acceso fácil a theme properties
///
/// **KISS/DRY/YAGNI:** Single source of truth para theme shortcuts.
/// Elimina múltiples llamadas a Theme.of(context) y proporciona acceso directo.
///
/// **USO:**
/// ```dart
/// Widget build(BuildContext context) {
///   final colorScheme = context.colorScheme;
///   final textTheme = context.textTheme;
///
///   return Text(
///     'Hello',
///     style: textTheme.bodyLarge?.copyWith(
///       color: colorScheme.primary,
///     ),
///   );
/// }
/// ```
extension BuildContextThemeExtensions on BuildContext {
  /// Acceso directo a ThemeData
  ThemeData get theme => Theme.of(this);

  /// Acceso directo a ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Acceso directo a TextTheme
  TextTheme get textTheme => theme.textTheme;
}
