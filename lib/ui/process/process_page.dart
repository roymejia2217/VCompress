import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:vcompressor/core/core.dart';
import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/settings_provider.dart';
import 'package:vcompressor/utils/format_utils.dart';
import 'package:vcompressor/ui/widgets/app_app_bar.dart';
import 'package:vcompressor/ui/widgets/app_video_player.dart';
import 'package:vcompressor/ui/widgets/video_list_items/video_list_items.dart';
import 'package:vcompressor/core/services/operation_cancellation_service.dart';

class ProcessPage extends ConsumerStatefulWidget {
  const ProcessPage({super.key});

  @override
  ConsumerState<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends ConsumerState<ProcessPage> {
  static const double _estimatedItemHeight = 72.0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};
  int _currentTaskIndex = 0;
  bool _done = false;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    AppLogger.performanceStart('video_processing');

    // Ejecuta inicio de procesamiento fuera del build cycle usando microtask
    Future.microtask(() {
      if (mounted) {
        _start();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    AppLogger.performanceEnd('video_processing');
    super.dispose();
  }

  Future<void> _start() async {
    if (!mounted || _cancelled) return;

    try {
      // LINUX FIX: Esperar a que saveDirProvider se resuelva completamente
      final saveDir = await ref.read(saveDirProvider.future);

      if (!mounted || _cancelled) return;
      await ref
          .read(tasksProvider.notifier)
          .compressAll(
            saveDir: saveDir,
            onProgress: (currentIndex, total, percent, fileName) {
              if (!mounted || _cancelled) return;

              // Solo actualizar índice actual (para AppBar subtitle)
              if (_currentTaskIndex != currentIndex) {
                setState(() {
                  _currentTaskIndex = currentIndex;
                });
                // Usar microtask para asegurar que el frame se ha renderizado si es necesario
                // o simplemente llamar al scroll.
                // Al ser un cambio de estado, el build sucederá, pero _scrollToIndex
                // maneja la lógica de items no renderizados.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _scrollToIndex(currentIndex);
                });
              }

              // Performance monitoring
              AppLogger.performanceEvent(
                'progress_update',
                data: {
                  'current_index': currentIndex,
                  'total': total,
                  'percent': percent,
                  'file_name': fileName,
                },
              );
            },
          );

      if (!mounted || _cancelled) return;

      setState(() {
        _done = true;
      });

      // M3: Haptic feedback para success
      await HapticFeedback.mediumImpact();
    } catch (e) {
      final appError = AppError.fromException(e, StackTrace.current);
      debugPrint('Error en el procesamiento: ${appError.message}');
      if (mounted && !_cancelled) {
        setState(() {
          _done = true;
          // _statusMessage = appError.userMessage;
        });

        // M3: Haptic feedback para error (más fuerte)
        await HapticFeedback.heavyImpact();
      }
    }
  }

  /// Desplaza la lista de manera inteligente para mantener visible el item actual
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    final tasks = ref.read(tasksProvider);
    if (index < 0 || index >= tasks.length) return;

    final taskId = tasks[index].id.toString();
    final key = _itemKeys[taskId];
    final context = key?.currentContext;

    // Caso 1: El item ya está renderizado en el árbol de widgets
    if (context != null) {
      // Scrollable.ensureVisible es "inteligente":
      // - Si el item ya es visible, no hace nada (cumple el requisito de no deslizar si ya se ve).
      // - Si no es visible, hace el scroll mínimo necesario.
      Scrollable.ensureVisible(
        context,
        duration: AppAnimations.long2,
        curve: AppAnimations.emphasized,
        alignment: 0.5, // Intenta centrarlo si es necesario moverlo, mejor visibilidad
        alignmentPolicy:
            ScrollPositionAlignmentPolicy.explicit, // Forza la alineación si mueve
      );
      return;
    }

    // Caso 2: El item NO está renderizado (está fuera del viewport/cache)
    // Calculamos una posición estimada basada en el promedio de altura de los items visibles
    final double avgHeight = _getAverageItemHeight();
    double targetOffset = index * avgHeight;

    // Aseguramos no pasarnos del máximo scroll posible
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (targetOffset > maxScroll) {
      targetOffset = maxScroll;
    }

    // Evitamos scroll innecesario si ya estamos en el fondo y el target es mayor
    // (aunque la validación de maxScroll ya ayuda, esto es explícito)
    if (_scrollController.offset >= maxScroll && targetOffset >= maxScroll) {
      return;
    }

    _scrollController.animateTo(
      targetOffset,
      duration: AppAnimations.long2,
      curve: AppAnimations.emphasized,
    );
  }

  /// Calcula la altura promedio de los items actualmente renderizados
  double _getAverageItemHeight() {
    double totalHeight = 0;
    int count = 0;

    for (final key in _itemKeys.values) {
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          totalHeight += renderBox.size.height;
          count++;
        }
      }
    }

    // Si tenemos items renderizados, devolvemos el promedio real
    if (count > 0) {
      return totalHeight / count;
    }

    // Fallback de seguridad solo si no hay NADA renderizado (raro en este punto)
    // Usamos una estimación basada en Material Design 3 Standard List Item height
    return _estimatedItemHeight;
  }

  /// Cancela el procesamiento de video actual mostrando diálogo de confirmación
  void _cancel() {
    setState(() {
      _cancelled = true;
    });

    // Muestra diálogo de confirmación usando servicio de cancelación
    OperationCancellationService.cancelVideoProcessing(
      context: context,
      onCancel: () {
        // Registra evento de cancelación en monitor de rendimiento
        AppLogger.performanceEvent('processing_cancelled');

        // Delega cancelación al controlador de tareas
        ref.read(tasksProvider.notifier).cancelCompression();

        // Navegar después de la cancelación
        Navigator.of(context).pop();
      },
    );
  }

  /// Reproduce el video procesado con la configuración de playback apropiada
  Future<void> _showVideoPlayer(VideoTask task) async {
    // Determina contexto de reproducción según configuración de la tarea
    final playbackContext = _determinePlaybackContext(task);

    await AppVideoPlayer.playVideoTask(
      context,
      task: task,
      config: VideoPlayerConfig.results.copyWith(
        playbackContext: playbackContext,
      ),
    );
  }

  /// Selecciona contexto de reproducción: processed si se reemplazó el original, processed en caso contrario
  VideoPlaybackContext _determinePlaybackContext(VideoTask task) {
    // Si replaceOriginalFile está activado, el video final está en la ubicación original
    if (task.settings.editSettings.replaceOriginalFile) {
      // Usar 'original' para acceder a originalPath (que contiene el video reemplazado)
      // en lugar de inputPath (que puede haber sido eliminado del caché)
      return VideoPlaybackContext.original;
    }

    // Si no se reemplaza el archivo original, usar el video procesado normal
    return VideoPlaybackContext
        .processed; // outputPath apunta al directorio de destino
  }

  /// Comparte el video comprimido mediante la interfaz nativa del sistema
  Future<void> _shareVideo(VideoTask task) async {
    try {
      // Obtener ruta del video comprimido (no hardcoded)
      final videoPath = task.outputPath;

      if (videoPath == null || videoPath.isEmpty) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context)!;
        final errorColor = Theme.of(context).colorScheme.error;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.compressedVideoPathNotFound),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      final file = File(videoPath);
      // Captura localizaciones antes del await para evitar uso de BuildContext asíncrono
      final l10n = AppLocalizations.of(context)!;

      if (await file.exists()) {
        // Comparte video como XFile con texto descriptivo
        await SharePlus.instance.share(
          ShareParams(
            text: l10n.compressedVideoShare(task.fileName),
            subject: l10n.compressedVideoSubject(AppConstants.appName),
            files: [
              XFile(videoPath),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final appError = AppError.fileNotFound(videoPath);
        final errorColor = Theme.of(context).colorScheme.error;
        messenger.showSnackBar(
          SnackBar(
            content: Text(appError.userMessage),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final appError = AppError.fromException(e, StackTrace.current);
      final l10n = AppLocalizations.of(context)!;
      final errorColor = Theme.of(context).colorScheme.error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareError(appError.userMessage)),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    // Calcula espacio total ahorrado sumando diferencias entre tamaños originales y comprimidos
    String? spaceSaved;
    if (_done) {
      final completedTasks = tasks.where((t) => t.compressedSizeBytes != null);
      int totalSaved = 0;
      for (final task in completedTasks) {
        if (task.originalSizeBytes != null &&
            task.compressedSizeBytes != null) {
          totalSaved += task.originalSizeBytes! - task.compressedSizeBytes!;
        }
      }
      if (totalSaved > 0) {
        spaceSaved = FormatUtils.formatBytes(totalSaved);
      }
    }

    return PopScope(
      canPop: _done, // Solo puede volver si está done (resultados)
      onPopInvokedWithResult: (didPop, result) {
        // Si está procesando y se intenta volver, cancelar
        if (!_done && !didPop) {
          _cancel();
        }
      },
      child: Scaffold(
        appBar: _done
            ? AppAppBar.withReturn(
                title: AppLocalizations.of(context)!.results,
                subtitle: spaceSaved != null
                    ? AppLocalizations.of(context)!.spaceFreed(spaceSaved)
                    : AppLocalizations.of(context)!.videosCompressed(
                        tasks
                            .where((t) => t.compressedSizeBytes != null)
                            .length,
                      ),
                // onBackPressed no definido = Navigator.pop() default
              )
            : AppAppBar.withReturn(
                title: AppLocalizations.of(context)!.compressing,
                subtitle: _buildSmartProgressSubtitle(context, tasks),
                onBackPressed:
                    _cancel, // Acción custom: cancelar en lugar de pop
              ),
        body: _done ? _buildResultsView(tasks) : _buildProcessingView(tasks),
      ),
    );
  }

  /// Construye el subtítulo de progreso inteligente ignorando tareas canceladas
  String _buildSmartProgressSubtitle(BuildContext context, List<VideoTask> tasks) {
    // Total de tareas activas (no canceladas)
    final activeTotal = tasks.where((t) => !t.isCancelled).length;
    
    // Posición actual relativa solo a tareas activas
    // Filtramos las tareas hasta el índice actual (_currentTaskIndex) que no estén canceladas
    final activeCurrent = tasks
        .take(_currentTaskIndex + 1) // Tomar hasta la tarea actual (inclusive)
        .where((t) => !t.isCancelled)
        .length;

    // Si no hay tareas activas (ej: todas canceladas), mostrar estado genérico o 0/0
    if (activeTotal == 0) {
      return AppLocalizations.of(context)!.videoProgress(0, 0);
    }

    // Asegurar que activeCurrent no sea 0 si hay activeTotal (mínimo 1 si estamos procesando)
    final displayCurrent = activeCurrent > 0 ? activeCurrent : 1;

    return AppLocalizations.of(context)!.videoProgress(
      displayCurrent,
      activeTotal,
    );
  }

  /// Construye lista de tareas mostrando progreso de cada video durante compresión
  Widget _buildProcessingView(List<VideoTask> tasks) {
    return Padding(
      padding: AppPadding.m,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: tasks.length,
        addRepaintBoundaries: true, // Aísla repaints por elemento
        itemBuilder: (context, index) {
          final task = tasks[index];

          // Asignar una GlobalKey única para cada tarea
          // Usamos putIfAbsent para mantener la misma key a través de rebuilds
          final key = _itemKeys.putIfAbsent(
            task.id.toString(),
            () => GlobalKey(debugLabel: 'task_${task.id}'),
          );

          // Widget optimizado que solo se reconstruye cuando cambia su tarea específica
          return VideoTaskListItem(
            key: key, // Usamos la GlobalKey para el tracking de scroll
            taskId: task.id.toString(),
            onCancelPressed: !_cancelled
                ? () => ref.read(tasksProvider.notifier).cancelTask(task.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildResultsView(List<VideoTask> tasks) {
    final List<VideoTask> completedTasks = tasks
        .where((task) => task.compressedSizeBytes != null)
        .toList();

    // Obtiene padding inferior del sistema para ajustar interfaz
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          bottomPadding + AppSpacing.m,
        ),
        child: Column(
          children: [
            // Lista de resultados (scrollable con Expanded)
            Expanded(
              child: ListView.builder(
                itemCount: completedTasks.length,
                padding: EdgeInsets.zero,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  final task = completedTasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: AppVideoListItem.results(
                      key: ValueKey(task.id),
                      taskId: task.id.toString(),
                      onSharePressed: () => _shareVideo(task),
                      onTap: () => _showVideoPlayer(task),
                    ),
                  );
                },
              ),
            ),

            // Spacing antes del botón
            const SizedBox(height: AppSpacing.m),

            // Navigation button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: Text(AppLocalizations.of(context)!.backToHome),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
