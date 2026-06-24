import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Controller que maneja el estado de autenticación.
///
/// Expone [AsyncValue<AppUser?>] donde:
/// - AsyncLoading → cargando (al iniciar operación o sesión)
/// - AsyncData(null) → no hay usuario logueado
/// - AsyncData(user) → usuario logueado
/// - AsyncError → error en la última operación
///
/// El controller NO depende de Firebase directamente, solo de la
/// interface `AuthRepository`. En tests se le inyecta un mock.
class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.loading()) {
    // Cargar sesión inicial
    _init();
  }

  final AuthRepository _authRepository;

  Future<void> _init() async {
    try {
      final user = await _authRepository.currentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ============================================================
  // Operaciones de auth
  // ============================================================

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
    }
  }

  Future<void> loginWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithApple();
      state = AsyncValue.data(user);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
    } on Failure catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(e.toString()), st);
      rethrow;
    }
  }

  /// Refresca el usuario desde Firestore (útil después de verificar parental
  /// o después de suscribirse, para que el state refleje los cambios).
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.refreshUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      // No romper el state si el refresh falla
      state = AsyncValue.error(e, st);
    }
  }

  /// Limpia el estado de error (lo vuelve a AsyncData con el user actual).
  void clearError() {
    final current = state;
    if (current is AsyncError) {
      state = AsyncValue.data(current.valueOrNull);
    }
  }
}
