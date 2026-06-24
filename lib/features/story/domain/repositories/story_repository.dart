import '../entities/audio_timestamp.dart';
import '../entities/comprehension_question.dart';
import '../entities/story.dart';
import '../entities/story_section.dart';
import '../entities/vocabulary_word.dart';

/// Contrato del repositorio de cuentos.
///
/// Maneja:
/// - Lectura del catálogo de cuentos publicados (con filtros)
/// - Lectura de un cuento completo (story + sections + vocab + questions)
/// - Descarga de audio MP3 y timestamps JSON desde Storage
/// - Tracking de progreso del niño (user_progress)
abstract class StoryRepository {
  // ============================================================
  // Catálogo
  // ============================================================

  /// Obtiene todos los cuentos publicados, opcionalmente filtrados.
  ///
  /// Filtros:
  /// - [categoryId]: si no es null, solo cuentos de esa categoría.
  /// - [age]: si no es null, solo cuentos donde minAge <= age <= maxAge.
  /// - [tag]: si no es null, solo cuentos con ese tag.
  Future<List<Story>> getPublishedStories({
    String? categoryId,
    int? age,
    String? tag,
    int limit = 50,
  });

  /// Obtiene un cuento específico por ID.
  /// Lanza [NotFoundFailure] si no existe o no está publicado.
  Future<Story> getStory(String storyId);

  /// Busca cuentos por título (búsqueda case-insensitive, prefix match).
  Future<List<Story>> searchStories(String query);

  /// Obtiene los cuentos recomendados para un niño según su edad e intereses.
  Future<List<Story>> getRecommendedStories({
    required int age,
    required List<String> interests,
    int limit = 10,
  });

  // ============================================================
  // Contenido del cuento
  // ============================================================

  /// Obtiene todas las secciones (páginas) de un cuento, ordenadas.
  Future<List<StorySection>> getStorySections(String storyId);

  /// Obtiene el vocabulario destacado de un cuento.
  Future<List<VocabularyWord>> getStoryVocabulary(String storyId);

  /// Obtiene las preguntas de comprensión de un cuento.
  Future<List<ComprehensionQuestion>> getComprehensionQuestions(
      String storyId);

  // ============================================================
  // Audio y timestamps
  // ============================================================

  /// Descarga el JSON de timestamps desde Storage y lo parsea.
  /// Devuelve null si el cuento no tiene timestamps (audio no generado).
  Future<AudioTimestamps?> getAudioTimestamps(String storyId);

  // ============================================================
  // Progreso del niño
  // ============================================================

  /// Obtiene el progreso de un niño en un cuento específico.
  /// Si no existe, retorna null (el niño nunca lo abrió).
  Future<UserProgress?> getProgress({
    required String childId,
    required String storyId,
  });

  /// Obtiene todos los cuentos en progreso del niño (para "Continuar leyendo").
  Future<List<UserProgress>> getInProgressStories(String childId);

  /// Obtiene todos los cuentos completados por el niño.
  Future<List<UserProgress>> getCompletedStories(String childId);

  /// Crea o actualiza el progreso del niño en un cuento.
  /// Se llama cada 10 segundos durante la lectura (debounced en cliente).
  Future<void> updateProgress({
    required String childId,
    required String storyId,
    required String storyTitle,
    required String storyCoverUrl,
    required int completionPct,
    required int timeSpentSeconds,
    required int lastSectionOrder,
    bool completed = false,
  });

  /// Marca un cuento como completado.
  /// Dispara el trigger `onStoryCompleted` en Cloud Functions.
  Future<void> markAsCompleted({
    required String childId,
    required String storyId,
  });
}

// Import aquí para que UserProgress esté disponible en la interface.
import '../../progress/domain/entities/user_progress.dart';
