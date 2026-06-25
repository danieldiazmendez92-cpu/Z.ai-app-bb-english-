import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio de performance monitoring.
///
/// Wrapper simple sobre Firebase Performance (en producción) que
/// mide tiempos de operaciones clave:
/// - Carga de cuentos
/// - Reproducción de audio
/// - Sincronización de progreso
///
/// En demo mode, solo loggea. En producción, integra con Firebase Performance.
class PerformanceMonitor {
  final Map<String, DateTime> _traces = {};

  /// Inicia un trace.
  void startTrace(String name) {
    _traces[name] = DateTime.now();
    if (kDebugMode) {
      debugPrint('⏱️ [PERF] start: $name');
    }
  }

  /// Termina un trace y loggea la duración.
  void stopTrace(String name) {
    final start = _traces[name];
    if (start == null) return;
    final duration = DateTime.now().difference(start);
    _traces.remove(name);

    if (kDebugMode) {
      debugPrint('⏱️ [PERF] $name: ${duration.inMilliseconds}ms');
    }

    // En producción: enviar a Firebase Performance
    // FirebasePerformance.instance.newTrace(name)..start()..stop()
  }

  /// Mide la ejecución de una función async.
  Future<T> measure<T>(String name, Future<T> Function() action) async {
    startTrace(name);
    try {
      return await action();
    } finally {
      stopTrace(name);
    }
  }
}

final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor();
});
