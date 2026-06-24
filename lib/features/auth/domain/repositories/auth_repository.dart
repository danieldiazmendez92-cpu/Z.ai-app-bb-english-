import '../../../../features/auth/domain/entities/app_user.dart';

/// Contrato del repositorio de autenticación.
/// La implementación vive en `data/auth_repository_impl.dart`.
///
/// Esta interface permite que los controllers dependan de la abstracción
/// (no de Firebase directamente), facilitando testing con mocks.
abstract class AuthRepository {
  /// Inicia sesión con email y password.
  /// Lanza [AuthFailure] si las credenciales son inválidas.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Crea una cuenta nueva con email y password.
  /// Lanza [AuthFailure] si el email ya existe o la password es débil.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Inicia sesión con Google Sign-In.
  /// Lanza [AuthFailure] si el usuario cancela o hay error.
  Future<AppUser> signInWithGoogle();

  /// Inicia sesión con Sign in with Apple.
  /// Lanza [AuthFailure] si el usuario cancela o hay error.
  Future<AppUser> signInWithApple();

  /// Cierra la sesión del usuario actual.
  Future<void> signOut();

  /// Devuelve el usuario actual, o null si no hay sesión.
  Future<AppUser?> currentUser();

  /// Stream de cambios de estado de autenticación.
  /// Emite null cuando el usuario cierra sesión.
  Stream<AppUser?> authStateChanges();

  /// Envía un email de reseteo de password.
  Future<void> sendPasswordResetEmail({required String email});

  /// Refresca el usuario actual desde Firestore (para detectar cambios
  /// como `parentalVerifiedAt` o `isPremium`).
  Future<AppUser?> refreshUser();
}
