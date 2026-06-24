import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Repositorio de auth DEMO.
///
/// No usa Firebase. Mantiene usuarios en memoria.
/// Cualquier email/password funciona. Acepta cualquier social login.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository() : _currentUser = null;

  AppUser? _currentUser;

  /// Usuario demo "precreado" para login rápido
  static final AppUser _demoUser = AppUser(
    uid: 'demo-user-001',
    email: 'demo@storyenglish.kids',
    displayName: 'Demo Parent',
    authProvider: 'email',
    parentalVerifiedAt: DateTime.now(),
    isPremium: false,
    createdAt: DateTime(2026, 6, 1),
    updatedAt: DateTime.now(),
  );

  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate latency
    _currentUser = _demoUser.copyWith(
      email: email.toLowerCase(),
      authProvider: 'email',
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // En demo mode, el signup ya deja al usuario parentalmente verificado
    // (no requiere math challenge). Así se puede probar el flujo completo
    // sin configurar Cloud Functions.
    _currentUser = AppUser(
      uid: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email.toLowerCase(),
      displayName: displayName,
      authProvider: 'email',
      parentalVerifiedAt: DateTime.now(),
      isPremium: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _demoUser.copyWith(
      authProvider: 'google',
      email: 'google.demo@storyenglish.kids',
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _demoUser.copyWith(
      authProvider: 'apple',
      email: 'apple.demo@storyenglish.kids',
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AppUser?> currentUser() async {
    return _currentUser;
  }

  @override
  Stream<AppUser?>> authStateChanges() {
    return _controller.stream;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op en demo
  }

  @override
  Future<AppUser?> refreshUser() async {
    return _currentUser;
  }

  /// Demo: marca al usuario como parentalmente verificado.
  /// En demo mode, esto se hace sin llamada a backend.
  Future<void> markParentalVerified() async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        parentalVerifiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _controller.add(_currentUser);
    }
  }

  void dispose() {
    _controller.close();
  }
}
