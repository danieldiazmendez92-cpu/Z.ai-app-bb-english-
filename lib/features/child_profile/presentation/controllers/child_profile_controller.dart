import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_profile.dart';
import '../../domain/repositories/child_profile_repository.dart';
import 'package:storyenglish_kids/shared/providers/auth_provider.dart';

/// Controller que maneja la lista de hijos del usuario y el hijo activo.
///
/// State es [AsyncValue<List<ChildProfile>>] con todos los hijos activos.
/// El hijo activo se maneja con [activeChildProvider] aparte.
class ChildProfileController
    extends StateNotifier<AsyncValue<List<ChildProfile>>> {
  ChildProfileController({
    required ChildProfileRepository repository,
    required String userUid,
  })  : _repository = repository,
        _userUid = userUid,
        super(const AsyncValue.loading()) {
    _init();
  }

  final ChildProfileRepository _repository;
  final String _userUid;

  Future<void> _init() async {
    try {
      // Suscribirse al stream reactivo
      _repository.watchChildrenForUser(_userUid).listen(
        (children) {
          state = AsyncValue.data(children);
        },
        onError: (e, st) {
          state = AsyncValue.error(e, st);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ChildProfile?> createChild({
    required String name,
    required int age,
    required String avatarUrl,
    List<String> interests = const [],
  }) async {
    try {
      final child = await _repository.createChild(
        name: name,
        age: age,
        avatarUrl: avatarUrl,
        interests: interests,
      );
      // El stream se va a actualizar automáticamente
      return child;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> updateChild({
    required String childId,
    String? name,
    int? age,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    try {
      await _repository.updateChild(
        childId: childId,
        name: name,
        age: age,
        avatarUrl: avatarUrl,
        interests: interests,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await _repository.softDeleteChild(childId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// Provider del repositorio.
/// Inyecta el `userUid` del usuario actual desde `authControllerProvider`.
final childProfileRepositoryProvider =
    Provider<ChildProfileRepository>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  return ChildProfileRepositoryImpl(
    currentUserUid: user?.uid,
  );
});

/// Provider del controller de perfiles.
/// Reacciona a cambios del usuario actual.
final childProfileControllerProvider =
    StateNotifierProvider<ChildProfileController, AsyncValue<List<ChildProfile>>>(
        (ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  final repo = ref.watch(childProfileRepositoryProvider);
  return ChildProfileController(
    repository: repo,
    userUid: user?.uid ?? '',
  );
});

/// Provider del hijo activo (seleccionado en ChildPicker).
final activeChildProvider = StateProvider<ChildProfile?>((ref) {
  // Por defecto, tomar el primer hijo disponible
  final children = ref.watch(childProfileControllerProvider).valueOrNull;
  return children?.isNotEmpty == true ? children!.first : null;
});

/// Helper: devuelve true si el usuario tiene al menos un hijo configurado.
final hasChildrenProvider = Provider<bool>((ref) {
  final children = ref.watch(childProfileControllerProvider).valueOrNull;
  return children != null && children.isNotEmpty;
});
