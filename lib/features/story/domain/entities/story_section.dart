import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_section.freezed.dart';
part 'story_section.g.dart';

/// Una página/escena de un cuento.
///
/// El cuento se divide en secciones para:
/// - Mostrar ilustración por escena
/// - Navegar página a página
/// - Calcular progreso de lectura
@freezed
class StorySection with _$StorySection {
  const factory StorySection({
    required String sectionId,

    /// FK al story. Igual al parent doc ID en Firestore.
    required String storyId,

    /// Orden de la sección (1, 2, 3...).
    required int order,

    /// Texto en inglés de esta sección.
    required String textEn,

    /// Traducción al español de esta sección.
    required String textEs,

    /// URL de la ilustración de esta escena (opcional).
    String? illustrationUrl,
  }) = _StorySection;

  factory StorySection.fromJson(Map<String, dynamic> json) =>
      _$StorySectionFromJson(json);
}
