import '../../domain/entities/learned_word.dart';
import '../../domain/services/srs_algorithm.dart';

/// Contrato del repositorio de palabras aprendidas.
abstract class LearnedWordsRepository {
  Future<LearnedWord> recordWordSeen({
    required String childId,
    required String wordEn,
    required String wordEs,
    String? phonetic,
    String? exampleSentence,
    required String sourceStoryId,
  });

  Future<List<LearnedWord>> getDueWords(String childId, {int limit = 20});

  Stream<List<LearnedWord>> watchDueWords(String childId);

  Future<List<LearnedWord>> getAllWords(String childId);

  Future<List<LearnedWord>> getWordsByState(String childId, String srsState);

  Future<LearnedWord> recordReview({
    required String learnedWordId,
    required ReviewQuality quality,
  });

  Future<void> markAsMastered(String learnedWordId);

  Future<int> getTotalWordsCount(String childId);

  Future<Map<String, int>> getWordsCountByState(String childId);
}
