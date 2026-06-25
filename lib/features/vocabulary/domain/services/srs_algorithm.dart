// =============================================================================
// srs_algorithm.dart - Algoritmo SM-2 simplificado (Spaced Repetition)
// -----------------------------------------------------------------------------
// Implementación simplificada del algoritmo SuperMemo 2 (Piotr Wozniak, 1987).
// Es el estándar de la industria para apps de flashcards (Anki, Duolingo).
//
// Concepto:
// - Cada palabra tiene un "ease factor" (qué tan fácil es para el niño).
// - Cada repaso exitoso aumenta el intervalo hasta el próximo repaso.
// - Cada repaso fallido reinicia el intervalo a corto.
// - Después de varios repasos exitosos, la palabra se considera "aprendida".
// =============================================================================

import '../../domain/entities/learned_word.dart';

/// Calidad de respuesta del niño (0-5, escala SM-2).
enum ReviewQuality {
  /// El niño no la sabía para nada.
  blackout(0),

  /// La sabía pero con mucho esfuerzo / duda.
  incorrect(1),

  /// La sabía pero con esfuerzo.
  hard(2),

  /// La sabía con algo de duda.
  medium(3),

  /// La sabía bien, con pequeña pausa.
  good(4),

  /// La sabía perfectamente, instantáneo.
  perfect(5);

  const ReviewQuality(this.value);
  final int value;
}

/// Resultado de un repaso: nueva estado SRS para persistir.
class SrsReviewResult {
  const SrsReviewResult({
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
    required this.nextReviewAt,
    required this.srsState,
  });

  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewAt;
  final String srsState;

  @override
  String toString() =>
      'SrsReviewResult(reps=$repetitions, ease=$easeFactor, interval=${intervalDays}d, state=$srsState)';
}

/// Servicio que implementa el algoritmo SM-2.
///
/// No tiene estado (stateless). Recibe el estado actual de la palabra
/// y la calidad de respuesta, devuelve el nuevo estado.
class SrsAlgorithm {
  const SrsAlgorithm();

  /// Constantes del algoritmo.
  static const double _minEaseFactor = 1.3;
  static const double _initialEaseFactor = 2.5;
  static const int _masteryRepetitionsThreshold = 5;

  /// Calcula el nuevo estado SRS después de un repaso.
  ///
  /// [word] estado actual de la palabra
  /// [quality] calidad de respuesta del niño
  SrsReviewResult review(LearnedWord word, ReviewQuality quality) {
    final q = quality.value;
    var repetitions = word.repetitions;
    var easeFactor = word.easeFactor;
    var intervalDays = word.intervalDays;

    // SM-2 core algorithm
    if (q < 3) {
      // Respuesta incorrecta: reiniciar repeticiones, intervalo corto
      repetitions = 0;
      intervalDays = 1; // Repasar mañana
    } else {
      // Respuesta correcta: avanzar
      repetitions += 1;
      if (repetitions == 1) {
        intervalDays = 1;
      } else if (repetitions == 2) {
        intervalDays = 3;
      } else {
        // Intervalo = anterior * easeFactor (redondeado)
        intervalDays = (intervalDays * easeFactor).round();
        // Mínimo 1 día
        if (intervalDays < 1) intervalDays = 1;
        // Máximo 180 días (6 meses)
        if (intervalDays > 180) intervalDays = 180;
      }
    }

    // Actualizar ease factor
    // EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
    easeFactor = easeFactor +
        (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (easeFactor < _minEaseFactor) easeFactor = _minEaseFactor;

    // Determinar estado SRS
    String srsState;
    if (repetitions == 0) {
      srsState = 'learning';
    } else if (repetitions >= _masteryRepetitionsThreshold) {
      srsState = 'mastered';
    } else {
      srsState = 'review';
    }

    // Calcular próxima fecha de repaso
    final nextReviewAt = DateTime.now().add(Duration(days: intervalDays));

    return SrsReviewResult(
      repetitions: repetitions,
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      nextReviewAt: nextReviewAt,
      srsState: srsState,
    );
  }

  /// Crea el estado inicial para una palabra nueva (vista por primera vez).
  LearnedWord createNewWord({
    required String childId,
    required String wordEn,
    required String wordEs,
    String? phonetic,
    String? exampleSentence,
    required String sourceStoryId,
  }) {
    final now = DateTime.now();
    return LearnedWord(
      learnedWordId: '${childId}_${_normalizeWord(wordEn)}',
      childId: childId,
      wordEn: wordEn,
      wordEs: wordEs,
      phonetic: phonetic,
      exampleSentence: exampleSentence,
      sourceStoryId: sourceStoryId,
      repetitions: 0,
      easeFactor: _initialEaseFactor,
      intervalDays: 0,
      // Nueva palabra: primera revisión inmediata (hoy mismo)
      nextReviewAt: now,
      srsState: 'new',
      timesSeen: 1,
      firstSeenAt: now,
    );
  }

  /// Normaliza una palabra para usar como ID (lowercase, sin puntuación).
  static String _normalizeWord(String word) {
    return word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
  }
}
