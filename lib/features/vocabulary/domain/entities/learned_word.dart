import 'package:freezed_annotation/freezed_annotation.dart';

part 'learned_word.freezed.dart';
part 'learned_word.g.dart';

/// Estado de una palabra que el niño está aprendiendo.
///
/// Usa el algoritmo SM-2 simplificado para repetición espaciada.
/// Cada vez que el niño ve la palabra, se le pregunta "¿La sabés?"
/// y según la respuesta se ajusta el intervalo.
///
/// Estados posibles:
/// - new: palabra nueva, nunca repasada
/// - learning: en proceso de aprendizaje (intervalos cortos)
/// - review: en repaso espaciado (intervalos largos)
/// - mastered: aprendida (no aparece más en repaso)
@freezed
class LearnedWord with _$LearnedWord {
  const factory LearnedWord({
    /// ID: '{childId}_{wordEn_normalized}'
    required String learnedWordId,

    required String childId,

    /// Palabra en inglés (normalizada: lowercase, sin puntuación).
    required String wordEn,

    /// Traducción al español (denormalizada de VocabularyWord).
    required String wordEs,

    /// Fonética IPA (denormalizada).
    String? phonetic,

    /// Oración de ejemplo (denormalizada).
    String? exampleSentence,

    /// ID del cuento donde se vio por primera vez.
    required String sourceStoryId,

    /// SM-2 algorithm fields:
    /// Número de repeticiones exitosas consecutivas.
    @Default(0) int repetitions,

    /// Ease factor (1.3 a 2.5+. Default 2.5 para palabras nuevas).
    @Default(2.5) double easeFactor,

    /// Intervalo en días hasta el próximo repaso.
    @Default(0) int intervalDays,

    /// Fecha del próximo repaso (UTC).
    required DateTime nextReviewAt,

    /// Estado SRS.
    /// 'new' | 'learning' | 'review' | 'mastered'
    @Default('new') String srsState,

    /// Cuántas veces el niño vio esta palabra (en cualquier contexto).
    @Default(0) int timesSeen,

    /// Cuántas veces el niño respondió "sí la sé" en repaso.
    @Default(0) int correctReviews,

    /// Cuántas veces el niño respondió "no la sé" en repaso.
    @Default(0) int incorrectReviews,

    /// Fecha de la primera vez que vio la palabra.
    required DateTime firstSeenAt,

    /// Fecha del último repaso (si aplica).
    DateTime? lastReviewedAt,
  }) = _LearnedWord;

  factory LearnedWord.fromJson(Map<String, dynamic> json) =>
      _$LearnedWordFromJson(json);

  const LearnedWord._();

  /// True si la palabra está due para repaso hoy.
  bool get isDueForReview =>
      DateTime.now().isAfter(nextReviewAt) && srsState != 'mastered';

  /// True si la palabra ya está aprendida.
  bool get isMastered => srsState == 'mastered';

  /// Calidad de memorización (0-100%) basada en stats.
  int get masteryPct {
    if (timesSeen == 0) return 0;
    final correctRate = correctReviews / timesSeen;
    return (correctRate * 100).round();
  }
}
