import '../entities/achievement.dart';
import '../entities/reading_stats.dart';
import '../entities/user_achievement.dart';

/// Contrato del repositorio de logros y estadísticas.
///
/// Maneja:
/// - Catálogo global de logros (lectura pública)
/// - Logros desbloqueados por cada niño
/// - Estadísticas agregadas de lectura
abstract class AchievementRepository {
  // ============================================================
  // Catálogo de logros
  // ============================================================

  /// Obtiene todos los logros del catálogo (ordenados por criteriaThreshold).
  Future<List<Achievement>> getAllAchievements();

  /// Obtiene un logro específico por ID.
  Future<Achievement> getAchievement(String achievementId);

  // ============================================================
  // Logros del niño
  // ============================================================

  /// Obtiene todos los logros desbloqueados por el niño.
  Future<List<UserAchievement>> getUserAchievements(String childId);

  /// Stream reactivo de logros desbloqueados por el niño.
  /// Se actualiza cuando la Cloud Function crea nuevos.
  Stream<List<UserAchievement>> watchUserAchievements(String childId);

  // ============================================================
  // Estadísticas
  // ============================================================

  /// Calcula estadísticas agregadas del niño.
  /// Lee de `user_progress` y `user_achievements`.
  Future<ReadingStats> getReadingStats(String childId);

  /// Obtiene los últimos N días con actividad (para calendario de racha).
  /// Retorna lista de fechas con al menos una sesión de lectura.
  Future<List<DateTime>> getActiveDays(String childId, {int days = 30});
}
