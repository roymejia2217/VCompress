import 'package:flutter/animation.dart';

/// Constantes de animación basadas en Material 3 Motion System
///
/// **Durations (Material 3 spec):**
/// - short1-4: 50-200ms - Transiciones rápidas (fade, small movement)
/// - medium1-4: 250-400ms - Transiciones estándar (page transitions, dialogs)
/// - long1-2: 450-500ms - Transiciones complejas (layout changes)
/// - extraLong1-2: 700-1000ms - Efectos especiales (loading, celebrations)
///
/// **Curves (Material 3 easing):**
/// - emphasized: Curva principal M3 para movimientos naturales
/// - emphasizedDecelerate: Entrada suave (elementos apareciendo)
/// - emphasizedAccelerate: Salida rápida (elementos desapareciendo)
/// - standard: Curva estándar para micro-interacciones
///
/// **USO:**
/// ```dart
/// AnimatedOpacity(
///   duration: AppAnimations.medium2,
///   curve: AppAnimations.emphasizedDecelerate,
///   opacity: isVisible ? 1.0 : 0.0,
///   child: child,
/// )
/// ```
///
/// **REFERENCIAS:**
/// - https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration
/// - https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
class AppAnimations {
  AppAnimations._(); // Prevent instantiation

  // ===== DURATIONS (Material 3 spec) =====

  /// Extra short: 50ms - Tooltip show/hide, ripple effects
  static const Duration short1 = Duration(milliseconds: 50);

  /// Short: 100ms - Simple fade in/out, icon changes
  static const Duration short2 = Duration(milliseconds: 100);

  /// Short: 150ms - Checkbox, radio transitions
  static const Duration short3 = Duration(milliseconds: 150);

  /// Short: 200ms - Switch toggle, simple state changes
  static const Duration short4 = Duration(milliseconds: 200);

  /// Medium: 250ms - Card expand, list item insertion
  static const Duration medium1 = Duration(milliseconds: 250);

  /// Medium: 300ms - Fade + slide combined, page transitions
  static const Duration medium2 = Duration(milliseconds: 300);

  /// Medium: 350ms - Complex state transitions
  static const Duration medium3 = Duration(milliseconds: 350);

  /// Medium: 400ms - Modal/dialog appearance
  static const Duration medium4 = Duration(milliseconds: 400);

  /// Long: 450ms - Layout changes, reordering
  static const Duration long1 = Duration(milliseconds: 450);

  /// Long: 500ms - Full-screen transitions
  static const Duration long2 = Duration(milliseconds: 500);

  /// Extra long: 700ms - Loading animations
  static const Duration extraLong1 = Duration(milliseconds: 700);

  /// Extra long: 1000ms - Celebration animations, progress loops
  static const Duration extraLong2 = Duration(milliseconds: 1000);

  // ===== CURVES (Material 3 Easing) =====

  /// Emphasized: Curva principal M3 para movimientos naturales
  /// Uso: Transiciones importantes que captan atención
  static const Curve emphasized = Cubic(0.2, 0.0, 0, 1.0);

  /// Emphasized Decelerate: Entrada suave (elementos apareciendo)
  /// Uso: Widgets entrando en pantalla, modals, dropdowns
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Emphasized Accelerate: Salida rápida (elementos desapareciendo)
  /// Uso: Widgets saliendo de pantalla, dismiss animations
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Standard: Curva estándar para transiciones sutiles
  /// Uso: Micro-interacciones, hover states, subtle changes
  static const Curve standard = Cubic(0.2, 0.0, 0, 1.0);

  /// Standard Decelerate: Desaceleración suave
  /// Uso: Elementos que se detienen gradualmente
  static const Curve standardDecelerate = Cubic(0, 0, 0, 1);

  /// Standard Accelerate: Aceleración gradual
  /// Uso: Elementos iniciando movimiento
  static const Curve standardAccelerate = Cubic(0.3, 0, 1, 1);

  // ===== CONFIGURACIONES COMPUESTAS (USO COMÚN) =====

  /// Fade In: Aparición suave estándar
  static const fadeIn = (
    duration: medium2, // 300ms
    curve: emphasizedDecelerate,
  );

  /// Fade Out: Desaparición rápida
  static const fadeOut = (
    duration: short4, // 200ms
    curve: emphasizedAccelerate,
  );

  /// Slide Up: Deslizamiento desde abajo (modals, bottom sheets)
  static const slideUp = (
    duration: medium3, // 350ms
    curve: emphasized,
  );

  /// Slide Down: Deslizamiento hacia abajo (notificaciones)
  static const slideDown = (
    duration: medium2, // 300ms
    curve: emphasized,
  );

  /// Scale Up: Crecimiento suave (dialogs, popovers)
  static const scaleUp = (
    duration: medium1, // 250ms
    curve: emphasizedDecelerate,
  );

  /// Scale Down: Encogimiento rápido (dismiss)
  static const scaleDown = (
    duration: short4, // 200ms
    curve: emphasizedAccelerate,
  );

  /// List Transition: Transición de estado de listas (empty ↔ content)
  static const listTransition = (
    duration: medium2, // 300ms
    curve: emphasizedDecelerate,
  );

  /// State Switch: Cambio de estado general (loading ↔ success)
  static const stateSwitch = (
    duration: medium1, // 250ms
    curve: standard,
  );

  /// Item Deletion: Animación de eliminación de items
  static const itemDeletion = (
    duration: short3, // 150ms
    curve: emphasizedAccelerate,
  );

  /// Item Insertion: Animación de inserción de items
  static const itemInsertion = (
    duration: medium1, // 250ms
    curve: emphasizedDecelerate,
  );

  /// Notification: Aparición de notificaciones (desde arriba)
  static const notification = (
    duration: medium4, // 400ms
    curve: emphasizedDecelerate,
  );

  /// Modal: Aparición de modales/dialogs
  static const modal = (
    duration: medium1, // 250ms
    curve: emphasizedDecelerate,
  );

  /// Progress: Animación de progreso (loop infinito)
  static const progress = (
    duration: extraLong2, // 1000ms
    curve: Curves.easeInOut,
  );
}
