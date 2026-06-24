import 'dart:async';

import '../../../../core/config/demo_data.dart';
import '../../../../core/errors/failures.dart';
import '../../../progress/domain/entities/user_progress.dart';
import '../../domain/entities/audio_timestamp.dart';
import '../../domain/entities/comprehension_question.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_section.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/story_repository.dart';

/// Repositorio de cuentos DEMO.
///
/// Usa [DemoData] con 5 cuentos hardcodeados.
/// El progreso se mantiene en memoria (se pierde al cerrar la app).
class DemoStoryRepository implements StoryRepository {
  DemoStoryRepository();

  final List<UserProgress> _progress = [];

  @override
  Future<List<Story>> getPublishedStories({
    String? categoryId,
    int? age,
    String? tag,
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var stories = DemoData.stories.where((s) => s.published).toList();

    if (categoryId != null) {
      stories = stories.where((s) => s.categoryId == categoryId).toList();
    }
    if (age != null) {
      stories = stories.where((s) => s.minAge <= age && s.maxAge >= age).toList();
    }
    if (tag != null) {
      stories = stories.where((s) => s.tags.contains(tag)).toList();
    }

    return stories.take(limit).toList();
  }

  @override
  Future<Story> getStory(String storyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DemoData.stories.firstWhere(
      (s) => s.storyId == storyId,
      orElse: () => throw const NotFoundFailure('Cuento no encontrado'),
    );
  }

  @override
  Future<List<Story>> searchStories(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return DemoData.stories
        .where((s) => s.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<Story>> getRecommendedStories({
    required int age,
    required List<String> interests,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Filtrar por edad + ordenar por popularidad + filtrar por intereses
    var stories = DemoData.stories
        .where((s) => s.published && s.minAge <= age && s.maxAge >= age)
        .toList();
    stories.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return stories.take(limit).toList();
  }

  @override
  Future<List<StorySection>> getStorySections(String storyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DemoData.storySections[storyId] ?? [];
  }

  @override
  Future<List<VocabularyWord>> getStoryVocabulary(String storyId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return DemoData.storyVocabulary[storyId] ?? [];
  }

  @override
  Future<List<ComprehensionQuestion>> getComprehensionQuestions(
      String storyId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return DemoData.storyQuestions[storyId] ?? [];
  }

  @override
  Future<AudioTimestamps?> getAudioTimestamps(String storyId) async {
    return DemoData.storyTimestamps[storyId];
  }

  @override
  Future<UserProgress?> getProgress({
    required String childId,
    required String storyId,
  }) async {
    final id = '${childId}_$storyId';
    return _progress.firstWhere(
      (p) => p.progressId == id,
      orElse: () => UserProgress(
        progressId: id,
        childId: childId,
        storyId: storyId,
        storyTitle: '',
        storyCoverUrl: '',
        createdAt: DateTime.now(),
        lastReadAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<UserProgress>> getInProgressStories(String childId) async {
    return _progress
        .where((p) => p.childId == childId && !p.completed && p.completionPct > 0)
        .toList();
  }

  @override
  Future<List<UserProgress>> getCompletedStories(String childId) async {
    return _progress.where((p) => p.childId == childId && p.completed).toList();
  }

  @override
  Future<void> updateProgress({
    required String childId,
    required String storyId,
    required String storyTitle,
    required String storyCoverUrl,
    required int completionPct,
    required int timeSpentSeconds,
    required int lastSectionOrder,
    bool completed = false,
  }) async {
    final id = '${childId}_$storyId';
    final idx = _progress.indexWhere((p) => p.progressId == id);
    final existing = idx >= 0 ? _progress[idx] : null;

    final updated = UserProgress(
      progressId: id,
      childId: childId,
      storyId: storyId,
      storyTitle: storyTitle,
      storyCoverUrl: storyCoverUrl,
      completionPct: completionPct,
      timeSpentSeconds: (existing?.timeSpentSeconds ?? 0) + timeSpentSeconds,
      lastSectionOrder: lastSectionOrder,
      completed: completed,
      completedAt: completed ? DateTime.now() : existing?.completedAt,
      lastReadAt: DateTime.now(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (idx >= 0) {
      _progress[idx] = updated;
    } else {
      _progress.add(updated);
    }
  }

  @override
  Future<void> markAsCompleted({
    required String childId,
    required String storyId,
  }) async {
    await updateProgress(
      childId: childId,
      storyId: storyId,
      storyTitle: DemoData.stories
          .firstWhere((s) => s.storyId == storyId)
          .title,
      storyCoverUrl: DemoData.stories
          .firstWhere((s) => s.storyId == storyId)
          .coverImageUrl,
      completionPct: 100,
      timeSpentSeconds: 0,
      lastSectionOrder: 0,
      completed: true,
    );
  }
}
