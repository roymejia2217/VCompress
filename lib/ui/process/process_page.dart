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
  final ValueNotifier<String?> _timeEstimateNotifier = ValueNotifier(null);
  
  // FIX: Ya no necesitamos _currentTaskIndex local, usamos el provider
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
    _timeEstimateNotifier.dispose();
    AppLogger.performanceEnd('video_processing');
    super.dispose();
  }

  Future<void> _start() async {
    if (!mounted || _cancelled) return;

    try {
      // LINUX FIX: Obtener directorio de guardado del estado actual
      final saveDirState = ref.read(saveDirProvider);
      final saveDir = saveDirState.valueOrNull;

      if (saveDir == null) {
        throw Exception('Directorio de guardado no inicializado');
      }

      if (!mounted || _cancelled) return;
      
      // CRITICAL FIX: Llamada optimizada sin callbacks de alta frecuencia
      await ref
          .read(tasksProvider.notifier)
          .compressAll(
            saveDir: saveDir,
            onTimeEstimate: (duration) {
              if (!mounted) return;
              if (duration == null) {
                _timeEstimateNotifier.value = null;
                return;
              }
              final l10n = AppLocalizations.of(context)!;
              _timeEstimateNotifier.value = FormatUtils.formatTimeEstimate(duration, l10n);
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
      // - Si el item ya es visible, no hace nada.
      // - Si no es visible, hace el scroll mínimo necesario.
      Scrollable.ensureVisible(
        context,
        duration: AppAnimations.long2,
        curve: AppAnimations.emphasized,
        alignment: 0.5,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
      return;
    }

    // Caso 2: El item NO está renderizado (está fuera del viewport/cache)
    final double avgHeight = _getAverageItemHeight();
    double targetOffset = index * avgHeight;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (targetOffset > maxScroll) {
      targetOffset = maxScroll;
    }

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

    if (count > 0) {
      return totalHeight / count;
    }

    return _estimatedItemHeight;
  }

  /// Cancela el procesamiento de video actual mostrando diálogo de confirmación
  void _cancel() {
    setState(() {
      _cancelled = true;
    });

    OperationCancellationService.cancelVideoProcessing(
      context: context,
      onCancel: () {
        AppLogger.performanceEvent('processing_cancelled');
        ref.read(tasksProvider.notifier).cancelCompression();
        Navigator.of(context).pop();
      },
    );
  }

  /// Reproduce el video procesado
  Future<void> _showVideoPlayer(VideoTask task) async {
    final playbackContext = _determinePlaybackContext(task);

    await AppVideoPlayer.playVideoTask(
      context,
      task: task,
      config: VideoPlayerConfig.results.copyWith(
        playbackContext: playbackContext,
      ),
    );
  }

  VideoPlaybackContext _determinePlaybackContext(VideoTask task) {
    if (task.settings.editSettings.replaceOriginalFile) {
      return VideoPlaybackContext.original;
    }
    return VideoPlaybackContext.processed;
  }

  /// Comparte el video comprimido
  Future<void> _shareVideo(VideoTask task) async {
    try {
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
      final l10n = AppLocalizations.of(context)!;

      if (await file.exists()) {
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
    
    // CRITICAL FIX: Escuchar cambios en el índice de procesamiento
    // para hacer scroll automático SOLO cuando cambia de video.
    // listen NO reconstruye el widget, solo ejecuta el callback.
    ref.listen(currentProcessingIndexProvider, (prev, next) {
      if (prev != next) {
         // Usar addPostFrameCallback para asegurar que el frame se ha renderizado
         WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToIndex(next);
         });
      }
    });

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
      canPop: _done, 
      onPopInvokedWithResult: (didPop, result) {
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
              )
            : AppAppBar.withReturn(
                title: AppLocalizations.of(context)!.compressing,
                // Leemos el índice del provider para el subtítulo
                // Usamos ValueListenableBuilder para actualizar la estimación sin rebuilds masivos
                subtitleWidget: ValueListenableBuilder<String?>(
                  valueListenable: _timeEstimateNotifier,
                  builder: (context, timeEstimate, _) {
                    final baseSubtitle = _buildSmartProgressSubtitle(
                      context, 
                      tasks, 
                      ref.watch(currentProcessingIndexProvider)
                    );
                    
                    if (timeEstimate != null) {
                      return Text('$baseSubtitle • $timeEstimate', style: Theme.of(context).textTheme.bodyMedium);
                    }
                    return Text(baseSubtitle, style: Theme.of(context).textTheme.bodyMedium);
                  },
                ),
                onBackPressed: _cancel,
              ),
        body: _done ? _buildResultsView(tasks) : _buildProcessingView(tasks),
      ),
    );
  }

  /// Construye el subtítulo de progreso inteligente
  String _buildSmartProgressSubtitle(
    BuildContext context, 
    List<VideoTask> tasks,
    int currentIndex,
  ) {
    final activeTotal = tasks.where((t) => !t.isCancelled).length;
    
    final activeCurrent = tasks
        .take(currentIndex + 1)
        .where((t) => !t.isCancelled)
        .length;

    if (activeTotal == 0) {
      return AppLocalizations.of(context)!.videoProgress(0, 0);
    }

    final displayCurrent = activeCurrent > 0 ? activeCurrent : 1;

    return AppLocalizations.of(context)!.videoProgress(
      displayCurrent,
      activeTotal,
    );
  }

  Widget _buildProcessingView(List<VideoTask> tasks) {
    return Padding(
      padding: AppPadding.m,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: tasks.length,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          final task = tasks[index];

          final key = _itemKeys.putIfAbsent(
            task.id.toString(),
            () => GlobalKey(debugLabel: 'task_${task.id}'),
          );

          return VideoTaskListItem(
            key: key,
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

            const SizedBox(height: AppSpacing.m),

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