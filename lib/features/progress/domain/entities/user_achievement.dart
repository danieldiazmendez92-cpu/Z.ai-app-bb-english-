import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_achievement.freezed.dart';
part 'user_achievement.g.dart';

/// Instancia de un logro desbloqueado por un niño.
///
/// Se crea automáticamente por la Cloud Function `achievementEngine`
/// cuando el progreso del niño cumple los criterios.
@freezed
class UserAchievement with _$UserAchievement {
  const factory UserAchievement({
    /// ID compuesto: '{childId}_{achievementId}'
    required String userAchievementId,

    /// FK al niño.
    required String childId,

    /// FK al logro.
    required String achievementId,

    /// Fecha de desbloqueo.
    required DateTime unlockedAt,
  }) = _UserAchievement;

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
}
