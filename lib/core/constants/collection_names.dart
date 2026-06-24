// =============================================================================
// collection_names.dart - Nombres de colecciones Firestore
// -----------------------------------------------------------------------------
// Centraliza los nombres de colecciones/subcolecciones para evitar typos y
// facilitar refactors. Tomado de docs/03-data-models.md.
// =============================================================================

/// Nombres de colecciones y subcolecciones de Firestore.
class CollectionNames {
  CollectionNames._();

  // ---- Colecciones raiz ----

  /// Padre/madre que crea la cuenta.
  static const String users = 'users';

  /// Perfiles de nios (hasta 4 por cuenta).
  static const String childrenProfiles = 'children_profiles';

  /// Catalogo de cuentos.
  static const String stories = 'stories';

  /// Progreso por nio+cuento (denormalizado con storyTitle).
  static const String userProgress = 'user_progress';

  /// Sesiones individuales de lectura (analitica granular).
  static const String readingSessions = 'reading_sessions';

  /// Catalogo de logros / insignias.
  static const String achievements = 'achievements';

  /// Logros desbloqueados por cada nio.
  static const String userAchievements = 'user_achievements';

  /// Estado de suscripcion del padre.
  static const String subscriptions = 'subscriptions';

  /// Configuracion parental por usuario.
  static const String parentalSettings = 'parental_settings';

  /// Categorias tematicas del catalogo.
  static const String categories = 'categories';

  /// Eventos analiticos anonimizados (TTL 90 dias).
  static const String analyticsEvents = 'analytics_events';

  // ---- Subcolecciones (bajo /stories/{storyId}) ----

  /// Subcoleccion: `stories/{storyId}/story_sections`
  static const String storySections = 'story_sections';

  /// Subcoleccion: `stories/{storyId}/vocabulary`
  static const String vocabulary = 'vocabulary';

  /// Subcoleccion: `stories/{storyId}/comprehension_questions`
  static const String comprehensionQuestions = 'comprehension_questions';

  // ---- Helpers de paths completos ----

  /// Path completo a la subcoleccion `story_sections` de un cuento.
  static String storySectionsPath(String storyId) =>
      '$stories/$storyId/$storySections';

  /// Path completo a la subcoleccion `vocabulary` de un cuento.
  static String vocabularyPath(String storyId) =>
      '$stories/$storyId/$vocabulary';

  /// Path completo a la subcoleccion `comprehension_questions` de un cuento.
  static String comprehensionQuestionsPath(String storyId) =>
      '$stories/$storyId/$comprehensionQuestions';
}
