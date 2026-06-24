import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

/// Palabra clave de un cuento, con traducción y pronunciación.
///
/// Se genera automáticamente con Gemini en la ingesta del cuento.
/// El niño puede tocar una palabra destacada del texto para ver
/// su traducción, fonética y ejemplo de uso.
@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String wordId,

    /// FK al story.
    required String storyId,

    /// Palabra en inglés. Ej: 'wolf'
    required String wordEn,

    /// Traducción al español. Ej: 'lobo'
    required String wordEs,

    /// Fonética IPA. Ej: '/wʊlf/'
    String? phonetic,

    /// Oración de ejemplo en inglés.
    String? exampleSentence,

    /// Traducción de la oración de ejemplo.
    String? exampleTranslation,

    /// URL de imagen ilustrativa (opcional).
    String? imageUrl,

    /// Si true, la palabra se resalta en el texto del cuento
    /// y es tappable para abrir el popup de vocabulario.
    @Default(true) bool isHighlighted,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}
