// =============================================================================
// connectivity_service.dart - Chequea online/offline
// -----------------------------------------------------------------------------
// Wrapper sobre `connectivity_plus` que expone un Stream<bool> de estado de
// conexion. La capa de datos lo usa para decidir si va a Firestore o al cache
// local de Hive.
// =============================================================================

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio de conectividad. Singleton con un Stream de estado.
///
/// No lanza excepciones: si no puede determinar el estado, asume `true`
/// (conectado) y deja que la siguiente llamada falle naturalmente.
class ConnectivityService {
  ConnectivityService._(this._connectivity);

  final Connectivity _connectivity;

  /// Stream que emite `true` cuando hay conexion, `false` cuando no.
  /// Emite el valor actual inmediatamente al subscribirse.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_anyConnectionToBool);
  }

  /// `true` si actualmente hay conexion (WiFi, mobile o ethernet).
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _anyConnectionToBool(result);
  }

  /// Convierte el resultado de connectivity_plus a bool.
  /// `ConnectivityResult.none` significa sin conexion.
  static bool _anyConnectionToBool(List<ConnectivityResult> result) {
    // connectivity_plus 6.0+ devuelve List<ConnectivityResult>
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Factory estandar.
  static ConnectivityService create() {
    return ConnectivityService._(Connectivity());
  }
}

/// Provider de Riverpod para `ConnectivityService`.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService.create();
  ref.onDispose(service.dispose);
  return service;
});

// Extension para exponer dispose sin acoplarnos al package interno.
extension on ConnectivityService {
  void dispose() {
    // connectivity_plus no requiere dispose explicito.
  }
}
