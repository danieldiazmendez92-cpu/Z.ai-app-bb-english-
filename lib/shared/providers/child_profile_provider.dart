// =============================================================================
// child_profile_provider.dart - Providers de perfiles de nio (Riverpod)
// -----------------------------------------------------------------------------
// Expone:
//  - `childProfileRepositoryProvider`: instancia singleton de
//    `ChildProfileRepositoryImpl`.
//  - `childProfileControllerProvider`: `StateNotifier<AsyncValue<List<ChildProfile>>>`
//    con los metodos CRUD (createChild / updateChild / softDeleteChild).
//  - `activeChildProvider`: `StateProvider<ChildProfile?>` con el hijo
//    seleccionado actualmente para jugar. Reemplaza al stub anterior.
//  - `activeChildIdProvider`: convenience `Provider<String?>`.
//  - `childrenStreamProvider`: `StreamProvider` que escucha cambios en
//    `children_profiles` en tiempo real.
//  - `hasAnyChildProvider`: helper bool para el router (true si el usuario
//    tiene al menos 1 perfil -> onboarding completo).
//
// El router observa `authControllerProvider` y al verificar parental,
// redirige a `/onboarding/welcome` si `hasAnyChildProvider` es false.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../features/child_profile/data/child_profile_repository_impl.dart';
import '../../features/child_profile/domain/entities/child_profile.dart';
import '../../features/child_profile/domain/entities/parental_settings.dart';
import '../../features/child_profile/domain/repositories/child_profile_repository.dart';
import '../../features/child_profile/presentation/controllers/child_profile_controller.dart';
import '../../shared/providers/auth_provider.dart';

/// Provider singleton de [ChildProfileRepository].
///
/// Usa `FirebaseFirestore.instance` y `FirebaseAuth.instance` por defecto.
/// En tests se puede overridear con una instancia de `FakeCloudFirestore`.
final childProfileRepositoryProvider = Provider<ChildProfileRepository>((ref) {
  return ChildProfileRepositoryImpl();
});

/// UID del usuario autenticado actual (o null si no hay sesion).
final _currentUidProvider = Provider<String?>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  return user?.uid;
});

/// Provider del [ChildProfileController].
///
/// Se reconstruye cuando cambia el UID del usuario (login/logout). En
/// logout el state se resetea a `AsyncValue.loading()` (no se muestra
/// nada en pantalla porque el router redirige a login).
final childProfileControllerProvider =
    StateNotifierProvider.autoDispose<ChildProfileController,
        AsyncValue<List<ChildProfile>>>((ref) {
  final uid = ref.watch(_currentUidProvider);
  final repo = ref.watch(childProfileRepositoryProvider);

  if (uid == null) {
    // Sin sesion: controller vacio. El router redirige a login.
    return ChildProfileController(
      repository: _EmptyChildProfileRepository(),
      userUid: '',
    );
  }
  return ChildProfileController(repository: repo, userUid: uid);
});

/// Hijo activo (seleccionado para jugar). Se persiste en Hive en Fase 2.
/// Por ahora vive solo en memoria del ProviderScope.
final activeChildProvider = StateProvider<ChildProfile?>((ref) {
  return null;
});

/// Convenience: ID del hijo activo (o null).
final activeChildIdProvider = Provider<String?>((ref) {
  return ref.watch(activeChildProvider)?.childId;
});

/// `true` si el usuario tiene al menos 1 perfil de nio.
/// Util para el redirect del router (onboarding pendiente).
final hasAnyChildProvider = Provider<bool>((ref) {
  final children = ref.watch(childProfileControllerProvider).valueOrNull;
  return children != null && children.isNotEmpty;
});

/// `StreamProvider` que escucha cambios en tiempo real de la coleccion
/// `children_profiles` del usuario. Util para reaccionar a creaciones /
/// ediciones / deletes desde otros dispositivos.
///
/// Nota: en la mayoria de los casos basta con observar
/// `childProfileControllerProvider` (que internamente llama al repo).
/// Este provider esta disponible para flujos que necesitan el stream crudo.
final childrenStreamProvider =
    StreamProvider.autoDispose<List<ChildProfile>>((ref) {
  final uid = ref.watch(_currentUidProvider);
  if (uid == null) {
    return const Stream<List<ChildProfile>>.empty();
  }
  final repo = ref.watch(childProfileRepositoryProvider);
  try {
    return repo.watchChildrenForUser(uid);
  } catch (e, st) {
    AppLogger.error('childrenStreamProvider: error', e, st);
    return Stream.error(
      e is Failure ? e : UnknownFailure(e.toString()),
    );
  }
});

/// Repository "vacio" usado cuando no hay sesion activa.
/// Todos sus metodos lanzan [AuthFailure].
class _EmptyChildProfileRepository implements ChildProfileRepository {
  @override
  Future<ChildProfile> createChild({
    required String userUid,
    required String name,
    required int age,
    required String avatarUrl,
    List<String> interests = const [],
  }) async {
    throw const AuthFailure('No hay sesion activa');
  }

  @override
  Future<ChildProfile> updateChild({
    required String childId,
    String? name,
    int? age,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    throw const AuthFailure('No hay sesion activa');
  }

  @override
  Future<void> softDeleteChild(String childId) async {
    throw const AuthFailure('No hay sesion activa');
  }

  @override
  Future<List<ChildProfile>> getChildrenForUser(String userUid) async {
    return const <ChildProfile>[];
  }

  @override
  Future<ChildProfile> getChild(String childId) async {
    throw const AuthFailure('No hay sesion activa');
  }

  @override
  Stream<List<ChildProfile>> watchChildrenForUser(String userUid) {
    return const Stream<List<ChildProfile>>.empty();
  }

  @override
  Future<ParentalSettings> getParentalSettings(String userUid) async {
    throw const AuthFailure('No hay sesion activa');
  }

  @override
  Future<void> updateParentalSettings(ParentalSettings settings) async {
    throw const AuthFailure('No hay sesion activa');
  }
}
