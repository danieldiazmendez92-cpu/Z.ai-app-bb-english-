import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/collection_names.dart';
import '../../../../core/errors/failures.dart';
import '../../../story/domain/repositories/story_repository.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/reading_stats.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

/// Implementación de [AchievementRepository] que usa Firestore.
class AchievementRepositoryImpl implements AchievementRepository {
  AchievementRepositoryImpl({
    FirebaseFirestore? firestore,
    StoryRepository? storyRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storyRepository = storyRepository;

  final FirebaseFirestore _firestore;
  final StoryRepository? _storyRepository;

  // ============================================================
  // Catálogo de logros
  // ============================================================

  @override
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.achievements)
          .orderBy('criteria_threshold')
          .get();

      if (snap.docs.isEmpty) {
        // Si no hay logros en Firestore (desarrollo), devolver defaults
        return _defaultAchievements;
      }

      return snap.docs.map(_mapDocToAchievement).toList();
    } catch (e) {
      // Fallback a defaults si hay error
      return _defaultAchievements;
    }
  }

  @override
  Future<Achievement> getAchievement(String achievementId) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.achievements)
          .doc(achievementId)
          .get();

      if (!doc.exists) {
        // Fallback a defaults
        final match = _defaultAchievements
            .where((a) => a.achievementId == achievementId)
            .firstOrNull;
        if (match != null) return match;
        throw const NotFoundFailure('Logro no encontrado');
      }

      return _mapDocToAchievement(doc);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al leer logro: $e');
    }
  }

  // ============================================================
  // Logros del niño
  // ============================================================

  @override
  Future<List<UserAchievement>> getUserAchievements(String childId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.userAchievements)
          .where('child_id', isEqualTo: childId)
          .orderBy('unlocked_at', descending: true)
          .get();

      return snap.docs.map(_mapDocToUserAchievement).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer logros del niño: $e');
    }
  }

  @override
  Stream<List<UserAchievement>> watchUserAchievements(String childId) {
    try {
      return _firestore
          .collection(CollectionNames.userAchievements)
          .where('child_id', isEqualTo: childId)
          .orderBy('unlocked_at', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_mapDocToUserAchievement).toList());
    } catch (e) {
      throw UnknownFailure('Error al observar logros: $e');
    }
  }

  // ============================================================
  // Estadísticas
  // ============================================================

  @override
  Future<ReadingStats> getReadingStats(String childId) async {
    try {
      // 1. Leer todos los progresos del niño
      final progressSnap = await _firestore
          .collection(CollectionNames.userProgress)
          .where('child_id', isEqualTo: childId)
          .get();

      final progresses = progressSnap.docs;
      final storiesCompleted =
          progresses.where((d) => d.data()['completed'] == true).length;
      final storiesStarted = progresses.length;
      final totalSeconds = progresses.fold<int>(
        0,
        (sum, doc) =>
            sum + ((doc.data()['time_spent_seconds'] as num?)?.toInt() ?? 0),
      );
      final totalMinutes = (totalSeconds / 60).round();

      // 2. Categorías exploradas (necesitamos leer los stories)
      final storyIds = progresses
          .map((d) => d.data()['story_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .cast<String>();

      final categories = <String>{};
      if (_storyRepository != null) {
        for (final id in storyIds) {
          try {
            final story = await _storyRepository!.getStory(id);
            categories.add(story.categoryId);
          } catch (_) {
            // Ignorar stories que no existan
          }
        }
      }

      // 3. Logros desbloqueados
      final achievementsSnap = await _firestore
          .collection(CollectionNames.userAchievements)
          .where('child_id', isEqualTo: childId)
          .get();
      final achievementsUnlocked = achievementsSnap.docs.length;

      // 4. CORRECCIÓN PEDAGÓGICA: palabras aprendidas con medición REAL.
      // Antes era `storiesCompleted * 8` (falso). Ahora contamos palabras
      // efectivamente marcadas como "aprendidas" por el niño.
      int wordsLearned = 0;
      try {
        final wordsSnap = await _firestore
            .collection('learned_words')
            .where('child_id', isEqualTo: childId)
            .where('is_learned', isEqualTo: true)
            .get();
        wordsLearned = wordsSnap.docs.length;
      } catch (_) {
        wordsLearned = 0;
      }

      // 5. Racha de días consecutivos
      final activeDays = await getActiveDays(childId, days: 60);
      final (currentStreak, longestStreak) = _calculateStreaks(activeDays);

      return ReadingStats(
        storiesCompleted: storiesCompleted,
        storiesStarted: storiesStarted,
        totalMinutes: totalMinutes,
        wordsLearned: wordsLearned,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        categoriesExplored: categories.length,
        achievementsUnlocked: achievementsUnlocked,
        lastReadDate: activeDays.isNotEmpty ? activeDays.last : null,
      );
    } catch (e) {
      throw UnknownFailure('Error al calcular estadísticas: $e');
    }
  }

  @override
  Future<List<DateTime>> getActiveDays(String childId,
      {int days = 30}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));

      final snap = await _firestore
          .collection(CollectionNames.userProgress)
          .where('child_id', isEqualTo: childId)
          .get();

      final days = <DateTime>{};
      for (final doc in snap.docs) {
        final lastRead = doc.data()['last_read_at'] as Timestamp?;
        if (lastRead != null) {
          final date = lastRead.toDate();
          if (date.isAfter(since)) {
            // Normalizar a medianoche para comparar solo fecha
            days.add(DateTime(date.year, date.month, date.day));
          }
        }
      }

      final sorted = days.toList()..sort();
      return sorted;
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // Cálculo de rachas
  // ============================================================

  /// Calcula racha actual y más larga histórica.
  (int current, int longest) _calculateStreaks(List<DateTime> activeDays) {
    if (activeDays.isEmpty) return (0, 0);

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Calcular racha actual (hacia atrás desde hoy o ayer)
    int current = 0;
    var checkDate = activeDays.contains(todayDate)
        ? todayDate
        : (activeDays.contains(yesterdayDate) ? yesterdayDate : null);

    if (checkDate != null) {
      while (activeDays.contains(checkDate)) {
        current++;
        checkDate = checkDate!.subtract(const Duration(days: 1));
      }
    }

    // Calcular racha más larga histórica
    int longest = 0;
    int streak = 0;
    DateTime? prev;
    for (final day in activeDays) {
      if (prev == null) {
        streak = 1;
      } else {
        final diff = day.difference(prev).inDays;
        if (diff == 1) {
          streak++;
        } else {
          streak = 1;
        }
      }
      longest = longest > streak ? longest : streak;
      prev = day;
    }

    return (current, longest);
  }

  // ============================================================
  // Helpers de mapeo
  // ============================================================

  Achievement _mapDocToAchievement(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Achievement(
      achievementId: d['achievement_id'] as String? ?? doc.id,
      name: d['name'] as String? ?? 'Logro',
      description: d['description'] as String? ?? '',
      iconUrl: d['icon_url'] as String? ?? '⭐',
      criteriaType: d['criteria_type'] as String? ?? 'stories_completed',
      criteriaThreshold:
          (d['criteria_threshold'] as num?)?.toInt() ?? 1,
      isHidden: d['is_hidden'] as bool? ?? false,
      xpReward: (d['xp_reward'] as num?)?.toInt() ?? 10,
      emoji: d['emoji'] as String?,
    );
  }

  UserAchievement _mapDocToUserAchievement(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return UserAchievement(
      userAchievementId: d['user_achievement_id'] as String? ?? doc.id,
      childId: d['child_id'] as String? ?? '',
      achievementId: d['achievement_id'] as String? ?? '',
      unlockedAt: (d['unlocked_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  // ============================================================
  // Logros por defecto (si Firestore está vacío)
  // ============================================================

  static const List<Achievement> _defaultAchievements = [
    Achievement(
      achievementId: 'first_story',
      name: 'First Steps',
      description: 'Leíste tu primer cuento',
      iconUrl: '👶',
      emoji: '👶',
      criteriaType: 'stories_completed',
      criteriaThreshold: 1,
      xpReward: 10,
    ),
    Achievement(
      achievementId: 'stories_5',
      name: 'Bookworm',
      description: 'Completaste 5 cuentos',
      iconUrl: '📖',
      emoji: '📖',
      criteriaType: 'stories_completed',
      criteriaThreshold: 5,
      xpReward: 25,
    ),
    Achievement(
      achievementId: 'stories_10',
      name: 'Story Explorer',
      description: 'Completaste 10 cuentos',
      iconUrl: '🧭',
      emoji: '🧭',
      criteriaType: 'stories_completed',
      criteriaThreshold: 10,
      xpReward: 50,
    ),
    Achievement(
      achievementId: 'stories_25',
      name: 'Master Reader',
      description: 'Completaste 25 cuentos',
      iconUrl: '🏆',
      emoji: '🏆',
      criteriaType: 'stories_completed',
      criteriaThreshold: 25,
      xpReward: 100,
    ),
    Achievement(
      achievementId: 'streak_3_days',
      name: 'On Fire',
      description: 'Leíste 3 días seguidos',
      iconUrl: '🔥',
      emoji: '🔥',
      criteriaType: 'streak_days',
      criteriaThreshold: 3,
      xpReward: 20,
    ),
    Achievement(
      achievementId: 'streak_7_days',
      name: 'Week Warrior',
      description: 'Leíste 7 días seguidos',
      iconUrl: '⚔️',
      emoji: '⚔️',
      criteriaType: 'streak_days',
      criteriaThreshold: 7,
      xpReward: 50,
    ),
    Achievement(
      achievementId: 'streak_30_days',
      name: 'Unstoppable',
      description: 'Leíste 30 días seguidos',
      iconUrl: '💎',
      emoji: '💎',
      criteriaType: 'streak_days',
      criteriaThreshold: 30,
      xpReward: 200,
      isHidden: true,
    ),
    Achievement(
      achievementId: 'words_50',
      name: 'Word Collector',
      description: 'Aprendiste 50 palabras nuevas',
      iconUrl: '📚',
      emoji: '📚',
      criteriaType: 'words_learned',
      criteriaThreshold: 50,
      xpReward: 40,
    ),
    Achievement(
      achievementId: 'categories_3',
      name: 'Explorer',
      description: 'Exploraste 3 categorías diferentes',
      iconUrl: '🗺️',
      emoji: '🗺️',
      criteriaType: 'categories_explored',
      criteriaThreshold: 3,
      xpReward: 30,
    ),
    Achievement(
      achievementId: 'time_60_min',
      name: 'Time Traveler',
      description: 'Leíste por 60 minutos en total',
      iconUrl: '⏰',
      emoji: '⏰',
      criteriaType: 'time_spent_minutes',
      criteriaThreshold: 60,
      xpReward: 35,
    ),
  ];
}

// Extensión temporal hasta migrar a Dart 3
extension _FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
