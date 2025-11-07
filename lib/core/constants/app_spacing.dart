import 'package:flutter/material.dart';

// Material 3 Design Tokens - 8dp grid system
class AppSpacing {
  // Spacing base 4dp
  static const double xs = 4.0; // 4dp
  static const double s = 8.0; // 8dp (1 unit)
  static const double m = 16.0; // 16dp (2 units)
  static const double l = 24.0; // 24dp (3 units)
  static const double xl = 32.0; // 32dp (4 units)
  static const double xxl = 48.0; // 48dp (6 units)

  // EdgeInsets const para performance óptima
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingS = EdgeInsets.all(s);
  static const EdgeInsets paddingM = EdgeInsets.all(m);
  static const EdgeInsets paddingL = EdgeInsets.all(l);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal/vertical específicos
  static const EdgeInsets horizontalS = EdgeInsets.symmetric(horizontal: s);
  static const EdgeInsets horizontalM = EdgeInsets.symmetric(horizontal: m);
  static const EdgeInsets verticalS = EdgeInsets.symmetric(vertical: s);
  static const EdgeInsets verticalM = EdgeInsets.symmetric(vertical: m);

  // Private constructor
  const AppSpacing._();
}
