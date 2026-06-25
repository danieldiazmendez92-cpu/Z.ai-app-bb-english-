import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/learned_word.dart';
import '../../domain/repositories/learned_words_repository.dart';
import '../../domain/services/srs_algorithm.dart';

/// Repositorio DEMO en memoria.
class DemoLearnedWordsRepository implements LearnedWordsRepository {
  DemoLearnedWordsRepository({SrsAlgorithm? srsAlgorithm})
      : _srs = srsAlgorithm ?? const SrsAlgorithm();

  final SrsAlgorithm _srs;
  final Map<String, LearnedWord> _words = {};

  final StreamController<List<LearnedWord>> _dueController =
      StreamController<List<LearnedWord>>.broadcast();

  @override
  Future<LearnedWord> recordWordSeen({
    required String childId,
    required String wordEn,
    required String wordEs,
    String? phonetic,
    String? exampleSentence,
    required String sourceStoryId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final normalized = wordEn.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    final docId = '${childId}_$normalized';

    if (!_words.containsKey(docId)) {
      final newWord = _srs.createNewWord(
        childId: childId,
        wordEn: wordEn,
        wordEs: wordEs,
        phonetic: phonetic,
        exampleSentence: exampleSentence,
        sourceStoryId: sourceStoryId,
      );
      _words[docId] = newWord;
      _emitDue(childId);
      return newWord;
    } else {
      final existing = _words[docId]!;
      final updated = existing.copyWith(
        timesSeen: existing.timesSeen + 1,
      );
      _words[docId] = updated;
      _emitDue(childId);
      return updated;
    }
  }

  @override
  Future<List<LearnedWord>> getDueWords(String childId,
      {int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return _words.values
        .where((w) =>
            w.childId == childId &&
            w.nextReviewAt.isBefore(now) &&
            w.srsState != 'mastered')
        .toList()
      ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
  }

  @override
  Stream<List<LearnedWord>> watchDueWords(String childId) {
    Future.microtask(() => _emitDue(childId));
    return _dueController.stream;
  }

  void _emitDue(String childId) {
    final now = DateTime.now();
    final due = _words.values
        .where((w) =>
            w.childId == childId &&
            w.nextReviewAt.isBefore(now) &&
            w.srsState != 'mastered')
        .toList()
      ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
    _dueController.add(due);
  }

  @override
  Future<List<LearnedWord>> getAllWords(String childId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _words.values
        .where((w) => w.childId == childId)
        .toList()
      ..sort((a, b) => b.firstSeenAt.compareTo(a.firstSeenAt));
  }

  @override
  Future<List<LearnedWord>> getWordsByState(
      String childId, String srsState) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _words.values
        .where((w) => w.childId == childId && w.srsState == srsState)
        .toList();
  }

  @override
  Future<LearnedWord> recordReview({
    required String learnedWordId,
    required ReviewQuality quality,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final word = _words[learnedWordId];
    if (word == null) {
      throw const NotFoundFailure('Palabra no encontrada');
    }
    final result = _srs.review(word, quality);
    final updated = word.copyWith(
      repetitions: result.repetitions,
      easeFactor: result.easeFactor,
      intervalDays: result.intervalDays,
      nextReviewAt: result.nextReviewAt,
      srsState: result.srsState,
      lastReviewedAt: DateTime.now(),
      timesSeen: word.timesSeen + 1,
      correctReviews: quality.value >= 3
          ? word.correctReviews + 1
          : word.correctReviews,
      incorrectReviews: quality.value < 3
          ? word.incorrectReviews + 1
          : word.incorrectReviews,
    );
    _words[learnedWordId] = updated;
    _emitDue(word.childId);
    return updated;
  }

  @override
  Future<void> markAsMastered(String learnedWordId) async {
    final word = _words[learnedWordId];
    if (word == null) return;
    _words[learnedWordId] = word.copyWith(
      srsState: 'mastered',
      nextReviewAt: DateTime.now().add(const Duration(days: 365)),
    );
    _emitDue(word.childId);
  }

  @override
  Future<int> getTotalWordsCount(String childId) async {
    return _words.values.where((w) => w.childId == childId).length;
  }

  @override
  Future<Map<String, int>> getWordsCountByState(String childId) async {
    final counts = <String, int>{
      'new': 0,
      'learning': 0,
      'review': 0,
      'mastered': 0,
    };
    for (final word in _words.values.where((w) => w.childId == childId)) {
      counts[word.srsState] = (counts[word.srsState] ?? 0) + 1;
    }
    return counts;
  }

  // ============================================================
  // Demo helpers: pre-poblar palabras
  // ============================================================

  /// Pre-crea algunas palabras para que el niño tenga algo que repasar
  /// al entrar a la pantalla de vocabulario.
  void prepopulateDemo(String childId) {
    final demoWords = [
      ('wolf', 'lobo', '/wʊlf/', 'The wolf was hungry.', 'little-red-riding-hood'),
      ('forest', 'bosque', '/ˈfɒrɪst/', 'She walked into the forest.', 'little-red-riding-hood'),
      ('grandmother', 'abuela', '/ˈɡrænmʌðər/', 'Her grandmother was sick.', 'little-red-riding-hood'),
      ('pig', 'cerdo', '/pɪɡ/', 'The pig built a house.', 'three-little-pigs'),
      ('house', 'casa', '/haʊs/', 'The house was strong.', 'three-little-pigs'),
      ('bear', 'oso', '/beər/', 'The three bears lived there.', 'goldilocks'),
      ('hot', 'caliente', '/hɒt/', 'The porridge was hot.', 'goldilocks'),
      ('cold', 'frío', '/kəʊld/', 'The porridge was cold.', 'goldilocks'),
      ('star', 'estrella', '/stɑːr/', 'Twinkle, twinkle, little star.', 'twinkle-twinkle'),
      ('spider', 'araña', '/ˈspaɪdər/', 'The spider climbed up.', 'itsy-bitsy-spider'),
    ];

    for (final (wordEn, wordEs, phonetic, example, storyId) in demoWords) {
      final docId = '${childId}_${wordEn.toLowerCase()}';
      if (!_words.containsKey(docId)) {
        final word = _srs.createNewWord(
          childId: childId,
          wordEn: wordEn,
          wordEs: wordEs,
          phonetic: phonetic,
          exampleSentence: example,
          sourceStoryId: storyId,
        );
        _words[docId] = word;
      }
    }
    _emitDue(childId);
  }

  void dispose() {
    _dueController.close();
  }
}
