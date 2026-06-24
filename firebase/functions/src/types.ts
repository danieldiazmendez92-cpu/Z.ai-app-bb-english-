/**
 * Tipos TypeScript compartidos entre todas las Cloud Functions.
 *
 * Estos tipos reflejan el esquema Firestore definido en
 * `docs/04-firestore-schema.md` y los contratos de las Cloud Functions
 * definidos en `docs/06-roadmap.md` (Fase 1 Sprint 1.3, Fase 3 Sprint 3.1).
 */

import type { Timestamp } from "firebase-admin/firestore";

// =============================================================================
// USUARIOS Y PERFILES
// =============================================================================

/** Proveedor de autenticacion ( Auth Provider ) */
export type AuthProvider = "email" | "google" | "apple";

/** Documento Firestore `users/{uid}` */
export interface AppUser {
  uid: string;
  email: string; // siempre lowercase
  display_name: string | null;
  auth_provider: AuthProvider;
  parental_verified_at: Timestamp | null;
  is_premium: boolean;
  premium_expires_at: Timestamp | null;
  children_count?: number; // mantenido por onChildCreate trigger
  created_at: Timestamp;
  updated_at: Timestamp;
}

/** Documento Firestore `children_profiles/{childId}` */
export interface ChildProfile {
  child_id: string;
  user_uid: string;
  name: string; // solo primer nombre o apodo ( COPPA )
  age: number; // 2-7
  avatar_url: string;
  interests: string[];
  created_at: Timestamp;
  last_active_at: Timestamp | null;
  deleted_at: Timestamp | null; // soft delete
}

/** Documento Firestore `parental_settings/{userUid}` */
export interface ParentalSettings {
  user_uid: string;
  daily_limit_minutes: number; // 0 = sin limite
  blocked_categories: string[];
  allow_offline_download: boolean;
  allow_analytics: boolean; // COPPA opt-in, default false
  allow_personalized_ads: boolean; // siempre false ( COPPA )
  bedtime_start: string | null; // 'HH:mm'
  bedtime_end: string | null; // 'HH:mm'
}

// =============================================================================
// CUENTOS Y CATÁLOGO
// =============================================================================

/** Documento Firestore `stories/{storyId}` */
export interface Story {
  story_id: string;
  title: string;
  category_id: string;
  min_age: number;
  max_age: number;
  duration_minutes: number;
  audio_url_en: string;
  audio_url_es: string | null;
  timestamps_json_url: string | null;
  cover_image_url: string;
  source_attribution: string;
  source_url: string;
  published: boolean;
  tags: string[];
  created_at: Timestamp;
  published_at: Timestamp | null;
  view_count: number;
  avg_rating: number | null;
}

/** Subcoleccion `stories/{storyId}/story_sections/{sectionId}` */
export interface StorySection {
  section_id: string;
  story_id: string;
  order: number;
  text_en: string;
  text_es: string;
  illustration_url: string | null;
}

/** Subcoleccion `stories/{storyId}/vocabulary/{wordId}` */
export interface VocabularyWord {
  word_id: string;
  story_id: string;
  word_en: string;
  word_es: string;
  phonetic: string | null; // IPA
  example_sentence: string | null;
  example_translation: string | null;
  image_url: string | null;
  is_highlighted: boolean;
}

/** Subcoleccion `stories/{storyId}/comprehension_questions/{qId}` */
export interface ComprehensionQuestion {
  question_id: string;
  story_id: string;
  question_text: string;
  options: string[]; // 4 opciones
  correct_index: number; // 0-3
  explanation: string;
}

/** Documento Firestore `categories/{categoryId}` */
export interface Category {
  category_id: string;
  name: string;
  name_es: string;
  icon_asset: string;
  description: string | null;
  order: number;
}

// =============================================================================
// PROGRESO, LOGROS Y SESIONES
// =============================================================================

/** Documento Firestore `user_progress/{childId}_{storyId}` */
export interface UserProgress {
  progress_id: string;
  child_id: string;
  story_id: string;
  story_title: string; // denormalizado
  story_cover_url: string; // denormalizado
  completion_pct: number; // 0-100
  time_spent_seconds: number;
  last_section_order: number;
  completed: boolean;
  completed_at: Timestamp | null;
  last_read_at: Timestamp;
  created_at: Timestamp;
}

/** Tipo de criterio para evaluar logros */
export type AchievementCriteriaType =
  | "stories_completed"
  | "streak_days"
  | "words_learned"
  | "categories_explored"
  | "perfect_comprehension"
  | "total_minutes_read";

/** Documento Firestore `achievements/{achievementId}` */
export interface Achievement {
  achievement_id: string;
  name: string;
  description: string;
  icon_url: string;
  criteria_type: AchievementCriteriaType;
  criteria_threshold: number;
  is_hidden: boolean;
  xp_reward: number;
}

/** Documento Firestore `user_achievements/{childId}_{achievementId}` */
export interface UserAchievement {
  user_achievement_id: string;
  child_id: string;
  achievement_id: string;
  unlocked_at: Timestamp;
}

/** Documento Firestore `reading_sessions/{sessionId}` */
export interface ReadingSession {
  session_id: string;
  child_id: string;
  story_id: string;
  started_at: Timestamp;
  ended_at: Timestamp | null;
  duration_seconds: number;
  sections_read: number;
  completed: boolean;
}

// =============================================================================
// SUSCRIPCIONES Y BILLING
// =============================================================================

export type SubscriptionPlan = "monthly" | "annual";
export type SubscriptionPlatform = "android" | "ios";
export type SubscriptionStatus =
  | "active"
  | "expired"
  | "canceled"
  | "grace_period";

/** Documento Firestore `subscriptions/{subscriptionId}` */
export interface Subscription {
  subscription_id: string; // '{userUid}_{platform}'
  user_uid: string;
  plan: SubscriptionPlan;
  platform: SubscriptionPlatform;
  store_product_id: string;
  started_at: Timestamp;
  expires_at: Timestamp;
  auto_renew: boolean;
  status: SubscriptionStatus;
  last_receipt_id: string | null;
  canceled_at: Timestamp | null;
}

// =============================================================================
// AUDIT Y RATE LIMITING
// =============================================================================

export type AuditAction =
  | "parental_verified"
  | "child_created"
  | "child_deleted"
  | "subscription_started"
  | "subscription_canceled"
  | "data_exported"
  | "data_deleted"
  | "admin_granted";

/** Documento Firestore `audit_log/{eventId}` */
export interface AuditLogEntry {
  event_id: string;
  actor_uid: string;
  action: AuditAction;
  target_id: string | null;
  occurred_at: Timestamp;
  ip_hash: string;
  metadata: Record<string, unknown>;
}

/** Documento Firestore `rate_limit/{uid}_{action}` */
export interface RateLimitEntry {
  uid: string;
  action: string;
  count: number;
  window_start: Timestamp;
  last_attempt_at: Timestamp;
}

// =============================================================================
// CONTRATOS DE CLOUD FUNCTIONS ( CALLABLES )
// =============================================================================

/** Payload de entrada para `storyIngest` */
export interface StoryIngestRequest {
  title: string;
  textEn: string;
  sourceAttribution: string;
  sourceUrl: string;
  categoryId: string;
  minAge: number;
  maxAge: number;
}

/** Respuesta de `storyIngest` */
export interface StoryIngestResponse {
  storyId: string;
  audioPath: string;
  timestampsPath: string;
  vocabularyCount: number;
  questionsCount: number;
  sectionsCount: number;
}

/** Payload de entrada para `verifyParental` */
export interface VerifyParentalRequest {
  /** 3 respuestas numericas a las preguntas matematicas */
  answers: number[];
}

/** Respuesta de `verifyParental` */
export interface VerifyParentalResponse {
  verified: boolean;
  verifiedAt: string | null; // ISO
  reason?: "ok" | "wrong_answers" | "already_verified" | "rate_limited";
}

/** Payload de entrada para `validatePlayReceipt` */
export interface ValidatePlayReceiptRequest {
  purchaseToken: string;
  productId: string;
}

/** Payload de entrada para `validateAppStoreReceipt` */
export interface ValidateAppStoreReceiptRequest {
  receiptData: string;
  transactionId: string;
}

/** Respuesta comun para validacion de receipts */
export interface ValidateReceiptResponse {
  valid: boolean;
  subscriptionId?: string;
  plan?: SubscriptionPlan;
  status?: SubscriptionStatus;
  expiresAt?: string; // ISO
  reason?: string;
}

// =============================================================================
// AUXILIARES
// =============================================================================

/** Timestamp de una palabra en el audio narrado */
export interface WordTimestamp {
  word: string;
  start_ms: number;
  end_ms: number;
}

/** Resultado de Gemini al procesar un cuento */
export interface GeminiStoryResult {
  vocabulary: Omit<VocabularyWord, "word_id" | "story_id">[];
  translationEs: string;
  questions: Omit<ComprehensionQuestion, "question_id" | "story_id">[];
  sections: { text_en: string; text_es: string }[];
}

/** Resultado de la sintesis TTS */
export interface TtsResult {
  audioBuffer: Buffer;
  timestamps: WordTimestamp[];
}
