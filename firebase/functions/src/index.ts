/**
 * Punto de entrada principal de las Cloud Functions.
 *
 * Re-exporta todas las functions para que Firebase CLI las detecte y deploye.
 *
 * Referencia: `docs/06-roadmap.md` Fase 1 Sprint 1.3 ( story ingestion ),
 * Sprint 1.1 ( parental verify ), Fase 2 Sprint 2.1 ( achievements ),
 * Fase 3 Sprint 3.1 ( billing ).
 */

import { logger } from "firebase-functions/v2";
import { validateConfig } from "./config";

// Validacion de configuracion al cargar el modulo ( cold start ).
try {
  validateConfig();
} catch (err) {
  logger.warn("Config validation error ( non-fatal )", err);
}

// =============================================================================
// CALLABLES
// =============================================================================

export { storyIngest } from "./story_ingest";
export { verifyParental } from "./verify_parental";
export { validatePlayReceipt, validateAppStoreReceipt } from "./billing_validation";
export { exportUserData } from "./export_user_data";

// =============================================================================
// FIRESTORE TRIGGERS
// =============================================================================

export { onUserCreate } from "./on_user_create";
export { onChildCreate, onChildUpdate } from "./on_child_create";
export { onStoryCompleted } from "./on_story_completed";

// =============================================================================
// HTTP WEBHOOKS
// =============================================================================

export { playWebhook } from "./play_webhook";
export { appStoreWebhook } from "./app_store_webhook";

// =============================================================================
// SCHEDULED
// =============================================================================

export { coppaCleanup } from "./coppa_cleanup";

// =============================================================================
// HELPERS EXPORTADOS ( para uso en tests )
// =============================================================================

export { evaluateAchievementsForChild } from "./achievement_engine";
export { checkRateLimit, enforceRateLimit } from "./rate_limiter";
export {
  writeAuditLog,
  requireAuth,
  assertIntInRange,
  assertNonEmptyString,
  slugify,
  hashString,
  generateMathChallenge,
} from "./utils";
