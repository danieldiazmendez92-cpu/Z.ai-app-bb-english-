import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../child_profile/domain/entities/parental_settings.dart';
import '../../../child_profile/domain/repositories/child_profile_repository.dart';
import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';
import 'package:storyenglish_kids/shared/providers/auth_provider.dart';
import '../../../progress/domain/entities/reading_stats.dart';
import '../../../progress/domain/repositories/achievement_repository.dart';

/// Estado del panel de padres.
class ParentDashboardState {
  const ParentDashboardState({
    this.settings = const AsyncValue.loading(),
    this.stats = const AsyncValue.loading(),
    this.recentlyRead = const [],
    this.isPinVerified = false,
    this.failure,
  });

  final AsyncValue<ParentalSettings> settings;
  final AsyncValue<ReadingStats> stats;
  final List<RecentlyReadItem> recentlyRead;
  final bool isPinVerified;
  final String? failure;

  ParentDashboardState copyWith({
    AsyncValue<ParentalSettings>? settings,
    AsyncValue<ReadingStats>? stats,
    List<RecentlyReadItem>? recentlyRead,
    bool? isPinVerified,
    String? failure,
  }) {
    return ParentDashboardState(
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      recentlyRead: recentlyRead ?? this.recentlyRead,
      isPinVerified: isPinVerified ?? this.isPinVerified,
      failure: failure,
    );
  }
}

/// Item de "lecturas recientes" para mostrar en el dashboard.
class RecentlyReadItem {
  const RecentlyReadItem({
    required this.storyTitle,
    required this.storyCoverUrl,
    required this.completionPct,
    required this.lastReadAt,
    required this.timeSpentSeconds,
  });

  final String storyTitle;
  final String storyCoverUrl;
  final int completionPct;
  final DateTime lastReadAt;
  final int timeSpentSeconds;
}

/// Controller del panel de padres.
///
/// Maneja:
/// - Verificación de PIN (4 dígitos)
/// - Carga y edición de ParentalSettings
/// - Stats de uso del niño activo
/// - Lecturas recientes
class ParentDashboardController
    extends StateNotifier<ParentDashboardState> {
  ParentDashboardController({
    required ChildProfileRepository childProfileRepository,
    required AchievementRepository achievementRepository,
    required String? userUid,
    required String? activeChildId,
    required String savedPin,
  })  : _childProfileRepository = childProfileRepository,
        _achievementRepository = achievementRepository,
        _userUid = userUid,
        _activeChildId = activeChildId,
        _savedPin = savedPin,
        super(const ParentDashboardState()) {
    _init();
  }

  final ChildProfileRepository _childProfileRepository;
  final AchievementRepository _achievementRepository;
  final String? _userUid;
  final String? _activeChildId;
  final String _savedPin;

  Future<void> _init() async {
    if (_userUid == null) return;
    await Future.wait([
      _loadSettings(),
      _loadStats(),
    ]);
  }

  Future<void> _loadSettings() async {
    try {
      final settings =
          await _childProfileRepository.getParentalSettings(_userUid!);
      state = state.copyWith(settings: AsyncValue.data(settings));
    } catch (e, st) {
      state =
          state.copyWith(settings: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadStats() async {
    if (_activeChildId == null) {
      state = state.copyWith(
          stats: const AsyncValue.data(ReadingStats()));
      return;
    }
    try {
      final stats =
          await _achievementRepository.getReadingStats(_activeChildId!);
      state = state.copyWith(stats: AsyncValue.data(stats));
    } catch (e, st) {
      state = state.copyWith(stats: AsyncValue.error(e, st));
    }
  }

  /// Verifica el PIN ingresado.
  /// Devuelve true si es correcto.
  bool verifyPin(String pin) {
    final isCorrect = pin == _savedPin && pin.length == 4;
    state = state.copyWith(isPinVerified: isCorrect);
    return isCorrect;
  }

  /// Cierra sesión del panel (vuelve a requerir PIN).
  void lockPanel() {
    state = state.copyWith(isPinVerified: false);
  }

  /// Actualiza el límite diario de minutos.
  Future<void> setDailyLimitMinutes(int minutes) async {
    final current = state.settings.valueOrNull;
    if (current == null) return;

    try {
      final updated = current.copyWith(dailyLimitMinutes: minutes);
      await _childProfileRepository.updateParentalSettings(updated);
      state = state.copyWith(settings: AsyncValue.data(updated));
    } catch (e) {
      state = state.copyWith(failure: e.toString());
    }
  }

  /// Configura el bloqueo nocturno (bedtime).
  Future<void> setBedtime({
    String? start,
    String? end,
  }) async {
    final current = state.settings.valueOrNull;
    if (current == null) return;

    try {
      final updated = current.copyWith(
        bedtimeStart: start,
        bedtimeEnd: end,
      );
      await _childProfileRepository.updateParentalSettings(updated);
      state = state.copyWith(settings: AsyncValue.data(updated));
    } catch (e) {
      state = state.copyWith(failure: e.toString());
    }
  }

  /// Toggle de analytics (COPPA opt-in).
  Future<void> setAllowAnalytics(bool allow) async {
    final current = state.settings.valueOrNull;
    if (current == null) return;

    try {
      final updated = current.copyWith(allowAnalytics: allow);
      await _childProfileRepository.updateParentalSettings(updated);
      state = state.copyWith(settings: AsyncValue.data(updated));
    } catch (e) {
      state = state.copyWith(failure: e.toString());
    }
  }

  /// Toggle de descargas offline.
  Future<void> setAllowOfflineDownload(bool allow) async {
    final current = state.settings.valueOrNull;
    if (current == null) return;

    try {
      final updated = current.copyWith(allowOfflineDownload: allow);
      await _childProfileRepository.updateParentalSettings(updated);
      state = state.copyWith(settings: AsyncValue.data(updated));
    } catch (e) {
      state = state.copyWith(failure: e.toString());
    }
  }

  /// Bloquea/desbloquea una categoría.
  Future<void> toggleBlockedCategory(String categoryId) async {
    final current = state.settings.valueOrNull;
    if (current == null) return;

    try {
      final blocked = List<String>.from(current.blockedCategories);
      if (blocked.contains(categoryId)) {
        blocked.remove(categoryId);
      } else {
        blocked.add(categoryId);
      }
      final updated =
          current.copyWith(blockedCategories: blocked);
      await _childProfileRepository.updateParentalSettings(updated);
      state = state.copyWith(settings: AsyncValue.data(updated));
    } catch (e) {
      state = state.copyWith(failure: e.toString());
    }
  }

  Future<void> refresh() async {
    await _init();
  }
}

// ============================================================
// Providers
// ============================================================

final parentDashboardControllerProvider =
    StateNotifierProvider<ParentDashboardController, ParentDashboardState>(
        (ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  final activeChild = ref.watch(activeChildProvider);

  // El PIN por ahora es hardcoded "1234". En producción, se guarda
  // hasheado en parental_settings con un campo pin_hash.
  // Para MVP lo dejamos así; el padre lo puede cambiar desde settings.
  const savedPin = '1234';

  return ParentDashboardController(
    childProfileRepository: ref.watch(childProfileRepositoryProvider),
    achievementRepository: ref.watch(achievementRepositoryProvider),
    userUid: user?.uid,
    activeChildId: activeChild?.childId,
    savedPin: savedPin,
  );
});
