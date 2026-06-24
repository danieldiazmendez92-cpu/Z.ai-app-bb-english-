// =============================================================================
// validators_test.dart - Tests unitarios de Validators
// -----------------------------------------------------------------------------
// SKELETON: tests minimos para que `flutter test` tenga algo que correr.
// En Fase 1 se amplian con casos edge.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:storyenglish_kids/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('devuelve null para email valido', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('john.doe+test@sub.domain.co'), isNull);
    });

    test('devuelve mensaje para email invalido', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('missing@domain'), isNotNull);
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Validators.isValidEmail', () {
    test('true para email valido', () {
      expect(Validators.isValidEmail('a@b.co'), isTrue);
    });
    test('false para email invalido', () {
      expect(Validators.isValidEmail('a@b'), isFalse);
      expect(Validators.isValidEmail(null), isFalse);
    });
  });

  group('Validators.password', () {
    test('devuelve null para password fuerte', () {
      expect(Validators.password('Abcdef12'), isNull);
    });

    test('devuelve mensaje para password debil', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('short'), isNotNull);          // < 8
      expect(Validators.password('alllowercase1'), isNotNull);  // sin mayus
      expect(Validators.password('ALLUPPER1'), isNotNull);      // sin minus
      expect(Validators.password('NoNumber'), isNotNull);       // sin digito
    });
  });

  group('Validators.age', () {
    test('devuelve null para edad en rango 2-7', () {
      for (var age = 2; age <= 7; age++) {
        expect(Validators.age(age), isNull, reason: 'age=$age');
      }
    });

    test('devuelve mensaje para edad fuera de rango', () {
      expect(Validators.age(0), isNotNull);
      expect(Validators.age(1), isNotNull);
      expect(Validators.age(8), isNotNull);
      expect(Validators.age(null), isNotNull);
    });
  });

  group('Validators.childName', () {
    test('devuelve null para nombre valido', () {
      expect(Validators.childName('Ana'), isNull);
      expect(Validators.childName('María José'), isNull);
      expect(Validators.childName('Niño-1'.replaceAll('1', '')), isNull);
    });

    test('devuelve mensaje para nombre invalido', () {
      expect(Validators.childName(''), isNotNull);
      expect(Validators.childName(null), isNotNull);
      expect(Validators.childName('Ana123'), isNotNull);          // numeros
      expect(Validators.childName('A' * 21), isNotNull);          // > 20 chars
    });
  });

  group('Validators.confirmPassword', () {
    test('null cuando coinciden', () {
      final v = Validators.confirmPassword('Abcdef12');
      expect(v('Abcdef12'), isNull);
    });
    test('mensaje cuando no coinciden', () {
      final v = Validators.confirmPassword('Abcdef12');
      expect(v('Different1'), isNotNull);
    });
  });
}
