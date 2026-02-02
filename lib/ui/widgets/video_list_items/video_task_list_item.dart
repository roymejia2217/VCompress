import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/progress_provider.dart'; // Import para progreso optimizado
import 'package:vcompressor/ui/widgets/video_list_items/app_video_list_item.dart';

/// Widget optimizado para lista de procesamiento
/// Riverpod select: Solo rebuild cuando ESTE task cambia su estado (no progreso)
/// ProgressProvider: Rebuild cuando progreso cambia (alta frecuencia, aislado)
class VideoTaskListItem extends ConsumerWidget {
  final String taskId;
  final VoidCallback? onCancelPressed;

  const VideoTaskListItem({
    super.key,
    required this.taskId,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Datos estáticos/estado (Baja frecuencia)
    // Riverpod select optimization: Solo rebuild cuando ESTE task cambia de estado
    // YA NO rebuild cuando cambia el progreso, porque 'progress' en la lista principal
    // no se actualiza durante la compresión continua.
    final task = ref.watch(
      tasksProvider.select(
        (tasks) => tasks.firstWhere(
          (t) => t.id.toString() == taskId,
          orElse: () => tasks.first, // Fallback
        ),
      ),
    );

    // 2. Progreso en tiempo real (Alta frecuencia)
    // Este provider se actualiza 100 veces por segundo sin afectar al resto de la UI.
    // Usamos int.tryParse para seguridad, aunque taskId debería ser numérico.
    final int numericId = int.tryParse(taskId) ?? -1;
    final liveProgress = ref.watch(taskProgressProvider(numericId));

    // RepaintBoundary: Aísla repaints de animación progress
    return RepaintBoundary(
      child: AppVideoListItem.process(
        taskId: taskId,
        // onCancelPressed solo activo si está procesando
        onCancelPressed: task.isProcessing ? onCancelPressed : null,
        // Inyectamos el progreso "live" que viene del side-channel
        progressOverride: liveProgress > 0 ? liveProgress : null,
      ),
    );
  }
}