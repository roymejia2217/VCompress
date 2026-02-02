import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider de alta frecuencia para el progreso de compresión de tareas individuales.
/// 
/// Arquitectura:
/// Separamos el estado de "Progreso" (que cambia 100 veces por segundo) 
/// del estado de la "Lista de Tareas" (que cambia poco).
/// 
/// Esto evita que toda la UI se reconstruya con cada frame de progreso.
/// 
/// Uso:
/// - TasksController actualiza este provider.
/// - VideoTaskListItem escucha este provider.
final taskProgressProvider = StateProvider.family<double, int>((ref, taskId) {
  return 0.0;
});
