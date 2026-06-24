import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Categoría temática para organizar la biblioteca de cuentos.
///
/// Ejemplos: Animals, Adventure, Bedtime, Fairy Tales, Learning, Music.
/// Se cargan en el catálogo global y son de lectura pública.
@freezed
class Category with _$Category {
  const factory Category({
    /// Slug de la categoría. Ej: 'animals'
    required String categoryId,

    /// Nombre para mostrar en inglés. Ej: 'Animals'
    required String name,

    /// Nombre para mostrar en español. Ej: 'Animales'
    required String nameEs,

    /// Path al asset SVG o PNG del ícono.
    required String iconAsset,

    /// Descripción corta (opcional).
    String? description,

    /// Orden para display en la UI.
    @Default(0) int order,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  const Category._();

  /// Devuelve el nombre localizado según el idioma.
  /// Por ahora solo EN/ES.
  String nameFor(String locale) {
    return locale.startsWith('es') ? nameEs : name;
  }
}
