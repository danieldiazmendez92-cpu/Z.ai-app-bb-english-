import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storyenglish_kids/core/errors/failures.dart';
import 'package:storyenglish_kids/features/auth/domain/entities/app_user.dart';
import 'package:storyenglish_kids/features/auth/domain/repositories/auth_repository.dart';
import 'package:storyenglish_kids/features/auth/presentation/controllers/auth_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late AuthController controller;

  // Datos de prueba
  final testUser = AppUser(
    uid: 'test-uid',
    email: 'test@test.com',
    displayName: 'Test User',
    authProvider: 'email',
    parentalVerifiedAt: null,
    isPremium: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repo = MockAuthRepository();
    // Stub de `currentUser()` que se llama en el constructor del controller.
    when(() => repo.currentUser()).thenAnswer((_) async => null);
    controller = AuthController(authRepository: repo);
  });

  group('AuthController', () {
    test('initial state is loading, then null after _init completes',
        () async {
      // El constructor llama a _init que llama a currentUser().
      // Como stub devuelve null, el state debería ser AsyncData(null).
      expect(controller.state, const AsyncValue.loading());

      // Esperar a que _init termine
      await Future.delayed(const Duration(milliseconds: 10));

      expect(controller.state, const AsyncValue<AppUser?>.data(null));
    });

    test('loginWithEmail sets user when repo succeeds', () async {
      // Arrange: stub del constructor ya configurado en setUp.
      when(() => repo.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      // Esperar _init
      await Future.delayed(const Duration(milliseconds: 10));

      // Act
      await controller.loginWithEmail(email: 'test@test.com', password: 'pass');

      // Assert
      expect(controller.state, AsyncValue<AppUser?>.data(testUser));
      verify(() => repo.signInWithEmail(
            email: 'test@test.com',
            password: 'pass',
          )).called(1);
    });

    test('loginWithEmail sets error when repo throws AuthFailure', () async {
      when(() => repo.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthFailure('Credenciales inválidas'));

      await Future.delayed(const Duration(milliseconds: 10));

      await controller.loginWithEmail(
          email: 'wrong@test.com', password: 'wrong');

      expect(controller.state.hasError, isTrue);
      expect(controller.state.error, isA<AuthFailure>());
      expect((controller.state.error as AuthFailure).message,
          'Credenciales inválidas');
    });

    test('loginWithGoogle sets user when repo succeeds', () async {
      when(() => repo.signInWithGoogle()).thenAnswer((_) async => testUser);

      await Future.delayed(const Duration(milliseconds: 10));

      await controller.loginWithGoogle();

      expect(controller.state, AsyncValue<AppUser?>.data(testUser));
    });

    test('logout sets state to null', () async {
      // Set initial user
      when(() => repo.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);
      await Future.delayed(const Duration(milliseconds: 10));
      await controller.loginWithEmail(email: 'a@b.com', password: 'p');
      expect(controller.state.value, testUser);

      // Logout
      when(() => repo.signOut()).thenAnswer((_) async {});
      await controller.logout();

      expect(controller.state, const AsyncValue<AppUser?>.data(null));
    });

    test('signUpWithEmail sets user when repo succeeds', () async {
      when(() => repo.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => testUser);

      await Future.delayed(const Duration(milliseconds: 10));

      await controller.signUpWithEmail(
        email: 'new@test.com',
        password: 'Password123',
        displayName: 'New User',
      );

      expect(controller.state, AsyncValue<AppUser?>.data(testUser));
    });
  });
}
