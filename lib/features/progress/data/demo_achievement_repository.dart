import 'dart:async';

import '../../../../core/config/demo_data.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/reading_stats.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

/// Repositorio de logros DEMO.
class DemoAchievementRepository implements AchievementRepository {
  DemoAchievementRepository();

  final List<UserAchievement> _unlocked = [
    // Simular que ya desbloqueó "first_story"
    UserAchievement(
      userAchievementId: 'demo-child-001_first_story',
      childId: 'demo-child-001',
      achievementId: 'first_story',
      unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final StreamController<List<UserAchievement>> _controller =
      StreamController<List<UserAchievement>>.broadcast();

  @override
  Future<List<Achievement>> getAllAchievements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DemoData.achievements;
  }

  @override
  Future<Achievement> getAchievement(String achievementId) async {
    return DemoData.achievements.firstWhere(
      (a) => a.achievementId == achievementId,
      orElse: () => throw Exception('Logro no encontrado'),
    );
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String childId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _unlocked.where((ua) => ua.childId == childId).toList();
  }

  @override
  Stream<List<UserAchievement>> watchUserAchievements(String childId) {
    Future.microtask(() {
      _controller.add(_unlocked.where((ua) => ua.childId == childId).toList());
    });
    return _controller.stream;
  }

  @override
  Future<ReadingStats> getReadingStats(String childId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simular stats: ya leyó 2 cuentos
    return DemoData.initialStats;
  }

  @override
  Future<List<DateTime>> getActiveDays(String childId, {int days = 30}) async {
    // Simular: leyó hoy, ayer, y hace 3 días
    final now = DateTime.now();
    return [
      DateTime(now.year, now.month, now.day - 3),
      DateTime(now.year, now.month, now.day - 1),
      DateTime(now.year, now.month, now.day),
    ];
  }

  /// Demo: desbloquear un logro manualmente (para probar animación).
  void unlockDemoAchievement(String achievementId, String childId) {
    final existing = _unlocked.any(
      (ua) => ua.achievementId == achievementId && ua.childId == childId,
    );
    if (existing) return;

    _unlocked.add(UserAchievement(
      userAchievementId: '${childId}_$achievementId',
      childId: childId,
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
    ));

    // Emitir a los listeners
    _controller.add(_unlocked.toList());
  }

  void dispose() {
    _controller.close();
  }
}
