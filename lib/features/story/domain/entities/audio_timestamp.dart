import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_timestamp.freezed.dart';
part 'audio_timestamp.g.dart';

/// Timestamp de una palabra en el audio narrado.
///
/// Se usa para sincronizar el resaltado palabra-a-palabra durante
/// la reproducción del audio en [ReaderScreen].
///
/// El JSON completo (array de AudioTimestamp) se descarga desde
/// Cloud Storage al abrir el cuento. No se guarda en Firestore
/// (es un archivo binario-ish, mejor en Storage).
@freezed
class AudioTimestamp with _$AudioTimestamp {
  const factory AudioTimestamp({
    /// La palabra en inglés.
    required String word,

    /// Milisegundos desde el inicio del audio donde empieza la palabra.
    required int startMs,

    /// Milisegundos desde el inicio del audio donde termina la palabra.
    required int endMs,
  }) = _AudioTimestamp;

  factory AudioTimestamp.fromJson(Map<String, dynamic> json) =>
      _$AudioTimestampFromJson(json);
}

/// Lista de timestamps para un cuento completo.
///
/// Se parsea desde el JSON descargado de Storage.
class AudioTimestamps {
  const AudioTimestamps({required this.timestamps});

  final List<AudioTimestamp> timestamps;

  /// Devuelve el índice de la palabra que se está reproduciendo
  /// en [positionMs], o null si no hay ninguna.
  int? wordIndexAt(int positionMs) {
    // Búsqueda binaria para performance (timestamps puede tener 500+ items)
    int low = 0;
    int high = timestamps.length - 1;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final ts = timestamps[mid];
      if (positionMs < ts.startMs) {
        high = mid - 1;
      } else if (positionMs > ts.endMs) {
        low = mid + 1;
      } else {
        return mid;
      }
    }
    return null;
  }

  /// Factory para parsear el JSON descargado de Storage.
  /// Formato esperado: `[{"word": "Once", "startMs": 0, "endMs": 320}, ...]`
  factory AudioTimestamps.fromJsonList(List<dynamic> json) {
    return AudioTimestamps(
      timestamps: json
          .map((e) => AudioTimestamp.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
