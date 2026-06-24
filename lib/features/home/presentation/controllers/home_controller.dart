import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../child_profile/presentation/controllers/child_profile_controller.dart';
import '../../../progress/domain/entities/user_progress.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/repositories/story_repository.dart';
import '../../../story/presentation/providers/story_provider.dart';

/// Estado de la pantalla Home.
class HomeState {
  const HomeState({
    this.recommended = const AsyncValue.loading(),
    this.continueReading = const AsyncValue.loading(),
  });

  final AsyncValue<List<Story>> recommended;
  final AsyncValue<List<UserProgress>> continueReading;

  HomeState copyWith({
    AsyncValue<List<Story>>? recommended,
    AsyncValue<List<UserProgress>>? continueReading,
  }) {
    return HomeState(
      recommended: recommended ?? this.recommended,
      continueReading: continueReading ?? this.continueReading,
    );
  }
}

/// Controller de la pantalla Home.
class HomeController extends StateNotifier<HomeState> {
  HomeController({
    required StoryRepository repository,
    required String? activeChildId,
    required int activeChildAge,
    required List<String> activeChildInterests,
  })  : _repository = repository,
        _activeChildId = activeChildId,
        _activeChildAge = activeChildAge,
        _activeChildInterests = activeChildInterests,
        super(const HomeState()) {
    _loadAll();
  }

  final StoryRepository _repository;
  final String? _activeChildId;
  final int _activeChildAge;
  final List<String> _activeChildInterests;

  Future<void> _loadAll() async {
    await Future.wait([
      _loadRecommended(),
      _loadContinueReading(),
    ]);
  }

  Future<void> _loadRecommended() async {
    try {
      final stories = await _repository.getRecommendedStories(
        age: _activeChildAge,
        interests: _activeChildInterests,
      );
      state = state.copyWith(recommended: AsyncValue.data(stories));
    } on Failure catch (e, st) {
      state = state.copyWith(recommended: AsyncValue.error(e, st));
    } catch (e, st) {
      state = state.copyWith(
          recommended: AsyncValue.error(UnknownFailure(e.toString()), st));
    }
  }

  Future<void> _loadContinueReading() async {
    if (_activeChildId == null) {
      state = state.copyWith(continueReading: const AsyncValue.data([]));
      return;
    }
    try {
      final progress = await _repository.getInProgressStories(_activeChildId!);
      state = state.copyWith(continueReading: AsyncValue.data(progress));
    } on Failure catch (e, st) {
      state = state.copyWith(continueReading: AsyncValue.error(e, st));
    } catch (e, st) {
      state = state.copyWith(
          continueReading:
              AsyncValue.error(UnknownFailure(e.toString()), st));
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  final activeChild = ref.watch(activeChildProvider);
  final repo = ref.watch(storyRepositoryProvider);

  return HomeController(
    repository: repo,
    activeChildId: activeChild?.childId,
    activeChildAge: activeChild?.age ?? 4,
    activeChildInterests: activeChild?.interests ?? const [],
  );
});
