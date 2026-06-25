import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';
import '../../data/learned_words_repository_impl.dart';
import '../../domain/entities/learned_word.dart';
import '../../domain/repositories/learned_words_repository.dart';
import '../../domain/services/srs_algorithm.dart';

/// Estado del flujo de repaso de vocabulario.
class VocabularyReviewState {
  const VocabularyReviewState({
    this.dueWords = const [],
    this.currentIndex = 0,
    this.isShowingAnswer = false,
    this.isFlipped = false,
    this.isLoading = true,
    this.totalReviewed = 0,
    this.correctCount = 0,
    this.failure,
    this.isComplete = false,
  });

  final List<LearnedWord> dueWords;
  final int currentIndex;
  final bool isShowingAnswer;
  final bool isFlipped;
  final bool isLoading;
  final int totalReviewed;
  final int correctCount;
  final Failure? failure;
  final bool isComplete;

  /// Palabra actual (o null si no hay).
  LearnedWord? get currentWord =>
      currentIndex < dueWords.length ? dueWords[currentIndex] : null;

  /// Progreso (0-100).
  int get progress {
    if (dueWords.isEmpty) return 0;
    return ((totalReviewed / dueWords.length) * 100).round();
  }

  VocabularyReviewState copyWith({
    List<LearnedWord>? dueWords,
    int? currentIndex,
    bool? isShowingAnswer,
    bool? isFlipped,
    bool? isLoading,
    int? totalReviewed,
    int? correctCount,
    Failure? failure,
    bool? isComplete,
  }) {
    return VocabularyReviewState(
      dueWords: dueWords ?? this.dueWords,
      currentIndex: currentIndex ?? this.currentIndex,
      isShowingAnswer: isShowingAnswer ?? this.isShowingAnswer,
      isFlipped: isFlipped ?? this.isFlipped,
      isLoading: isLoading ?? this.isLoading,
      totalReviewed: totalReviewed ?? this.totalReviewed,
      correctCount: correctCount ?? this.correctCount,
      failure: failure,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

/// Controller del flujo de repaso de vocabulario.
class VocabularyReviewController
    extends StateNotifier<VocabularyReviewState> {
  VocabularyReviewController({
    required LearnedWordsRepository repository,
    required String? childId,
  })  : _repository = repository,
        _childId = childId,
        super(const VocabularyReviewState()) {
    _init();
  }

  final LearnedWordsRepository _repository;
  final String? _childId;

  Future<void> _init() async {
    if (_childId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    try {
      final due = await _repository.getDueWords(_childId!, limit: 20);
      state = state.copyWith(
        dueWords: due,
        isLoading: false,
        isComplete: due.isEmpty,
      );
    } catch (e, st) {
      state = state.copyWith(
        isLoading: false,
        failure: UnknownFailure(e.toString()),
      );
    }
  }

  /// Voltea la card para mostrar la traducción.
  void flipCard() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  /// Registra la respuesta del niño y avanza a la siguiente palabra.
  Future<void> answerQuality(ReviewQuality quality) async {
    final word = state.currentWord;
    if (word == null) return;

    try {
      await _repository.recordReview(
        learnedWordId: word.learnedWordId,
        quality: quality,
      );

      final newTotal = state.totalReviewed + 1;
      final newCorrect = quality.value >= 3
          ? state.correctCount + 1
          : state.correctCount;

      final nextIndex = state.currentIndex + 1;
      final isComplete = nextIndex >= state.dueWords.length;

      state = state.copyWith(
        currentIndex: nextIndex,
        totalReviewed: newTotal,
        correctCount: newCorrect,
        isFlipped: false,
        isShowingAnswer: false,
        isComplete: isComplete,
      );
    } catch (e, st) {
      state = state.copyWith(
          failure: UnknownFailure(e.toString()));
    }
  }

  /// Reinicia el repaso (para empezar de nuevo).
  Future<void> restart() async {
    state = const VocabularyReviewState(isLoading: true);
    await _init();
  }

  /// Salta la palabra actual (no cuenta como repaso).
  void skipWord() {
    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= state.dueWords.length;
    state = state.copyWith(
      currentIndex: nextIndex,
      isFlipped: false,
      isComplete: isComplete,
    );
  }
}

// ============================================================
// Providers
// ============================================================

final learnedWordsRepositoryProvider = Provider<LearnedWordsRepository>((ref) {
  return LearnedWordsRepositoryImpl();
});

final vocabularyReviewControllerProvider =
    StateNotifierProvider<VocabularyReviewController, VocabularyReviewState>(
        (ref) {
  final activeChild = ref.watch(activeChildProvider);
  return VocabularyReviewController(
    repository: ref.watch(learnedWordsRepositoryProvider),
    childId: activeChild?.childId,
  );
});

/// Provider: número de palabras due para repaso (badge en Home).
final dueWordsCountProvider = FutureProvider<int>((ref) async {
  final activeChild = ref.watch(activeChildProvider);
  if (activeChild == null) return 0;
  final repo = ref.watch(learnedWordsRepositoryProvider);
  final due = await repo.getDueWords(activeChild.childId, limit: 100);
  return due.length;
});

/// Provider: stats agregadas de vocabulario.
final vocabularyStatsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final activeChild = ref.watch(activeChildProvider);
  if (activeChild == null) {
    return {'new': 0, 'learning': 0, 'review': 0, 'mastered': 0, 'total': 0};
  }
  final repo = ref.watch(learnedWordsRepositoryProvider);
  final counts = await repo.getWordsCountByState(activeChild.childId);
  final total = counts.values.fold(0, (a, b) => a + b);
  return {...counts, 'total': total};
});
