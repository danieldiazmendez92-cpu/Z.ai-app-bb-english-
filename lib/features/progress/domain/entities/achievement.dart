import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Logro/insignia que el niño puede desbloquear.
///
/// Catálogo global de logros (lectura pública). Las instancias
/// desbloqueadas por cada niño se guardan en `user_achievements`.
///
/// Los logros se evalúan automáticamente en la Cloud Function
/// `achievementEngine` cuando se actualiza `user_progress`.
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    /// ID del logro. Ej: 'first_story', 'streak_7_days', 'words_learned_50'
    required String achievementId,

    /// Nombre corto para mostrar. Ej: 'First Steps'
    required String name,

    /// Descripción para mostrar. Ej: 'Read your first story'
    required String description,

    /// URL del icono (asset path o Storage URL).
    /// Para MVP usamos emojis.
    required String iconUrl,

    /// Tipo de criterio para evaluar el logro.
    /// Debe matchear con `achievementEngine` Cloud Function.
    /// Valores: 'stories_completed' | 'streak_days' | 'words_learned' |
    /// 'categories_explored' | 'time_spent_minutes' | 'perfect_comprehension'
    required String criteriaType,

    /// Umbral numérico para desbloquear.
    /// Ej: 1 (para first_story), 7 (para streak_7_days), 50 (para 50 words)
    required int criteriaThreshold,

    /// Si true, el logro es sorpresa hasta desbloquearlo
    /// (no se muestra en la grid como "bloqueado").
    @Default(false) bool isHidden,

    /// XP que otorga al desbloquear (para leaderboard futuro).
    @Default(10) int xpReward,

    /// Emoji grande para mostrar en la badge (alternativa a iconUrl).
    String? emoji,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  const Achievement._();
}
