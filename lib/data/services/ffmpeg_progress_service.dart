import 'dart:math' as math;
import 'package:vcompressor/core/logging/app_logger.dart';
import 'package:vcompressor/utils/format_utils.dart';

/// Punto de progreso para cálculo de estimación temporal
class ProgressPoint {
  final double progress;
  final DateTime timestamp;
  final double timeElapsedSeconds;
  
  const ProgressPoint({
    required this.progress,
    required this.timestamp,
    required this.timeElapsedSeconds,
  });
  
  @override
  String toString() => 'ProgressPoint(${(progress * 100).toStringAsFixed(1)}%, ${timeElapsedSeconds.toStringAsFixed(1)}s)';
}

/// Servicio simplificado para manejo de progreso de FFmpeg
/// SOLID: Single Responsibility - solo maneja progreso y tiempo restante
/// DRY: Elimina complejidad innecesaria del sistema anterior
class FFmpegProgressService {
  static const int _maxHistoryPoints = 10; // Ventana pequeña para suavizado
  static const double _minProgressThreshold = 0.01; // 1% mínimo para evitar divisiones por cero
  
  final List<ProgressPoint> _progressHistory = [];
  DateTime? _startTime;
  double _lastReportedProgress = 0.0;
  
  /// Inicia el seguimiento de progreso
  void startProgress() {
    _startTime = DateTime.now();
    _progressHistory.clear();
    _lastReportedProgress = 0.0;
    AppLogger.debug('FFmpegProgressService iniciado', tag: 'FFmpegProgress');
  }
  
  /// Actualiza el progreso con datos de FFmpeg
  /// SOLID: Single Responsibility - solo actualiza progreso
  void updateProgress(double progress, double timeElapsedSeconds) {
    if (progress < 0 || progress > 1 || timeElapsedSeconds < 0) return;
    
    final now = DateTime.now();
    _progressHistory.add(ProgressPoint(
      progress: progress,
      timestamp: now,
      timeElapsedSeconds: timeElapsedSeconds,
    ));
    
    // Mantener ventana de historial limitada
    if (_progressHistory.length > _maxHistoryPoints) {
      _progressHistory.removeAt(0);
    }
    
    _lastReportedProgress = progress;
    
    AppLogger.debug(
      'Progreso actualizado: ${(progress * 100).toStringAsFixed(1)}% en ${timeElapsedSeconds.toStringAsFixed(1)}s',
      tag: 'FFmpegProgress',
    );
  }
  
  /// Calcula el tiempo restante usando la fórmula propuesta
  /// DRY: Implementa la fórmula matemática simple y efectiva
  String? calculateTimeRemaining() {
    if (_progressHistory.isEmpty || _lastReportedProgress >= 1.0) {
      return null;
    }
    
    // Usar el punto más reciente para cálculo directo
    final latestPoint = _progressHistory.last;
    
    // Aplicar la fórmula: Tiempo restante = (Tiempo transcurrido / Porcentaje completado) × (1 - Porcentaje completado)
    final timeRemainingSeconds = _calculateTimeRemaining(
      latestPoint.timeElapsedSeconds,
      latestPoint.progress,
    );
    
    if (timeRemainingSeconds == null || timeRemainingSeconds <= 0) {
      return null;
    }
    
    // Aplicar suavizado con media móvil si hay suficientes datos
    final smoothedSeconds = _applySmoothing(timeRemainingSeconds);
    
    // Formatear resultado
    final remaining = Duration(seconds: smoothedSeconds.round());
    return FormatUtils.formatTimeEstimate(remaining);
  }
  
  /// Calcula tiempo restante usando la fórmula matemática propuesta
  /// SOLID: Single Responsibility - solo calcula tiempo restante
  double? _calculateTimeRemaining(double timeElapsedSeconds, double progress) {
    // Validar datos de entrada
    if (progress <= _minProgressThreshold || timeElapsedSeconds <= 0) {
      return null;
    }
    
    // Fórmula: Tiempo restante = (Tiempo transcurrido / Porcentaje completado) × (1 - Porcentaje completado)
    final timeRemaining = (timeElapsedSeconds / progress) * (1 - progress);
    
    // Validar resultado razonable (5 segundos - 2 horas)
    return timeRemaining.clamp(5.0, 7200.0);
  }
  
  /// Aplica suavizado con media móvil simple
  /// DRY: Suavizado simple sin complejidad excesiva
  double _applySmoothing(double currentEstimate) {
    if (_progressHistory.length < 3) {
      return currentEstimate; // No hay suficientes datos para suavizar
    }
    
    // Calcular estimaciones para los últimos puntos
    final estimates = <double>[];
    for (int i = 1; i < _progressHistory.length; i++) {
      final point = _progressHistory[i];
      final estimate = _calculateTimeRemaining(point.timeElapsedSeconds, point.progress);
      if (estimate != null) {
        estimates.add(estimate);
      }
    }
    
    if (estimates.isEmpty) {
      return currentEstimate;
    }
    
    // Media móvil simple (más peso a datos recientes)
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    for (int i = 0; i < estimates.length; i++) {
      final weight = math.pow(1.2, i).toDouble(); // Peso exponencial creciente
      weightedSum += estimates[i] * weight;
      totalWeight += weight;
    }
    
    return totalWeight > 0 ? weightedSum / totalWeight : currentEstimate;
  }
  
  /// Obtiene el progreso actual
  double get currentProgress => _lastReportedProgress;
  
  /// Verifica si hay datos suficientes para estimación confiable
  bool get hasReliableData => _progressHistory.length >= 2;
  
  /// Obtiene estadísticas de debug
  Map<String, dynamic> getDebugStats() {
    return {
      'history_points': _progressHistory.length,
      'current_progress': '${(_lastReportedProgress * 100).toStringAsFixed(1)}%',
      'time_elapsed': _startTime != null 
          ? '${DateTime.now().difference(_startTime!).inSeconds}s'
          : 'N/A',
      'has_reliable_data': hasReliableData,
    };
  }
  
  /// Reinicia el servicio
  void reset() {
    _progressHistory.clear();
    _startTime = null;
    _lastReportedProgress = 0.0;
    AppLogger.debug('FFmpegProgressService reiniciado', tag: 'FFmpegProgress');
  }
}

