import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vcompressor/core/error/app_error.dart';

/// Estado de carga para diferentes operaciones
class LoadingState {
  final bool isAddingVideos;
  final bool isProcessingVideos;
  final String? currentMessage;
  final int currentProgress;
  final int totalProgress;
  final List<String> loadingFileNames; // DRY: nombres de archivos en carga

  const LoadingState({
    this.isAddingVideos = false,
    this.isProcessingVideos = false,
    this.currentMessage,
    this.currentProgress = 0,
    this.totalProgress = 0,
    this.loadingFileNames = const [], // SOLID: inyección de dependencias
  });

  LoadingState copyWith({
    bool? isAddingVideos,
    bool? isProcessingVideos,
    String? currentMessage,
    int? currentProgress,
    int? totalProgress,
    List<String>? loadingFileNames,
  }) {
    return LoadingState(
      isAddingVideos: isAddingVideos ?? this.isAddingVideos,
      isProcessingVideos: isProcessingVideos ?? this.isProcessingVideos,
      currentMessage: currentMessage ?? this.currentMessage,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      loadingFileNames: loadingFileNames ?? this.loadingFileNames,
    );
  }

  /// Verifica si hay alguna operación de carga activa
  bool get isLoading => isAddingVideos || isProcessingVideos;

  /// Obtiene el progreso como porcentaje (0.0 - 1.0)
  double get progressPercentage {
    if (totalProgress == 0) return 0.0;
    return currentProgress / totalProgress;
  }

  /// Obtiene el mensaje de carga apropiado
  String get loadingMessage {
    if (currentMessage != null) return currentMessage!;

    if (isAddingVideos) return 'Agregando videos...';
    if (isProcessingVideos) return 'Procesando videos...';

    return 'Procesando...';
  }
}

/// Provider para el estado de carga
final loadingProvider = StateNotifierProvider<LoadingController, LoadingState>((
  ref,
) {
  return LoadingController();
});

/// Controlador para manejar el estado de carga
class LoadingController extends StateNotifier<LoadingState> {
  LoadingController() : super(const LoadingState());

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeUpdate(LoadingState Function() updater) {
    if (_disposed || !mounted) return;
    try {
      state = updater();
    } catch (e) {
      final appError = AppError.fromException(e, StackTrace.current);
      // Ignore state update errors if the controller is disposed
      debugPrint(
        'LoadingController: Estado no actualizado (disposed): ${appError.message}',
      );
    }
  }

  /// Inicia la carga de agregar videos
  /// DRY: configura estado inicial y timeout automático
  void startAddingVideos({List<String>? fileNames}) {
    _safeUpdate(
      () => state.copyWith(
        isAddingVideos: true,
        currentMessage: 'Analizando videos...',
        currentProgress: 0,
        totalProgress: 0,
        loadingFileNames: fileNames ?? [], // SOLID: inyección de dependencias
      ),
    );

    // Timeout escalable: 30s + 1s por archivo (evita timeout con muchos archivos)
    final timeoutSeconds = 30 + (fileNames?.length ?? 0);
    Future.delayed(Duration(seconds: timeoutSeconds), () {
      if (mounted && state.isAddingVideos) {
        debugPrint(
          'LoadingController: Timeout automático (${timeoutSeconds}s) - reseteando estado de carga',
        );
        finishAddingVideos();
      }
    });
  }

  /// Actualiza el progreso de agregar videos
  void updateAddingProgress(int current, int total, [String? message]) {
    _safeUpdate(
      () => state.copyWith(
        currentProgress: current,
        totalProgress: total,
        currentMessage: message ?? 'Procesando video ${current + 1} de $total',
      ),
    );
  }

  /// Finaliza la carga de agregar videos
  /// DRY: limpia todos los estados relacionados con la carga
  void finishAddingVideos() {
    _safeUpdate(
      () => state.copyWith(
        isAddingVideos: false,
        currentMessage: null,
        currentProgress: 0,
        totalProgress: 0,
        loadingFileNames: [], // SOLID: limpiar lista de archivos
      ),
    );
  }

  /// Inicia la carga de procesamiento de videos
  void startProcessingVideos() {
    _safeUpdate(
      () => state.copyWith(
        isProcessingVideos: true,
        currentMessage: 'Iniciando compresión...',
        currentProgress: 0,
        totalProgress: 0,
      ),
    );
  }

  /// Actualiza el progreso de procesamiento
  void updateProcessingProgress(
    int current,
    int total,
    double fileProgress,
    String fileName,
  ) {
    final totalProgress = total * 100; // Convertir a porcentaje
    final currentProgress = ((current + fileProgress) * 100).round();

    _safeUpdate(
      () => state.copyWith(
        currentProgress: currentProgress,
        totalProgress: totalProgress,
        currentMessage: 'Comprimiendo: $fileName',
      ),
    );
  }

  /// Finaliza la carga de procesamiento
  void finishProcessingVideos() {
    _safeUpdate(
      () => state.copyWith(
        isProcessingVideos: false,
        currentMessage: null,
        currentProgress: 0,
        totalProgress: 0,
      ),
    );
  }

  /// Resetea todo el estado de carga
  void reset() {
    _safeUpdate(() => const LoadingState());
  }

  /// Actualiza el mensaje de carga
  void updateMessage(String message) {
    _safeUpdate(() => state.copyWith(currentMessage: message));
  }
}
