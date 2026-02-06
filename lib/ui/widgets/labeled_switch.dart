import 'package:flutter/material.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';

/// Widget helper reutilizable para Switch con label siguiendo Material 3
///
/// **CARACTERÍSTICAS:**
/// - Switch nativo Material 3 con theming automático
/// - Label clickeable que activa el switch
/// - Touch target 48dp mínimo (accesibilidad WCAG)
/// - Semantics automáticas del Switch nativo
/// - Padding consistente con AppSpacing
///
/// **USO:**
/// ```dart
/// LabeledSwitch(
///   label: 'Quitar audio',
///   value: isMuted,
///   onChanged: (newValue) {
///     // Update state
///   },
/// )
/// ```
class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const LabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m, // 16dp
          vertical: AppSpacing.s, // 8dp
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            IgnorePointer(
              child: Switch(
                value: value,
                onChanged: onChanged != null ? (_) {} : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
