import 'package:freezed_annotation/freezed_annotation.dart';

part 'comprehension_question.freezed.dart';
part 'comprehension_question.g.dart';

/// Pregunta de comprensión lectora generada por Gemini.
///
/// Se muestra al final del cuento en [StoryEndScreen].
/// Si el niño responde bien, gana XP extra. Si mal, se le
/// da otra oportunidad sin penalización.
@freezed
class ComprehensionQuestion with _$ComprehensionQuestion {
  const factory ComprehensionQuestion({
    required String questionId,

    /// FK al story.
    required String storyId,

    /// Pregunta en inglés. Ej: 'Why did the wolf want to eat Little Red?'
    required String questionText,

    /// 4 opciones de respuesta (en inglés).
    required List<String> options,

    /// Índice de la opción correcta (0-3).
    required int correctIndex,

    /// Explicación que se muestra si el niño se equivoca.
    required String explanation,
  }) = _ComprehensionQuestion;

  factory ComprehensionQuestion.fromJson(Map<String, dynamic> json) =>
      _$ComprehensionQuestionFromJson(json);

  const ComprehensionQuestion._();

  /// True si [index] es la respuesta correcta.
  bool isCorrect(int index) => index == correctIndex;
}
