// =============================================================================
// active_child_provider.dart - Hijo activo (perfil seleccionado)
// -----------------------------------------------------------------------------
// Re-export de `activeChildProvider` y helpers asociados definidos en
// `child_profile_provider.dart`. Se mantiene este archivo por compatibilidad
// con imports existentes (story_grid, child_avatar, etc.).
//
// En Fase 2 se persistira en Hive (key: AppConstants.keyActiveChildId) para
// que al reabrir la app siga el mismo hijo jugando.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../features/child_profile/domain/entities/child_profile.dart';

// Re-export del provider real para no romper imports existentes.
export '../../shared/providers/child_profile_provider.dart'
    show activeChildProvider, activeChildIdProvider;

/// Estado legacy para compatibilidad con widgets que todavia no migraron
/// al modelo `ChildProfile` real. Mantenemos [ActiveChild] y
/// [ActiveChildState] como DTOs que envuelven `ChildProfile`.
class ActiveChildState {
  const ActiveChildState({
    this.child,
    this.isLoading = false,
    this.failure,
  });

  final ChildProfile? child;
  final bool isLoading;
  final Failure? failure;

  bool get hasChild => child != null;
  bool get hasError => failure != null;
}

/// Provider legacy: estado con metadata de loading/error.
/// Se construye a partir de `activeChildProvider` (que es la fuente de
/// verdad del hijo seleccionado).
final legacyActiveChildStateProvider = Provider<ActiveChildState>((ref) {
  final child = ref.watch(activeChildProvider);
  return ActiveChildState(child: child);
});

/// `true` si hay un hijo activo (convenience).
final hasActiveChildProvider = Provider<bool>((ref) {
  return ref.watch(activeChildProvider) != null;
});
