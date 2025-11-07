import 'package:flutter/material.dart';

/// Sistema de temas simplificado siguiendo KISS/DRY/YAGNI
///
/// **ENFOQUE:**
/// - ColorScheme.fromSeed nativo M3 (sin FlexColorScheme)
/// - AppBar configuración mínima
/// - Design tokens como static constants
///
/// **USO:**
/// ```dart
/// Widget build(BuildContext context) {
///   final colorScheme = context.colorScheme;
///
///   return Container(
///     padding: AppPadding.m,
///     decoration: BoxDecoration(
///       color: colorScheme.primary,
///       borderRadius: BorderRadius.circular(AppRadius.m),
///     ),
///   );
/// }
/// ```

/// Tema claro usando ColorScheme.fromSeed nativo M3
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4), // Indigo
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0, // Solo override si quieres 0 siempre
  ),
);

/// Tema oscuro usando ColorScheme.fromSeed nativo M3
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4), // Indigo
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0, // Solo override si quieres 0 siempre
  ),
);
