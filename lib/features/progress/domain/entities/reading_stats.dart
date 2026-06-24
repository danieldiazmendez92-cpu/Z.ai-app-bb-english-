import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_stats.freezed.dart';
part 'reading_stats.g.dart';

/// Estadísticas agregadas de lectura de un niño.
///
/// Se calculan en cliente a partir de `user_progress` + `reading_sessions`.
/// En el futuro (Fase 4) se pueden pre-calcular en Cloud Functions y cachear.
@freezed
class ReadingStats with _$ReadingStats {
  const factory ReadingStats({
    /// Total de cuentos completados.
    @Default(0) int storiesCompleted,

    /// Total de cuentos iniciados (no necesariamente completados).
    @Default(0) int storiesStarted,

    /// Total de minutos leídos.
    @Default(0) int totalMinutes,

    /// Total de palabras aprendidas (vocabulario visto).
    @Default(0) int wordsLearned,

    /// Racha actual de días consecutivos leyendo (mínimo 1 sesión).
    @Default(0) int currentStreak,

    /// Racha más larga histórica.
    @Default(0) int longestStreak,

    /// Categorías exploradas (al menos 1 cuento leído).
    @Default(0) int categoriesExplored,

    /// Logros desbloqueados.
    @Default(0) int achievementsUnlocked,

    /// Última fecha de lectura (para calcular racha).
    DateTime? lastReadDate,
  }) = _ReadingStats;

  factory ReadingStats.fromJson(Map<String, dynamic> json) =>
      _$ReadingStatsFromJson(json);

  const ReadingStats._();

  /// Nivel aproximado del niño basado en cuentos completados.
  /// Cada 5 cuentos = 1 nivel.
  int get level => (storiesCompleted / 5).floor() + 1;

  /// Progreso al siguiente nivel (0-100%).
  int get levelProgress {
    final inLevel = storiesCompleted % 5;
    return (inLevel / 5 * 100).round();
  }
}
