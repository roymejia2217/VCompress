import 'package:flutter/material.dart';

/// Tamaños de spacing vertical estándar
///  Migrado: Valores alineados con constantes AppSpacing
enum AppSpacingSize {
  xs, // Extra small: 4dp (constants.AppSpacing.xs)
  s, // Small: 8dp (constants.AppSpacing.s)
  m, // Medium: 16dp (constants.AppSpacing.m)
  l, // Large: 20dp (constants.AppSpacing.l)
  xl, // Extra large: 24dp (constants.AppSpacing.xl)
}

/// Widget de spacing vertical consistente
///  Migrado: Usa constantes estáticas AppSpacing en lugar de AppThemeVars deprecated
/// Reemplaza SizedBox con alturas hardcodeadas
class AppSpacing extends StatelessWidget {
  final AppSpacingSize size;

  const AppSpacing(this.size, {super.key});

  /// Factory constructors para uso rápido
  const AppSpacing.xs({super.key}) : size = AppSpacingSize.xs;
  const AppSpacing.s({super.key}) : size = AppSpacingSize.s;
  const AppSpacing.m({super.key}) : size = AppSpacingSize.m;
  const AppSpacing.l({super.key}) : size = AppSpacingSize.l;
  const AppSpacing.xl({super.key}) : size = AppSpacingSize.xl;

  @override
  Widget build(BuildContext context) {
    // Migrado: Usar constantes estáticas en lugar de AppThemeVars deprecated
    final double height = switch (size) {
      AppSpacingSize.xs => 4.0, // AppSpacing.xs
      AppSpacingSize.s => 8.0, // AppSpacing.s
      AppSpacingSize.m => 16.0, // AppSpacing.m
      AppSpacingSize.l => 20.0, // AppSpacing.l
      AppSpacingSize.xl => 24.0, // AppSpacing.xl
    };

    return SizedBox(height: height);
  }
}
