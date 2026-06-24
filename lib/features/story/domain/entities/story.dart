import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

/// Cuento del catálogo. Creado en proceso admin, no por usuarios.
///
/// Cada cuento tiene:
/// - Texto en inglés dividido en secciones (story_sections)
/// - Traducción al español (por sección)
/// - Audio narrado en inglés (MP3 en Storage)
/// - Timestamps por palabra (JSON en Storage, para resaltado sincronizado)
/// - Vocabulario destacado (subcolección `vocabulary`)
/// - Preguntas de comprensión (subcolección `comprehension_questions`)
@freezed
class Story with _$Story {
  const factory Story({
    /// Slug del cuento. Ej: 'little-red-riding-hood'
    required String storyId,

    /// Título en inglés. Ej: 'Little Red Riding Hood'
    required String title,

    /// ID de la categoría. FK a `categories`.
    required String categoryId,

    /// Edad mínima recomendada (2-7).
    required int minAge,

    /// Edad máxima recomendada (2-7).
    required int maxAge,

    /// Duración estimada en minutos (basada en el audio TTS).
    required int durationMinutes,

    /// URL del audio MP3 narrado en inglés (Cloud Storage).
    required String audioUrlEn,

    /// URL del audio MP3 narrado en español (opcional, premium).
    String? audioUrlEs,

    /// URL del JSON con timestamps por palabra (para resaltado sincronizado).
    String? timestampsJsonUrl,

    /// URL de la imagen de portada (Cloud Storage o asset).
    required String coverImageUrl,

    /// Atribución de la fuente. Ej: 'Brothers Grimm, public domain'
    required String sourceAttribution,

    /// URL a la fuente original (Project Gutenberg, etc.).
    required String sourceUrl,

    /// False hasta que el admin aprueba el cuento.
    @Default(false) bool published,

    /// Tags para filtrado y recomendación.
    /// Ej: ['classic', 'animals', 'adventure']
    @Default(<String>[]) List<String> tags,

    required DateTime createdAt,

    DateTime? publishedAt,

    /// Contador de vistas (denormalizado para ordenar por popularidad).
    @Default(0) int viewCount,

    /// Rating promedio (0-5, null si no tiene suficientes votos).
    double? avgRating,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  const Story._();

  /// True si el cuento está publicado y visible en la app.
  bool get isPublished => published;

  /// Rango de edad como string. Ej: '2-4 años'
  String get ageRange => '$minAge-$maxAge años';

  /// True si el cuento tiene audio en español (feature premium).
  bool get hasSpanishAudio => audioUrlEs != null;
}
