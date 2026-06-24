import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../domain/entities/audio_timestamp.dart';
import '../../domain/entities/comprehension_question.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_section.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/story_repository.dart';
import '../../presentation/providers/story_provider.dart';
import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';

/// Estado del Reader.
class ReaderState {
  const ReaderState({
    this.story,
    this.sections = const [],
    this.vocabulary = const [],
    this.questions = const [],
    this.timestamps,
    this.isLoading = true,
    this.failure,
    this.currentSectionIndex = 0,
    this.currentWordIndex,
    this.isPlaying = false,
    this.positionMs = 0,
    this.durationMs = 0,
    this.speed = 1.0,
  });

  final Story? story;
  final List<StorySection> sections;
  final List<VocabularyWord> vocabulary;
  final List<ComprehensionQuestion> questions;
  final AudioTimestamps? timestamps;

  final bool isLoading;
  final Failure? failure;

  final int currentSectionIndex;
  final int? currentWordIndex;

  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final double speed;

  ReaderState copyWith({
    Story? story,
    List<StorySection>? sections,
    List<VocabularyWord>? vocabulary,
    List<ComprehensionQuestion>? questions,
    AudioTimestamps? timestamps,
    bool? isLoading,
    Failure? failure,
    int? currentSectionIndex,
    int? currentWordIndex,
    bool? isPlaying,
    int? positionMs,
    int? durationMs,
    double? speed,
  }) {
    return ReaderState(
      story: story ?? this.story,
      sections: sections ?? this.sections,
      vocabulary: vocabulary ?? this.vocabulary,
      questions: questions ?? this.questions,
      timestamps: timestamps ?? this.timestamps,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      speed: speed ?? this.speed,
    );
  }
}

/// Controller del Reader.
///
/// Maneja:
/// - Carga del cuento completo (sections + vocab + questions + timestamps)
/// - Reproducción de audio con [AudioPlayerService]
/// - Resaltado palabra-a-palabra según timestamps
/// - Tracking de progreso (cada 10s)
/// - Navegación entre secciones
class ReaderController extends StateNotifier<ReaderState> {
  ReaderController({
    required StoryRepository repository,
    required AudioPlayerService audioService,
    required String storyId,
    required String? childId,
  })  : _repository = repository,
        _audioService = audioService,
        _storyId = storyId,
        _childId = childId,
        super(const ReaderState()) {
    _init();
  }

  final StoryRepository _repository;
  final AudioPlayerService _audioService;
  final String _storyId;
  final String? _childId;

  StreamSubscription? _positionSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _completedSub;
  Timer? _progressTimer;

  Future<void> _init() async {
    try {
      // Cargar todo en paralelo
      final results = await Future.wait([
        _repository.getStory(_storyId),
        _repository.getStorySections(_storyId),
        _repository.getStoryVocabulary(_storyId),
        _repository.getComprehensionQuestions(_storyId),
        _repository.getAudioTimestamps(_storyId),
      ]);

      final story = results[0] as Story;
      final sections = results[1] as List<StorySection>;
      final vocabulary = results[2] as List<VocabularyWord>;
      final questions = results[3] as List<ComprehensionQuestion>;
      final timestamps = results[4] as AudioTimestamps?;

      // Configurar audio
      if (story.audioUrlEn.isNotEmpty) {
        // Convertir AudioTimestamps → List<AudioWordTimestamp> para el service
        final audioTs = timestamps?.timestamps
                .map((t) => AudioWordTimestamp(
                      word: t.word,
                      startMs: t.startMs,
                      endMs: t.endMs,
                    ))
                .toList() ??
            const [];

        await _audioService.load(
          audioUrl: story.audioUrlEn,
          timestamps: audioTs,
        );
        _setupAudioListeners();

        final duration = await _audioService.durationMs;
        state = state.copyWith(durationMs: duration);
      }

      state = state.copyWith(
        story: story,
        sections: sections,
        vocabulary: vocabulary,
        questions: questions,
        timestamps: timestamps,
        isLoading: false,
      );

      _startProgressTracking();
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, failure: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: UnknownFailure(e.toString()),
      );
    }
  }

  void _setupAudioListeners() {
    _positionSub = _audioService.onPositionChangedMs.listen((positionMs) {
      // Usar el servicio para obtener el índice de palabra (más eficiente)
      final wordIndex = _audioService.wordIndexAtMs(positionMs);

      state = state.copyWith(
        positionMs: positionMs,
        currentWordIndex: wordIndex >= 0 ? wordIndex : null,
      );
    });

    _playingSub = _audioService.onPlayingChanged.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });

    _completedSub = _audioService.onCompleted.listen((_) {
      _onAudioCompleted();
    });
  }

  void _onAudioCompleted() {
    if (_childId != null && state.story != null) {
      _repository.markAsCompleted(
        childId: _childId!,
        storyId: _storyId,
      );
    }
    state = state.copyWith(isPlaying: false, positionMs: 0);
  }

  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (_childId == null || state.story == null) return;

    final completionPct = state.durationMs > 0
        ? ((state.positionMs / state.durationMs) * 100).round().clamp(0, 100)
        : 0;

    await _repository.updateProgress(
      childId: _childId!,
      storyId: _storyId,
      storyTitle: state.story!.title,
      storyCoverUrl: state.story!.coverImageUrl,
      completionPct: completionPct,
      timeSpentSeconds: 10,
      lastSectionOrder: state.currentSectionIndex,
    );
  }

  // ============================================================
  // Controles de audio
  // ============================================================

  Future<void> play() => _audioService.play();
  Future<void> pause() => _audioService.pause();

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekToMs(int ms) => _audioService.seekToMs(ms);

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  Future<void> rewind10s() async {
    final newPos = (state.positionMs - 10000).clamp(0, state.durationMs);
    await _audioService.seekToMs(newPos);
  }

  Future<void> forward10s() async {
    final newPos = (state.positionMs + 10000).clamp(0, state.durationMs);
    await _audioService.seekToMs(newPos);
  }

  // ============================================================
  // Navegación entre secciones
  // ============================================================

  void goToSection(int index) {
    if (index < 0 || index >= state.sections.length) return;
    state = state.copyWith(currentSectionIndex: index);
  }

  void nextSection() {
    if (state.currentSectionIndex < state.sections.length - 1) {
      goToSection(state.currentSectionIndex + 1);
    }
  }

  void previousSection() {
    if (state.currentSectionIndex > 0) {
      goToSection(state.currentSectionIndex - 1);
    }
  }

  /// Busca una palabra en el vocabulario del cuento.
  VocabularyWord? findVocabularyWord(String word) {
    final lower = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    for (final v in state.vocabulary) {
      if (v.isHighlighted && v.wordEn.toLowerCase() == lower) {
        return v;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playingSub?.cancel();
    _completedSub?.cancel();
    _progressTimer?.cancel();
    _audioService.stop();
    super.dispose();
  }
}

// ============================================================
// Providers
// ============================================================

/// Provider family: una instancia de ReaderController por storyId.
final readerControllerProvider =
    StateNotifierProvider.family<ReaderController, ReaderState, String>(
        (ref, storyId) {
  final activeChild = ref.watch(activeChildProvider);

  return ReaderController(
    repository: ref.watch(storyRepositoryProvider),
    audioService: ref.watch(audioPlayerServiceProvider),
    storyId: storyId,
    childId: activeChild?.childId,
  );
});

/// Provider del AudioPlayerService (una instancia por reader).
/// En demo mode se overridea con DemoAudioPlayerService.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});
