// =============================================================================
// connectivity_provider.dart - Provider de estado de conexion
// -----------------------------------------------------------------------------
// Expone `AsyncValue<bool>` con el estado de conexion (true = online).
// Se usa para mostrar banners de "sin conexion" y decidir si leer de cache
// o de Firestore.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/utils/logger.dart';

/// Provider de Stream de conectividad (bool true=online).
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  AppLogger.debug('connectivityStreamProvider: subscribed');
  return service.onConnectivityChanged;
});

/// Provider de conveniencia: ultimo estado conocido de conexion.
/// Default `true` (asume online hasta que se sepa lo contrario).
final isOnlineProvider = Provider<bool>((ref) {
  final asyncConn = ref.watch(connectivityStreamProvider);
  return asyncConn.maybeWhen(
    data: (isOnline) => isOnline,
    orElse: () => true,
  );
});

/// Provider que emite `true` solo cuando se pasa de online -> offline.
/// Util para mostrar SnackBar "Sin conexion" una sola vez.
final justWentOfflineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  bool? wasOnline;
  return service.onConnectivityChanged.map((isOnline) {
    final wentOffline = wasOnline == true && !isOnline;
    wasOnline = isOnline;
    return wentOffline;
  });
});
