// =============================================================================
// auth_provider.dart - Providers de autenticación (Riverpod)
// -----------------------------------------------------------------------------
// Expone:
//  - `authRepositoryProvider`: instancia singleton de `AuthRepositoryImpl`.
//  - `authControllerProvider`: `StateNotifier<AsyncValue<AppUser?>>` con los
//    métodos de login/signup/logout.
//  - `authStateProvider`: `StreamProvider<AppUser?>` que escucha
//    `authStateChanges()` (útil para reaccionar a logout en otro device).
//  - `isParentalVerifiedProvider`: helper `bool` para el router.
//  - `currentAppUserProvider`: helper que devuelve el `AppUser?` actual.
//  - `parentalVerificationControllerProvider`: controller del flujo de
//    verificación parental (math challenge).
//
// El router (`app_router.dart`) observa `authControllerProvider` y
// `isParentalVerifiedProvider` para decidir redirecciones.
// =============================================================================

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:storyenglish_kids/features/auth/data/auth_repository_impl.dart';
import 'package:storyenglish_kids/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:storyenglish_kids/features/auth/domain/entities/app_user.dart';
import 'package:storyenglish_kids/features/auth/domain/repositories/auth_repository.dart';
import 'package:storyenglish_kids/features/auth/presentation/controllers/auth_controller.dart';
import 'package:storyenglish_kids/features/auth/presentation/controllers/parental_verification_controller.dart';

/// Provider singleton de [AuthRepository].
///
/// Inyecta [FirebaseAuthDatasource] (que envuelve `firebase_auth`,
/// `cloud_firestore`, `google_sign_in`, `sign_in_with_apple`).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: FirebaseAuthDatasource(),
  );
});

/// Provider del [AuthController] (estado de sesión actual).
///
/// El `state` es `AsyncValue<AppUser?>`:
///  - `AsyncLoading` mientras carga la sesión inicial o procesa una acción.
///  - `AsyncData<AppUser?>` cuando hay (o no hay) usuario.
///  - `AsyncError<Failure>` si la última acción falló.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// `StreamProvider` que escucha `authStateChanges()`.
///
/// Útil para reaccionar a cambios externos (logout en otro device, etc.).
/// El `authControllerProvider` internamente ya escucha este stream, así que
/// en la mayoría de los casos basta con observar `authControllerProvider`.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// `true` si el usuario completó verificación parental.
final isParentalVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  return user?.parentalVerifiedAt != null;
});

/// Devuelve el `AppUser?` actual (o `null` si loading / no hay sesión).
final currentAppUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});

/// Provider del [ParentalVerificationController].
///
/// Depende de `FirebaseFunctions` para llamar a la Cloud Function
/// `verifyParental`.
final parentalVerificationControllerProvider =
    StateNotifierProvider<ParentalVerificationController,
        ParentalVerificationState>((ref) {
  return ParentalVerificationController(
    functions: FirebaseFunctions.instance,
  );
});
