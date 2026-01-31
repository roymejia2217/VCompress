import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vcompressor/core/constants/app_constants.dart';
import 'package:vcompressor/services/permissions_service.dart';
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/ui/widgets/app_icons.dart';
import 'package:vcompressor/data/services/media_store_uri_resolver.dart';
import 'package:vcompressor/l10n/app_localizations.dart';

import 'package:vcompressor/models/video_task.dart';
import 'package:vcompressor/providers/tasks_provider.dart';
import 'package:vcompressor/providers/loading_provider.dart';

import 'package:vcompressor/ui/widgets/app_app_bar.dart';
import 'package:vcompressor/ui/widgets/video_list_items/video_list_items.dart';
import 'package:vcompressor/ui/widgets/batch_config_decision_modal.dart';

import 'package:vcompressor/ui/widgets/video_config_modal.dart';
import 'package:vcompressor/core/constants/app_design_tokens.dart';
import 'package:vcompressor/models/models.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isSelectionMode = false;
  final Set<int> _selectedTaskIds = {};

  // Métodos auxiliares para obtener textos localizados
  String _getEmptyStateMessage(BuildContext context) =>
      AppLocalizations.of(context)!.noVideosSelected;
  String _getSelectVideosText(BuildContext context) =>
      AppLocalizations.of(context)!.import;
  String _getProcessingText(BuildContext context) =>
      AppLocalizations.of(context)!.processing;
  String _getCompressText(BuildContext context) =>
      AppLocalizations.of(context)!.compress;

  /// Construye la lista de videos manejando estados: vacío, cargando, con contenido
  Widget _buildVideoListContent(
    BuildContext context,
    List<VideoTask> tasks,
    LoadingState loadingState,
    WidgetRef ref,
  ) {
    // Estado 1: Cargando y lista vacía
    if (loadingState.isAddingVideos && tasks.isEmpty) {
      return _buildLoadingState(context, ref);
    }

    // Estado 2: Lista vacía sin carga
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Estado 3: Lista con videos
    return _buildVideoList(context, tasks, ref);
  }

  /// Construye estado de carga minimalista: barra de progreso + contador x/y
  Widget _buildLoadingState(BuildContext context, WidgetRef ref) {
    final currentProgress = ref.watch(
      loadingProvider.select((state) => state.currentProgress),
    );
    final totalProgress = ref.watch(
      loadingProvider.select((state) => state.totalProgress),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressValue = totalProgress > 0
        ? currentProgress / totalProgress
        : 0.0;

    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 4,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '$currentProgress/$totalProgress',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye pantalla de estado vacío con icono y mensaje
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    // [MIGRADO] Usar constantes estáticas en lugar de AppThemeVars deprecated

    return Center(
      key: const ValueKey(
        'empty',
      ), // Key necesaria para transiciones de AnimatedSwitcher
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            icon: PhosphorIconsFill.video,
            config: const AppIconConfig(size: 64),
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            _getEmptyStateMessage(context),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye lista scrollable de videos con padding
  Widget _buildVideoList(
    BuildContext context,
    List<VideoTask> tasks,
    WidgetRef ref,
  ) {
    return ListView.builder(
      key: const ValueKey(
        'content',
      ), // Key necesaria para transiciones de AnimatedSwitcher
      padding: AppPadding.m,
      itemCount: tasks.length,
      addRepaintBoundaries: true, // Aísla repaints por elemento
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          key: ValueKey(task.id), // Key única para identificar cada tarea
          padding: const EdgeInsets.only(bottom: AppSpacing.s),
          child: _buildVideoItem(context, task, ref),
        );
      },
    );
  }

  /// Construye elemento de video con soporte para selección y tap
  Widget _buildVideoItem(BuildContext context, VideoTask task, WidgetRef ref) {
    final isSelected = _selectedTaskIds.contains(task.id);

    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _toggleSelection(task.id);
          });
        }
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(task.id);
        } else {
          _showConfig(context, ref, task);
        }
      },
      child: AppVideoListItem(
        taskId: task.id.toString(),
        config: const AppVideoListItemConfig.standard(),
        onSettingsPressed: () => _showConfig(context, ref, task),
        isSelected: isSelected,
      ),
    );
  }

  void _toggleSelection(int taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }

      if (_selectedTaskIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _disableSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTaskIds.clear();
    });
  }

  void _deleteSelectedItems() {
    final taskNotifier = ref.read(tasksProvider.notifier);
    for (final taskId in _selectedTaskIds) {
      taskNotifier.removeTask(taskId);
    }
    _disableSelectionMode();
  }

  void _toggleSelectAll(List<VideoTask> tasks) {
    setState(() {
      if (_selectedTaskIds.length == tasks.length) {
        _selectedTaskIds.clear();
      } else {
        _selectedTaskIds.addAll(tasks.map((task) => task.id));
      }
    });
  }

  /// Construye botón para seleccionar archivos de video mediante FilePicker
  Widget _buildSelectVideosButton(LoadingState loadingState) {
    return FilledButton.tonal(
      onPressed: loadingState.isAddingVideos
          ? null
          : () async {
              try {
                // Validar permisos antes de abrir FilePicker
                final hasPermission = await _ensurePermissions();
                if (!hasPermission) {
                  return; // Permanecer en home_page si usuario cancela
                }

                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: AppConstants.supportedVideoExtensions
                      .map((ext) => ext.substring(1))
                      .toList(),
                );
                if (result != null && result.files.isNotEmpty) {
                  final fileData = <Map<String, String?>>[];

                  // [SOLID] Procesar cada archivo individualmente para obtener rutas originales
                  for (final file in result.files) {
                    if (file.path != null) {
                      String originalPath = file.path!;

                      // [DEBUG] Log estructurado para file processing
                      AppLogger.debug({
                        'event': 'file_processing_started',
                        'file_path': file.path,
                        'file_identifier': file.identifier,
                        'platform_android': Platform.isAndroid,
                      });

                      // [MEDIASTORE] Si hay URI de MediaStore, intentar obtener la ruta original real
                      if (file.identifier != null && Platform.isAndroid) {
                        try {
                          // [DEBUG] Log para URI resolution
                          AppLogger.debug({
                            'event': 'uri_resolution_attempt',
                            'uri': file.identifier,
                          });

                          const uriResolver = MediaStoreUriResolver();
                          final pathResult = await uriResolver
                              .resolvePathFromUri(file.identifier!);

                          // [DEBUG] Log resultado de URI resolution
                          AppLogger.debug({
                            'event': 'uri_resolution_result',
                            'is_success': pathResult.isSuccess,
                            'resolved_path': pathResult.data,
                            'error_message': pathResult.error?.message,
                          });

                          if (pathResult.isSuccess && pathResult.data != null) {
                            originalPath = pathResult.data!;
                            // [INFO] URI resuelto exitosamente
                            AppLogger.info({
                              'event': 'uri_resolution_success',
                              'original_path': originalPath,
                              'temporal_path': file.path,
                            });
                          } else {
                            // [WARNING] Fallback a ruta temporal
                            AppLogger.warning({
                              'event': 'uri_resolution_fallback',
                              'reason': 'resolution_failed',
                            });
                          }
                        } catch (e) {
                          // [ERROR] Excepción en URI resolution
                          AppLogger.error({
                            'event': 'uri_resolution_exception',
                            'uri': file.identifier,
                            'error': e.toString(),
                          });
                          // Usar ruta temporal como fallback
                        }
                      } else {
                        // [DEBUG] Skip URI resolution
                        AppLogger.debug({
                          'event': 'uri_resolution_skipped',
                          'reason': file.identifier == null
                              ? 'no_uri'
                              : 'not_android',
                        });
                      }

                      fileData.add({
                        'path': file.path!, // Ruta temporal para procesamiento
                        'originalPath': originalPath, // Ruta original real
                        'uri': file.identifier, // URI de MediaStore en Android
                      });
                    }
                  }

                  await ref
                      .read(tasksProvider.notifier)
                      .addFilesWithUris(
                        fileData,
                        onInvalidFiles: (invalidFiles) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!
                                    .invalidFilesCount(invalidFiles.length),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              action: SnackBarAction(
                                label: AppLocalizations.of(context)!.view,
                                onPressed: () {
                                  AppLogger.debug(
                                    'Archivos rechazados: ${invalidFiles.join(", ")}',
                                    tag: 'HomePage',
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );

                  // [SEGURIDAD] BuildContext async safety: verificar mounted después de await
                  if (!mounted) return;

                  // [BATCH] Mostrar modal de decisión si > 1 video
                  final currentTasks = ref.read(tasksProvider);

                  if (currentTasks.length > 1) {
                    await _showBatchConfigDecision(
                      context,
                      currentTasks.length,
                    );
                  }
                }
              } catch (e) {
                // [CRÍTICO] Manejo de errores para evitar crashes en release
                AppLogger.error({
                  'event': 'file_picker_crash',
                  'error': e.toString(),
                  'stack_trace': e is Error ? e.stackTrace?.toString() : null,
                });

                // [SEGURIDAD] BuildContext async safety
                if (!mounted) return;

                // Mostrar error al usuario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error al seleccionar archivos: ${e.toString()}',
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingState.isAddingVideos
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(PhosphorIconsFill.filePlus),
          const SizedBox(width: 8),
          Text(
            loadingState.isAddingVideos
                ? _getProcessingText(context)
                : _getSelectVideosText(context),
          ),
        ],
      ),
    );
  }

  /// Construye botón de compresión que navega a la pantalla de procesamiento
  Widget _buildCompressButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.push('/process'),
      icon: const Icon(PhosphorIconsFill.playCircle),
      label: Text(_getCompressText(context)),
    );
  }

  /// Construye fila de botones: Importar (siempre) y Comprimir (solo si hay videos)
  Widget _buildBottomButtons(LoadingState loadingState, List<VideoTask> tasks) {
    return Padding(
      padding: AppPadding.m,
      child: Row(
        children: [
          // Botón Importar (OutlinedButton)
          Expanded(child: _buildSelectVideosButton(loadingState)),
          const SizedBox(width: AppSpacing.s),
          // Botón Comprimir (FilledButton) - solo si hay videos
          if (tasks.isNotEmpty) Expanded(child: _buildCompressButton(context)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    List<VideoTask> tasks,
  ) {
    if (_isSelectionMode) {
      final selectedCount = _selectedTaskIds.length;
      final allSelected = selectedCount == tasks.length;

      return AppAppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: _disableSelectionMode,
          tooltip: AppLocalizations.of(context)!.cancel,
        ),
        title: AppLocalizations.of(context)!.selected(selectedCount),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.trash),
            onPressed: selectedCount > 0 ? _deleteSelectedItems : null,
            tooltip: AppLocalizations.of(context)!.delete,
          ),
          Checkbox(
            value: allSelected,
            onChanged: (value) => _toggleSelectAll(tasks),
          ),
        ],
      );
    }

    return AppAppBar.home(
      title: AppLocalizations.of(context)!.appName,
      subtitle: AppLocalizations.of(context)!.appDescription,
      actions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.gearSix),
          onPressed: () => context.push('/settings'),
          tooltip: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Monitorear performance del build
    AppLogger.performanceEvent(
      'home_page_build',
      data: {'timestamp': DateTime.now().toIso8601String()},
    );

    final tasks = ref.watch(tasksProvider);
    final loadingState = ref.watch(loadingProvider);
    // [MIGRADO] Usar constantes estáticas en lugar de AppThemeVars deprecated

    return Scaffold(
      appBar: _buildAppBar(context, tasks),
      body: SafeArea(
        top: false, // AppBar ya maneja el área superior
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildVideoListContent(
                  context,
                  tasks,
                  loadingState,
                  ref,
                ),
              ),
            ),
            // Botones en la parte inferior
            _buildBottomButtons(loadingState, tasks),
          ],
        ),
      ),
    );
  }

  Future<bool> _ensurePermissions() async {
    if (kIsWeb) return true;

    try {
      // Solicita permisos de almacenamiento usando el servicio centralizado
      final hasPermission =
          await PermissionsService.requestStoragePermissions();

      if (!hasPermission) {
        if (!mounted) return false;

        // Mostrar diálogo de permisos denegados
        final shouldOpenSettings = await _showPermissionDeniedDialog();
        if (shouldOpenSettings) {
          await PermissionsService.openSettings();
          // Verificar permisos nuevamente después de volver de settings
          return await PermissionsService.requestStoragePermissions();
        }
        return false; // Usuario canceló
      }
      return true; // Permisos otorgados
    } catch (e) {
      // [SEGURIDAD] BuildContext async safety: verificar mounted después de await
      if (!mounted) return false;

      // Mostrar error simple
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.permissionRequestError(e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return false;
    }
  }

  /// Muestra diálogo de permisos denegados
  Future<bool> _showPermissionDeniedDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.permissionRequired),
            content: Text(
              AppLocalizations.of(context)!.permissionDeniedMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)!.openSettings),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showConfig(
    BuildContext context,
    WidgetRef ref,
    VideoTask task,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VideoConfigModal(task: task),
    );
  }

  /// Muestra modal para elegir configuración de lote (aplicar a todos o individual)
  Future<void> _showBatchConfigDecision(
    BuildContext context,
    int videoCount,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BatchConfigDecisionModal(videoCount: videoCount),
    );
  }
}
