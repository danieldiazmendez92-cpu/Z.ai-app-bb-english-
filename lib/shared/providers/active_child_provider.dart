// =============================================================================
// active_child_provider.dart - Provider stub del nio activo
// -----------------------------------------------------------------------------
// SKELETON: cuando se implemente la feature child_profile (Fase 1, sprint 1.2),
// este provider se conectara a ChildProfileRepository y expondra el nio
// seleccionado por el padre para jugar.
//
// El nio activo se persiste en Hive (key: 'active_child_id') para que al
// reabrir la app siga el mismo nio jugando.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';

/// DTO temporal para el nio activo.
/// En Fase 1 se reemplaza por `ChildProfile` (modelo freezed de docs/03).
class ActiveChild {
  const ActiveChild({
    required this.childId,
    required this.name,
    required this.age,
    required this.avatarUrl,
    this.interests = const [],
  });

  final String childId;
  final String name;
  final int age;
  final String avatarUrl;
  final List<String> interests;
}

/// Estado del nio activo.
class ActiveChildState {
  const ActiveChildState({
    this.child,
    this.isLoading = false,
    this.failure,
  });

  final ActiveChild? child;
  final bool isLoading;
  final Failure? failure;

  bool get hasChild => child != null;
  bool get hasError => failure != null;
}

/// Provider del nio activo.
///
/// SKELETON - en Fase 1 se reemplaza por StateNotifierProvider que:
///   1. Lee `active_child_id` de Hive al iniciar.
///   2. Lo carga desde ChildProfileRepository.
///   3. Expone setter `setActiveChild(childId)` que persiste en Hive.
final activeChildProvider =
    StateProvider<ActiveChildState>((ref) {
  AppLogger.debug('activeChildProvider: initialized as stub');
  return const ActiveChildState();
});

/// Provider de conveniencia: expone solo el childId activo (o null).
final activeChildIdProvider = Provider<String?>((ref) {
  return ref.watch(activeChildProvider).child?.childId;
});

/// Provider de conveniencia: `true` si hay un nio activo.
final hasActiveChildProvider = Provider<bool>((ref) {
  return ref.watch(activeChildProvider).hasChild;
});
