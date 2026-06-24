import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';

/// Estado posible del flujo de verificación parental.
enum ParentalVerificationStatus {
  /// Estado inicial: no se generó el challenge todavía.
  idle,

  /// Generando las preguntas matemáticas.
  generatingChallenge,

  /// Las preguntas están listas para ser respondidas.
  challengeReady,

  /// Enviando respuestas para validación.
  verifying,

  /// Verificación exitosa.
  verified,

  /// Verificación fallida (respuestas incorrectas o rate limit).
  error,
}

/// Datos de las preguntas del challenge matemático.
class MathChallenge {
  const MathChallenge({
    required this.questions,
    required this.sessionId,
  });

  /// Lista de 3 preguntas con su respuesta correcta.
  /// Cada pregunta es un Map: { 'question': '5 + 7 = ?', 'answer': 12 }
  final List<Map<String, dynamic>> questions;

  /// ID de sesión para enviar al backend (valida rate limit).
  final String sessionId;

  bool get isEmpty => questions.isEmpty;
}

class ParentalVerificationState {
  const ParentalVerificationState({
    this.status = ParentalVerificationStatus.idle,
    this.challenge,
    this.failure,
  });

  final ParentalVerificationStatus status;
  final MathChallenge? challenge;
  final Failure? failure;

  ParentalVerificationState copyWith({
    ParentalVerificationStatus? status,
    MathChallenge? challenge,
    Failure? failure,
  }) {
    return ParentalVerificationState(
      status: status ?? this.status,
      challenge: challenge ?? this.challenge,
      failure: failure,
    );
  }
}

/// Controller que orquesta la verificación parental.
///
/// Flujo:
/// 1. `generateChallenge()` → llama a Cloud Function `verifyParental`
///    en modo generación (sin respuestas) para obtener 3 preguntas
///    matemáticas y un sessionId.
/// 2. El usuario responde.
/// 3. `submitAnswers(answers)` → llama a la misma Cloud Function
///    con sessionId + respuestas. Si todas son correctas, el backend
///    marca `users/{uid}.parental_verified_at = now`.
///
/// Rate limit: 3 intentos por hora (enforced por Cloud Function).
class ParentalVerificationController
    extends StateNotifier<ParentalVerificationState> {
  ParentalVerificationController({required FirebaseFunctions functions})
      : _functions = functions,
        super(const ParentalVerificationState());

  final FirebaseFunctions _functions;

  /// Genera 3 preguntas matemáticas al azar.
  Future<void> generateChallenge() async {
    state = state.copyWith(
      status: ParentalVerificationStatus.generatingChallenge,
      failure: null,
    );

    try {
      final result = await _functions
          .httpsCallable('verifyParental')
          .call<Map<String, dynamic>>({
        'action': 'generate',
      });

      final data = result.data;
      final questions =
          (data['questions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final sessionId = data['session_id'] as String? ?? '';

      state = state.copyWith(
        status: ParentalVerificationStatus.challengeReady,
        challenge: MathChallenge(
          questions: questions,
          sessionId: sessionId,
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(
        status: ParentalVerificationStatus.error,
        failure: _mapFunctionsException(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: ParentalVerificationStatus.error,
        failure: UnknownFailure(e.toString()),
      );
    }
  }

  /// Envía las respuestas para validación.
  /// Devuelve true si la verificación fue exitosa.
  Future<bool> submitAnswers(List<int> answers) async {
    if (state.challenge == null) {
      state = state.copyWith(
        status: ParentalVerificationStatus.error,
        failure: const ValidationFailure(
            'Primero generá las preguntas con generateChallenge()'),
      );
      return false;
    }

    state = state.copyWith(
      status: ParentalVerificationStatus.verifying,
      failure: null,
    );

    try {
      final result = await _functions
          .httpsCallable('verifyParental')
          .call<Map<String, dynamic>>({
        'action': 'verify',
        'session_id': state.challenge!.sessionId,
        'answers': answers,
      });

      final verified = result.data['verified'] as bool? ?? false;

      if (verified) {
        state = state.copyWith(
          status: ParentalVerificationStatus.verified,
        );
        return true;
      } else {
        state = state.copyWith(
          status: ParentalVerificationStatus.error,
          failure: const AuthFailure(
              'Las respuestas no son correctas. Intentá de nuevo.'),
        );
        return false;
      }
    } on FirebaseFunctionsException catch (e) {
      state = state.copyWith(
        status: ParentalVerificationStatus.error,
        failure: _mapFunctionsException(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: ParentalVerificationStatus.error,
        failure: UnknownFailure(e.toString()),
      );
      return false;
    }
  }

  /// Resetea el controller a estado inicial (para reintentar).
  void reset() {
    state = const ParentalVerificationState();
  }

  Failure _mapFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'resource-exhausted':
        return const AuthFailure(
            'Demasiados intentos fallidos. Esperá una hora y probá de nuevo.');
      case 'unauthenticated':
        return const AuthFailure('Tenés que iniciar sesión primero.');
      case 'failed-precondition':
        return const AuthFailure('Ya estás verificado como adulto.');
      default:
        return AuthFailure(e.message ?? 'Error al verificar');
    }
  }
}
