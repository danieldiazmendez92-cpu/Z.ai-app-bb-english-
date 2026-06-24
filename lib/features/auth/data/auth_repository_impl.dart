import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'datasources/firebase_auth_datasource.dart';

/// Implementación de [AuthRepository] que usa Firebase Auth + Firestore.
///
/// Esta clase es la única que conoce Firebase en la capa de datos.
/// Los controllers solo ven la interface `AuthRepository`.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required FirebaseAuthDatasource datasource})
      : _datasource = datasource;

  final FirebaseAuthDatasource _datasource;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _datasource.signInWithEmail(
      email: email,
      password: password,
    );
    return _datasource.fetchAppUser(cred.user!);
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _datasource.signUpWithEmail(
      email: email,
      password: password,
    );

    // Actualizar display name en Firebase Auth
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }

    // fetchAppUser crea el doc en Firestore si no existe
    return _datasource.fetchAppUser(cred.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final cred = await _datasource.signInWithGoogle();
    return _datasource.fetchAppUser(cred.user!);
  }

  @override
  Future<AppUser> signInWithApple() async {
    final cred = await _datasource.signInWithApple();
    return _datasource.fetchAppUser(cred.user!);
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<AppUser?> currentUser() async {
    final fbUser = _datasource.currentFirebaseUser;
    if (fbUser == null) return null;
    return _datasource.fetchAppUser(fbUser);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    // Combina el stream de Firebase Auth con fetches a Firestore.
    // Cada vez que cambia el user de Auth, leemos su doc de Firestore.
    return _datasource.authStateChanges.asyncMap((fbUser) async {
      if (fbUser == null) return null;
      try {
        return await _datasource.fetchAppUser(fbUser);
      } on Failure {
        // Si falla el fetch, propagar null para que el router
        // trate al usuario como no autenticado.
        return null;
      }
    });
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _datasource.sendPasswordResetEmail(email: email);

  @override
  Future<AppUser?> refreshUser() async {
    // Forzar refresh del ID token antes de releer Firestore
    final fbUser = _datasource.currentFirebaseUser;
    if (fbUser == null) return null;
    await fbUser.reload();
    return _datasource.fetchAppUser(fbUser);
  }
}

// Helper para convertir Failure a Stream
extension FailureToStream on Failure {
  Never throwError() => throw this;
}
