import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/collection_names.dart';
import '../../../../core/errors/failures.dart';
import '../../../progress/domain/entities/user_progress.dart';
import '../../domain/entities/audio_timestamp.dart';
import '../../domain/entities/comprehension_question.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_section.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/story_repository.dart';

/// Implementación de [StoryRepository] que usa Firestore + Storage.
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // ============================================================
  // Catálogo
  // ============================================================

  @override
  Future<List<Story>> getPublishedStories({
    String? categoryId,
    int? age,
    String? tag,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(CollectionNames.stories)
          .where('published', isEqualTo: true);

      if (categoryId != null) {
        query = query.where('category_id', isEqualTo: categoryId);
      }

      if (age != null) {
        query = query
            .where('min_age', isLessThanOrEqualTo: age)
            .where('max_age', isGreaterThanOrEqualTo: age);
      }

      if (tag != null) {
        query = query.where('tags', arrayContains: tag);
      }

      query = query.orderBy('created_at', descending: true).limit(limit);

      final snap = await query.get();
      return snap.docs.map(_mapDocToStory).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer cuentos: $e');
    }
  }

  @override
  Future<Story> getStory(String storyId) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.stories)
          .doc(storyId)
          .get();

      if (!doc.exists) {
        throw const NotFoundFailure('Cuento no encontrado');
      }

      return _mapDocToStory(doc);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al leer cuento: $e');
    }
  }

  @override
  Future<List<Story>> searchStories(String query) async {
    try {
      // Firestore no soporte búsqueda full-text nativa.
      // Para MVP: traer todos los publicados y filtrar en cliente.
      // En Fase 4: migrar a Algolia o ElasticSearch.
      final q = query.toLowerCase().trim();
      if (q.isEmpty) return [];

      final snap = await _firestore
          .collection(CollectionNames.stories)
          .where('published', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(100)
          .get();

      return snap.docs
          .map(_mapDocToStory)
          .where((story) => story.title.toLowerCase().contains(q))
          .toList();
    } catch (e) {
      throw UnknownFailure('Error al buscar cuentos: $e');
    }
  }

  @override
  Future<List<Story>> getRecommendedStories({
    required int age,
    required List<String> interests,
    int limit = 10,
  }) async {
    try {
      // MVP: cuentos para la edad del niño, ordenados por popularidad.
      // En el futuro: algoritmo más sofisticado con ML.
      Query<Map<String, dynamic>> query = _firestore
          .collection(CollectionNames.stories)
          .where('published', isEqualTo: true)
          .where('min_age', isLessThanOrEqualTo: age)
          .where('max_age', isGreaterThanOrEqualTo: age)
          .orderBy('view_count', descending: true)
          .limit(limit * 2); // Traer más para filtrar por intereses en cliente

      final snap = await query.get();
      final stories = snap.docs.map(_mapDocToStory).toList();

      // Priorizar cuentos que matchean intereses
      if (interests.isNotEmpty) {
        stories.sort((a, b) {
          final aMatches =
              a.tags.where((t) => interests.contains(t)).length;
          final bMatches =
              b.tags.where((t) => interests.contains(t)).length;
          return bMatches.compareTo(aMatches);
        });
      }

      return stories.take(limit).toList();
    } catch (e) {
      throw UnknownFailure('Error al obtener recomendaciones: $e');
    }
  }

  // ============================================================
  // Contenido del cuento
  // ============================================================

  @override
  Future<List<StorySection>> getStorySections(String storyId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.stories)
          .doc(storyId)
          .collection('story_sections')
          .orderBy('order')
          .get();

      return snap.docs.map(_mapDocToStorySection).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer secciones: $e');
    }
  }

  @override
  Future<List<VocabularyWord>> getStoryVocabulary(String storyId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.stories)
          .doc(storyId)
          .collection('vocabulary')
          .get();

      return snap.docs.map(_mapDocToVocabularyWord).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer vocabulario: $e');
    }
  }

  @override
  Future<List<ComprehensionQuestion>> getComprehensionQuestions(
      String storyId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.stories)
          .doc(storyId)
          .collection('comprehension_questions')
          .get();

      return snap.docs.map(_mapDocToComprehensionQuestion).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer preguntas: $e');
    }
  }

  // ============================================================
  // Audio y timestamps
  // ============================================================

  @override
  Future<AudioTimestamps?> getAudioTimestamps(String storyId) async {
    try {
      // Primero obtener la URL del JSON desde el doc del story
      final storyDoc = await _firestore
          .collection(CollectionNames.stories)
          .doc(storyId)
          .get();

      if (!storyDoc.exists) return null;
      final timestampsUrl = storyDoc.data()?['timestamps_json_url'] as String?;
      if (timestampsUrl == null) return null;

      // Descargar el JSON desde Storage
      final ref = _storage.refFromURL(timestampsUrl);
      final data = await ref.getData();
      if (data == null) return null;

      final json = jsonDecode(String.fromCharCodes(data)) as List<dynamic>;
      return AudioTimestamps.fromJsonList(json);
    } catch (e) {
      // No propagar error: si no hay timestamps, el cuento sigue funcionando
      // sin resaltado sincronizado.
      return null;
    }
  }

  // ============================================================
  // Progreso del niño
  // ============================================================

  @override
  Future<UserProgress?> getProgress({
    required String childId,
    required String storyId,
  }) async {
    try {
      final progressId = '${childId}_$storyId';
      final doc = await _firestore
          .collection(CollectionNames.userProgress)
          .doc(progressId)
          .get();

      if (!doc.exists) return null;
      return _mapDocToUserProgress(doc);
    } catch (e) {
      throw UnknownFailure('Error al leer progreso: $e');
    }
  }

  @override
  Future<List<UserProgress>> getInProgressStories(String childId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.userProgress)
          .where('child_id', isEqualTo: childId)
          .where('completed', isEqualTo: false)
          .orderBy('last_read_at', descending: true)
          .limit(10)
          .get();

      return snap.docs.map(_mapDocToUserProgress).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer progreso: $e');
    }
  }

  @override
  Future<List<UserProgress>> getCompletedStories(String childId) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.userProgress)
          .where('child_id', isEqualTo: childId)
          .where('completed', isEqualTo: true)
          .orderBy('completed_at', descending: true)
          .get();

      return snap.docs.map(_mapDocToUserProgress).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer cuentos completados: $e');
    }
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
    try {
      final progressId = '${childId}_$storyId';
      final now = FieldValue.serverTimestamp();

      await _firestore
          .collection(CollectionNames.userProgress)
          .doc(progressId)
          .set({
        'progress_id': progressId,
        'child_id': childId,
        'story_id': storyId,
        'story_title': storyTitle,
        'story_cover_url': storyCoverUrl,
        'completion_pct': completionPct,
        'time_spent_seconds': timeSpentSeconds,
        'last_section_order': lastSectionOrder,
        'completed': completed,
        'completed_at': completed ? now : null,
        'last_read_at': now,
        'created_at': now,
      }, SetOptions(merge: true));
    } catch (e) {
      throw UnknownFailure('Error al actualizar progreso: $e');
    }
  }

  @override
  Future<void> markAsCompleted({
    required String childId,
    required String storyId,
  }) async {
    try {
      final progressId = '${childId}_$storyId';
      await _firestore
          .collection(CollectionNames.userProgress)
          .doc(progressId)
          .update({
        'completed': true,
        'completed_at': FieldValue.serverTimestamp(),
        'completion_pct': 100,
        'last_read_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UnknownFailure('Error al marcar como completado: $e');
    }
  }

  // ============================================================
  // Helpers de mapeo
  // ============================================================

  Story _mapDocToStory(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Story(
      storyId: d['story_id'] as String? ?? doc.id,
      title: d['title'] as String? ?? 'Untitled',
      categoryId: d['category_id'] as String? ?? 'uncategorized',
      minAge: (d['min_age'] as num?)?.toInt() ?? 2,
      maxAge: (d['max_age'] as num?)?.toInt() ?? 7,
      durationMinutes: (d['duration_minutes'] as num?)?.toInt() ?? 5,
      audioUrlEn: d['audio_url_en'] as String? ?? '',
      audioUrlEs: d['audio_url_es'] as String?,
      timestampsJsonUrl: d['timestamps_json_url'] as String?,
      coverImageUrl: d['cover_image_url'] as String? ?? '',
      sourceAttribution: d['source_attribution'] as String? ?? '',
      sourceUrl: d['source_url'] as String? ?? '',
      published: d['published'] as bool? ?? false,
      tags: (d['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      publishedAt: (d['published_at'] as Timestamp?)?.toDate(),
      viewCount: (d['view_count'] as num?)?.toInt() ?? 0,
      avgRating: (d['avg_rating'] as num?)?.toDouble(),
    );
  }

  StorySection _mapDocToStorySection(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return StorySection(
      sectionId: d['section_id'] as String? ?? doc.id,
      storyId: d['story_id'] as String? ?? '',
      order: (d['order'] as num?)?.toInt() ?? 0,
      textEn: d['text_en'] as String? ?? '',
      textEs: d['text_es'] as String? ?? '',
      illustrationUrl: d['illustration_url'] as String?,
    );
  }

  VocabularyWord _mapDocToVocabularyWord(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return VocabularyWord(
      wordId: d['word_id'] as String? ?? doc.id,
      storyId: d['story_id'] as String? ?? '',
      wordEn: d['word_en'] as String? ?? '',
      wordEs: d['word_es'] as String? ?? '',
      phonetic: d['phonetic'] as String?,
      exampleSentence: d['example_sentence'] as String?,
      exampleTranslation: d['example_translation'] as String?,
      imageUrl: d['image_url'] as String?,
      isHighlighted: d['is_highlighted'] as bool? ?? true,
    );
  }

  ComprehensionQuestion _mapDocToComprehensionQuestion(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return ComprehensionQuestion(
      questionId: d['question_id'] as String? ?? doc.id,
      storyId: d['story_id'] as String? ?? '',
      questionText: d['question_text'] as String? ?? '',
      options: (d['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctIndex: (d['correct_index'] as num?)?.toInt() ?? 0,
      explanation: d['explanation'] as String? ?? '',
    );
  }

  UserProgress _mapDocToUserProgress(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProgress(
      progressId: d['progress_id'] as String? ?? doc.id,
      childId: d['child_id'] as String? ?? '',
      storyId: d['story_id'] as String? ?? '',
      storyTitle: d['story_title'] as String? ?? '',
      storyCoverUrl: d['story_cover_url'] as String? ?? '',
      completionPct: (d['completion_pct'] as num?)?.toInt() ?? 0,
      timeSpentSeconds: (d['time_spent_seconds'] as num?)?.toInt() ?? 0,
      lastSectionOrder: (d['last_section_order'] as num?)?.toInt() ?? 0,
      completed: d['completed'] as bool? ?? false,
      completedAt: (d['completed_at'] as Timestamp?)?.toDate(),
      lastReadAt: (d['last_read_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}
