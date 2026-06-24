// =============================================================================
// debounce.dart - Utility para debounce de llamadas async
// -----------------------------------------------------------------------------
// Permite agrupar llamadas repetidas en una sola (ej: busqueda mientras se
// escribe). Cancela llamadas previas pendientes y solo ejecuta la ultima.
// =============================================================================

import 'dart:async';

import '../constants/app_constants.dart';

/// Debouncer: ejecuta [action] despues de [duration] sin nuevas llamadas.
///
/// Uso tipico:
///   final debouncer = Debouncer(duration: Duration(milliseconds: 400));
///   // en onChanged del TextField:
///   debouncer.run(() => buscar(query));
class Debouncer {
  Debouncer({
    this.duration = AppConstants.defaultDebounceDuration,
  });

  /// Tiempo que espera sin nuevas llamadas antes de ejecutar [action].
  final Duration duration;

  Timer? _timer;
  void Function()? _lastAction;

  /// Programa [action] para ejecutarse despues de [duration].
  /// Cancela cualquier accion previa pendiente.
  void run(void Function() action) {
    _lastAction = action;
    _timer?.cancel();
    _timer = Timer(duration, () {
      _lastAction?.call();
      _lastAction = null;
    });
  }

  /// Cancela la accion pendiente (si la hay) sin ejecutarla.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastAction = null;
  }

  /// `true` si hay una accion pendiente.
  bool get hasPending => _timer?.isActive ?? false;

  /// Libera recursos. Llamar al hacer dispose del widget que lo posee.
  void dispose() {
    cancel();
  }
}

/// Debouncer que devuelve un `Future<T>` con el resultado de la ultima llamada.
/// Util para llamadas async (ej: search API).
class AsyncDebouncer<T> {
  AsyncDebouncer({
    this.duration = AppConstants.defaultDebounceDuration,
  });

  final Duration duration;
  Timer? _timer;
  Completer<T>? _completer;

  /// Programa [action] para ejecutarse despues de [duration].
  /// Devuelve un Future que se completa con el resultado de [action].
  /// Si se llama de nuevo antes de [duration], cancela y reemplaza.
  Future<T> run(Future<T> Function() action) {
    _timer?.cancel();
    _completer?.completeError(StateError('Debounced'));
    _completer = Completer<T>();

    _timer = Timer(duration, () async {
      try {
        final result = await action();
        _completer?.complete(result);
      } catch (e, st) {
        _completer?.completeError(e, st);
      } finally {
        _completer = null;
        _timer = null;
      }
    });

    return _completer!.future;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _completer?.completeError(StateError('Cancelled'));
    _completer = null;
  }

  void dispose() => cancel();
}
