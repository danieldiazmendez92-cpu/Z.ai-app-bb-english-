// =============================================================================
// auth_provider.dart - Provider stub de autenticacion
// -----------------------------------------------------------------------------
// SKELETON: cuando se implemente la feature auth (Fase 1, sprint 1.1), este
// provider se conectara a AuthRepository y expondra el estado de sesion.
//
// Por ahora define la "forma" que espera el router y el resto de la app.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';

/// Estado de autenticacion expuesto por [authControllerProvider].
///
/// SKELETON - reemplazar por AsyncValue<AppUser?> en Fase 1.
class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.parentalVerified = false,
    this.onboardingCompleted = false,
    this.userUid,
    this.failure,
  });

  final bool isAuthenticated;
  final bool parentalVerified;
  final bool onboardingCompleted;
  final String? userUid;
  final Failure? failure;

  bool get requiresLogin => !isAuthenticated;
  bool get requiresParentalVerification =>
      isAuthenticated && !parentalVerified;
  bool get requiresOnboarding =>
      isAuthenticated && parentalVerified && !onboardingCompleted;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? parentalVerified,
    bool? onboardingCompleted,
    String? userUid,
    Failure? failure,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      parentalVerified: parentalVerified ?? this.parentalVerified,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      userUid: userUid ?? this.userUid,
      failure: failure,
    );
  }
}

/// Provider de estado de autenticacion.
///
/// SKELETON - en Fase 1 se reemplaza por:
///   final authControllerProvider =
///       StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
///     return AuthController(authRepository: ref.watch(authRepositoryProvider));
///   });
final authControllerProvider = StateProvider<AuthState>((ref) {
  AppLogger.debug('authControllerProvider: initialized as stub');
  return const AuthState();
});

/// Provider que expone solo el flag booleano de autenticacion (conveniencia
/// para uso en router redirect).
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

/// Provider que expone si el usuario requiere parental verification.
final requiresParentalVerificationProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).requiresParentalVerification;
});

/// Provider que expone si el usuario requiere onboarding.
final requiresOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).requiresOnboarding;
});
