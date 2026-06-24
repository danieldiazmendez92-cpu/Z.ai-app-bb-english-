import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/collection_names.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Datasource que habla directamente con Firebase Auth + Firestore.
///
/// Responsabilidades:
/// - Llamar a Firebase Auth para sign in / sign up / sign out
/// - Llamar a GoogleSignIn y SignInWithApple para auth social
/// - Mapear `firebase_auth.User` → `AppUser` (nuestra entidad de dominio)
/// - Convertir códigos de error de Firebase a `Failure` (dominio)
///
/// NO contiene lógica de negocio. Solo traduce APIs externas.
class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
            );

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // ============================================================
  // Sign in / Sign up con email y password
  // ============================================================

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ============================================================
  // Sign in con Google
  // ============================================================

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger el flujo de autenticación
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Cancelado por el usuario');
      }

      // Obtener credenciales
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in con Firebase
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ============================================================
  // Sign in con Apple
  // ============================================================

  Future<UserCredential> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential oauthCredential =
          OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await _firebaseAuth.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure('Cancelado por el usuario');
      }
      throw AuthFailure('Error Apple Sign-In: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ============================================================
  // Sign out y utilidades
  // ============================================================

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ============================================================
  // Conversión Firebase User → AppUser
  // ============================================================

  /// Lee el documento `/users/{uid}` desde Firestore y construye el `AppUser`.
  /// Si no existe el documento, lo crea (esto pasa en el primer login,
  /// el trigger `onUserCreate` lo completa después).
  Future<AppUser> fetchAppUser(User firebaseUser) async {
    final docRef =
        _firestore.collection(CollectionNames.users).doc(firebaseUser.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      // Crear doc inicial (el trigger onUserCreate lo complementa)
      final now = DateTime.now();
      final provider = _detectProvider(firebaseUser);
      final Map<String, dynamic> userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email?.toLowerCase() ?? '',
        'display_name': firebaseUser.displayName,
        'auth_provider': provider,
        'parental_verified_at': null,
        'is_premium': false,
        'premium_expires_at': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      await docRef.set(userData);

      // Releer para obtener timestamps del servidor
      final refreshed = await docRef.get();
      return _mapDocToAppUser(refreshed, firebaseUser);
    }

    return _mapDocToAppUser(docSnap, firebaseUser);
  }

  String _detectProvider(User user) {
    for (final userInfo in user.providerData) {
      switch (userInfo.providerId) {
        case 'google.com':
          return 'google';
        case 'apple.com':
          return 'apple';
        case 'password':
          return 'email';
      }
    }
    return 'email';
  }

  AppUser _mapDocToAppUser(DocumentSnapshot<Map<String, dynamic>> doc, User fbUser) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: fbUser.uid,
      email: (data['email'] as String?) ?? fbUser.email ?? '',
      displayName: data['display_name'] as String? ?? fbUser.displayName,
      authProvider: data['auth_provider'] as String? ?? 'email',
      parentalVerifiedAt: (data['parental_verified_at'] as Timestamp?)?.toDate(),
      isPremium: data['is_premium'] as bool? ?? false,
      premiumExpiresAt:
          (data['premium_expires_at'] as Timestamp?)?.toDate(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  // ============================================================
  // Mapeo de errores
  // ============================================================

  Failure _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const ValidationFailure('Email inválido');
      case 'user-disabled':
        return const AuthFailure('Esta cuenta fue deshabilitada');
      case 'user-not-found':
        return const AuthFailure('No existe una cuenta con ese email');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Email o contraseña incorrectos');
      case 'email-already-in-use':
        return const ValidationFailure('Ya existe una cuenta con ese email');
      case 'weak-password':
        return const ValidationFailure(
            'La contraseña es muy débil. Usá al menos 8 caracteres con mayúsculas y números');
      case 'operation-not-allowed':
        return const AuthFailure('Este método de login no está habilitado');
      case 'too-many-requests':
        return const AuthFailure(
            'Demasiados intentos fallidos. Probá de nuevo más tarde');
      case 'network-request-failed':
        return const NetworkFailure('Sin conexión a internet');
      default:
        debugPrint('FirebaseAuthException no mapeada: ${e.code} - ${e.message}');
        return AuthFailure(e.message ?? 'Error desconocido');
    }
  }
}
