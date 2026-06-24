import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../story/presentation/providers/story_provider.dart';
import '../../data/achievement_repository_impl.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/reading_stats.dart';
import '../../domain/entities/user_achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';

/// Estado de la pantalla Progress.
class ProgressState {
  const ProgressState({
    this.stats = const AsyncValue.loading(),
    this.allAchievements = const AsyncValue.loading(),
    this.unlockedAchievements = const AsyncValue.loading(),
    this.newlyUnlocked,
  });

  final AsyncValue<ReadingStats> stats;
  final AsyncValue<List<Achievement>> allAchievements;
  final AsyncValue<List<UserAchievement>> unlockedAchievements;

  /// Logro recién desbloqueado (para mostrar animación).
  /// Se setea cuando el stream detecta un nuevo user_achievement.
  final Achievement? newlyUnlocked;

  ProgressState copyWith({
    AsyncValue<ReadingStats>? stats,
    AsyncValue<List<Achievement>>? allAchievements,
    AsyncValue<List<UserAchievement>>? unlockedAchievements,
    Achievement? newlyUnlocked,
  }) {
    return ProgressState(
      stats: stats ?? this.stats,
      allAchievements: allAchievements ?? this.allAchievements,
      unlockedAchievements:
          unlockedAchievements ?? this.unlockedAchievements,
      newlyUnlocked: newlyUnlocked,
    );
  }
}

/// Controller de la pantalla Progress.
///
/// Maneja:
/// - Estadísticas agregadas del niño (cuentos, minutos, racha, etc.)
/// - Catálogo de logros disponibles
/// - Logros desbloqueados (stream reactivo)
/// - Detección de logros recién desbloqueados (para animación)
class ProgressController extends StateNotifier<ProgressState> {
  ProgressController({
    required AchievementRepository repository,
    required String? childId,
  })  : _repository = repository,
        _childId = childId,
        super(const ProgressState()) {
    _init();
  }

  final AchievementRepository _repository;
  final String? _childId;

  List<UserAchievement> _previousUnlocked = [];

  Future<void> _init() async {
    if (_childId == null) {
      state = state.copyWith(
        stats: const AsyncValue.data(ReadingStats()),
        allAchievements: const AsyncValue.data([]),
        unlockedAchievements: const AsyncValue.data([]),
      );
      return;
    }

    // Cargar catálogo de logros (una sola vez)
    try {
      final all = await _repository.getAllAchievements();
      state = state.copyWith(allAchievements: AsyncValue.data(all));
    } catch (e, st) {
      state = state.copyWith(
          allAchievements: AsyncValue.error(e, st));
    }

    // Cargar estadísticas
    await _loadStats();

    // Escuchar logros desbloqueados (stream reactivo)
    _repository.watchUserAchievements(_childId!).listen(
      (unlocked) {
        state = state.copyWith(
            unlockedAchievements: AsyncValue.data(unlocked));

        // Detectar nuevos desbloqueados
        if (_previousUnlocked.isNotEmpty &&
            unlocked.length > _previousUnlocked.length) {
          // Encontrar el nuevo
          final newOnes = unlocked
              .where((ua) => !_previousUnlocked
                  .any((prev) => prev.userAchievementId == ua.userAchievementId))
              .toList();

          if (newOnes.isNotEmpty) {
            // Buscar el Achievement correspondiente
            _findAndShowAnimation(newOnes.first);
          }
        }
        _previousUnlocked = unlocked;
      },
      onError: (e, st) {
        state = state.copyWith(
            unlockedAchievements: AsyncValue.error(e, st));
      },
    );
  }

  Future<void> _findAndShowAnimation(UserAchievement newUnlock) async {
    try {
      final achievement =
          await _repository.getAchievement(newUnlock.achievementId);
      state = state.copyWith(newlyUnlocked: achievement);
    } catch (_) {
      // Ignorar si no se puede cargar
    }
  }

  Future<void> _loadStats() async {
    if (_childId == null) return;
    try {
      final stats = await _repository.getReadingStats(_childId!);
      state = state.copyWith(stats: AsyncValue.data(stats));
    } catch (e, st) {
      state = state.copyWith(stats: AsyncValue.error(e, st));
    }
  }

  /// Limpia el logro recién desbloqueado (después de mostrar animación).
  void clearNewlyUnlocked() {
    state = state.copyWith(newlyUnlocked: null);
  }

  /// Refresca todo (pull to refresh).
  Future<void> refresh() async {
    await _loadStats();
  }

  /// Devuelve los logros desbloqueados como un Set de IDs (para lookup rápido).
  Set<String> get unlockedIds {
    final unlocked = state.unlockedAchievements.valueOrNull ?? [];
    return unlocked.map((ua) => ua.achievementId).toSet();
  }

  /// Devuelve los logros ordenados: desbloqueados primero, luego por threshold.
  List<Achievement> get sortedAchievements {
    final all = state.allAchievements.valueOrNull ?? [];
    final unlocked = unlockedIds;

    final sorted = [...all];
    sorted.sort((a, b) {
      final aUnlocked = unlocked.contains(a.achievementId);
      final bUnlocked = unlocked.contains(b.achievementId);
      if (aUnlocked && !bUnlocked) return -1;
      if (!aUnlocked && bUnlocked) return 1;
      return a.criteriaThreshold.compareTo(b.criteriaThreshold);
    });
    return sorted;
  }
}

// ============================================================
// Providers
// ============================================================

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepositoryImpl(
    storyRepository: ref.watch(storyRepositoryProvider),
  );
});

final progressControllerProvider =
    StateNotifierProvider<ProgressController, ProgressState>((ref) {
  final activeChild = ref.watch(activeChildProvider);
  return ProgressController(
    repository: ref.watch(achievementRepositoryProvider),
    childId: activeChild?.childId,
  );
});
