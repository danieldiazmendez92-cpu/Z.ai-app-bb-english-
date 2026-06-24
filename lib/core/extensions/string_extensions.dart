// =============================================================================
// string_extensions.dart - Extensiones para String
// =============================================================================

/// Extensiones utilitarias para `String`.
extension StringX on String {
  /// Capitaliza la primera letra (ej: 'hola' -> 'Hola').
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// `true` si es un email valido (RFC 5322 simplificado).
  bool get isValidEmail {
    if (isEmpty) return false;
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(this);
  }

  /// `true` si cumple politica de contrasena (min 8, 1 mayus, 1 minus, 1 digito).
  bool get isStrongPassword {
    if (length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(this)) return false;
    if (!RegExp(r'[a-z]').hasMatch(this)) return false;
    if (!RegExp(r'[0-9]').hasMatch(this)) return false;
    return true;
  }

  /// Trunca a [maxChars] agregando '...' si excede.
  String truncate(int maxChars) {
    if (length <= maxChars) return this;
    return '${substring(0, maxChars)}...';
  }

  /// Convierte a slug URL-safe (ej: 'Little Red Riding Hood' -> 'little-red-riding-hood').
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// `true` si el string es null o vacio (static helper).
  static bool isBlank(String? s) => s == null || s.trim().isEmpty;

  /// Quita espacios en blanco o devuelve null si esta vacio.
  String? get nullIfBlank => trim().isEmpty ? null : trim();
}
