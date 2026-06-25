import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/learned_word.dart';
import '../../domain/repositories/learned_words_repository.dart';
import '../../domain/services/srs_algorithm.dart';

/// Implementación real con Firestore.
class LearnedWordsRepositoryImpl implements LearnedWordsRepository {
  LearnedWordsRepositoryImpl({
    FirebaseFirestore? firestore,
    SrsAlgorithm? srsAlgorithm,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _srs = srsAlgorithm ?? const SrsAlgorithm();

  final FirebaseFirestore _firestore;
  final SrsAlgorithm _srs;

  static const _collection = 'learned_words';

  @override
  Future<LearnedWord> recordWordSeen({
    required String childId,
    required String wordEn,
    required String wordEs,
    String? phonetic,
    String? exampleSentence,
    required String sourceStoryId,
  }) async {
    try {
      final normalized = wordEn.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      final docId = '${childId}_$normalized';
      final docRef = _firestore.collection(_collection).doc(docId);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Crear palabra nueva
        final newWord = _srs.createNewWord(
          childId: childId,
          wordEn: wordEn,
          wordEs: wordEs,
          phonetic: phonetic,
          exampleSentence: exampleSentence,
          sourceStoryId: sourceStoryId,
        );
        await docRef.set(_wordToMap(newWord));
        return newWord;
      } else {
        // Incrementar timesSeen
        await docRef.update({
          'times_seen': FieldValue.increment(1),
        });
        final updated = await docRef.get();
        return _mapToWord(updated);
      }
    } catch (e) {
      throw UnknownFailure('Error al registrar palabra: $e');
    }
  }

  @override
  Future<List<LearnedWord>> getDueWords(String childId,
      {int limit = 20}) async {
    try {
      final now = DateTime.now();
      final snap = await _firestore
          .collection(_collection)
          .where('child_id', isEqualTo: childId)
          .where('next_review_at', isLessThanOrEqualTo: now.toUtc())
          .where('srs_state', whereIn: ['new', 'learning', 'review'])
          .orderBy('next_review_at')
          .limit(limit)
          .get();

      return snap.docs.map(_mapToWord).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer palabras due: $e');
    }
  }

  @override
  Stream<List<LearnedWord>> watchDueWords(String childId) {
    final now = DateTime.now().toUtc();
    return _firestore
        .collection(_collection)
        .where('child_id', isEqualTo: childId)
        .where('next_review_at', isLessThanOrEqualTo: now)
        .where('srs_state', whereIn: ['new', 'learning', 'review'])
        .snapshots()
        .map((snap) => snap.docs.map(_mapToWord).toList());
  }

  @override
  Future<List<LearnedWord>> getAllWords(String childId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('child_id', isEqualTo: childId)
          .orderBy('first_seen_at', descending: true)
          .get();
      return snap.docs.map(_mapToWord).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer palabras: $e');
    }
  }

  @override
  Future<List<LearnedWord>> getWordsByState(
      String childId, String srsState) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('child_id', isEqualTo: childId)
          .where('srs_state', isEqualTo: srsState)
          .get();
      return snap.docs.map(_mapToWord).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer palabras por estado: $e');
    }
  }

  @override
  Future<LearnedWord> recordReview({
    required String learnedWordId,
    required ReviewQuality quality,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(learnedWordId);
      final doc = await docRef.get();
      if (!doc.exists) {
        throw const NotFoundFailure('Palabra no encontrada');
      }
      final word = _mapToWord(doc);
      final result = _srs.review(word, quality);

      final updates = {
        'repetitions': result.repetitions,
        'ease_factor': result.easeFactor,
        'interval_days': result.intervalDays,
        'next_review_at': result.nextReviewAt.toUtc(),
        'srs_state': result.srsState,
        'last_reviewed_at': DateTime.now().toUtc(),
        'times_seen': FieldValue.increment(1),
        'correct_reviews':
            quality.value >= 3 ? FieldValue.increment(1) : FieldValue.increment(0),
        'incorrect_reviews':
            quality.value < 3 ? FieldValue.increment(1) : FieldValue.increment(0),
      };

      await docRef.update(updates);
      final updated = await docRef.get();
      return _mapToWord(updated);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al registrar repaso: $e');
    }
  }

  @override
  Future<void> markAsMastered(String learnedWordId) async {
    try {
      await _firestore.collection(_collection).doc(learnedWordId).update({
        'srs_state': 'mastered',
        'next_review_at':
            DateTime.now().add(const Duration(days: 365)).toUtc(),
      });
    } catch (e) {
      throw UnknownFailure('Error al marcar como aprendida: $e');
    }
  }

  @override
  Future<int> getTotalWordsCount(String childId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('child_id', isEqualTo: childId)
          .count()
          .get();
      return snap.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Map<String, int>> getWordsCountByState(String childId) async {
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('child_id', isEqualTo: childId)
          .get();

      final counts = <String, int>{
        'new': 0,
        'learning': 0,
        'review': 0,
        'mastered': 0,
      };
      for (final doc in snap.docs) {
        final state = doc.data()['srs_state'] as String? ?? 'new';
        counts[state] = (counts[state] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      return {'new': 0, 'learning': 0, 'review': 0, 'mastered': 0};
    }
  }

  // ============================================================
  // Helpers
  // ============================================================

  Map<String, dynamic> _wordToMap(LearnedWord word) {
    return {
      'learned_word_id': word.learnedWordId,
      'child_id': word.childId,
      'word_en': word.wordEn,
      'word_es': word.wordEs,
      'phonetic': word.phonetic,
      'example_sentence': word.exampleSentence,
      'source_story_id': word.sourceStoryId,
      'repetitions': word.repetitions,
      'ease_factor': word.easeFactor,
      'interval_days': word.intervalDays,
      'next_review_at': word.nextReviewAt.toUtc(),
      'srs_state': word.srsState,
      'times_seen': word.timesSeen,
      'correct_reviews': word.correctReviews,
      'incorrect_reviews': word.incorrectReviews,
      'first_seen_at': word.firstSeenAt.toUtc(),
      'last_reviewed_at': word.lastReviewedAt?.toUtc(),
    };
  }

  LearnedWord _mapToWord(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return LearnedWord(
      learnedWordId: d['learned_word_id'] as String? ?? doc.id,
      childId: d['child_id'] as String? ?? '',
      wordEn: d['word_en'] as String? ?? '',
      wordEs: d['word_es'] as String? ?? '',
      phonetic: d['phonetic'] as String?,
      exampleSentence: d['example_sentence'] as String?,
      sourceStoryId: d['source_story_id'] as String? ?? '',
      repetitions: (d['repetitions'] as num?)?.toInt() ?? 0,
      easeFactor: (d['ease_factor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (d['interval_days'] as num?)?.toInt() ?? 0,
      nextReviewAt: (d['next_review_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      srsState: d['srs_state'] as String? ?? 'new',
      timesSeen: (d['times_seen'] as num?)?.toInt() ?? 0,
      correctReviews: (d['correct_reviews'] as num?)?.toInt() ?? 0,
      incorrectReviews: (d['incorrect_reviews'] as num?)?.toInt() ?? 0,
      firstSeenAt: (d['first_seen_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      lastReviewedAt: (d['last_reviewed_at'] as Timestamp?)?.toDate(),
    );
  }
}
