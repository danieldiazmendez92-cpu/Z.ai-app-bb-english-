/**
 * Configuracion central de las Cloud Functions.
 *
 * Lee variables de entorno ( definidas en `functions/.env` y replicadas en
 * `firebase/functions/.env.example` ) y expone valores tipados. Usa
 * `functions.config()` como fallback para mantener compatibilidad con la CLI
 * legacy de Firebase.
 */

import { logger } from "firebase-functions/v2";

/**
 * Project ID de Firebase. En produccion viene inyectado por el runtime; en
 * local lo provee `FIREBASE_PROJECT_ID` o el emulador.
 */
export const projectId: string =
  process.env.GCLOUD_PROJECT ||
  process.env.FIREBASE_PROJECT_ID ||
  "storyenglish-kids-dev";

/**
 * Bucket default de Cloud Storage. Si no se especifica, Firebase usa
 * `{projectId}.appspot.com`.
 */
export const storageBucket: string =
  process.env.FIREBASE_STORAGE_BUCKET || `${projectId}.appspot.com`;

/**
 * Region preferida para deployar las Cloud Functions. Usamos `us-central1`
 * por defecto ( mejor cold start para usuarios en Americas ).
 */
export const defaultRegion: string =
  process.env.FUNCTIONS_REGION || "us-central1";

/**
 * API key de Google Gemini. Se obtiene en
 * https://aistudio.google.com/app/apikey
 */
export const geminiApiKey: string | undefined = process.env.GEMINI_API_KEY;

/**
 * Modelo de Gemini a utilizar. Por defecto `gemini-1.5-flash` ( rapido y
 * economico para tareas de procesamiento de texto ).
 */
export const geminiModel: string = process.env.GEMINI_MODEL || "gemini-1.5-flash";

/**
 * Voz de Google TTS a utilizar para narracion en ingles.
 * `en-US-Neural2-F` es voz femenina natural recomendada para contenido
 * infantil.
 */
export const ttsVoiceEn: string =
  process.env.GOOGLE_TTS_VOICE_EN || "en-US-Neural2-F";

/**
 * Voz de Google TTS para narracion en espanol ( premium ).
 */
export const ttsVoiceEs: string =
  process.env.GOOGLE_TTS_VOICE_ES || "es-US-Neural2-C";

/**
 * JSON de la service account de Google Play Developer API. Formato string
 * ( contenido del archivo `.json` descargado de Google Cloud Console ).
 */
export const playServiceAccountJson: string | undefined =
  process.env.PLAY_SERVICE_ACCOUNT_JSON;

/**
 * Package name de la app en Google Play ( ej: `com.storyenglish.kids` ).
 */
export const playPackageName: string =
  process.env.PLAY_PACKAGE_NAME || "com.storyenglish.kids";

/**
 * Issuer ID de App Store Server API ( obtenido en App Store Connect > Users
 * and Access > Keys > In-App Purchase ).
 */
export const appStoreIssuerId: string | undefined =
  process.env.APP_STORE_ISSUER_ID;

/**
 * Key ID de App Store Server API.
 */
export const appStoreKeyId: string | undefined = process.env.APP_STORE_KEY_ID;

/**
 * Private key (.p8) de App Store Server API. En el .env debe estar en una
 * sola linea con `\n` escapados.
 */
export const appStorePrivateKey: string | undefined =
  process.env.APP_STORE_PRIVATE_KEY;

/**
 * Bundle ID de la app iOS.
 */
export const appStoreBundleId: string =
  process.env.APP_STORE_BUNDLE_ID || "com.storyenglish.kids";

/**
 * URL base del entorno de App Store Server API. En sandbox usar
 * `https://api.storekit-sandbox.itunes.apple.com`.
 */
export const appStoreBaseUrl: string =
  process.env.APP_STORE_BASE_URL ||
  "https://api.storekit.itunes.apple.com";

/**
 * Secret compartido para validar webhook de Google Play RTDN. Se configura en
 * Google Play Console > Developer options > Real-time developer notifications.
 */
export const playWebhookSecret: string | undefined =
  process.env.PLAY_WEBHOOK_SECRET;

/**
 * Secret compartido para validar webhook de App Store Server Notifications V2.
 * Se configura en App Store Connect > App > App Information > App Store Server
 * Notifications V2 > Shared secret.
 */
export const appStoreWebhookSecret: string | undefined =
  process.env.APP_STORE_WEBHOOK_SECRET;

/**
 * Valida que las variables de entorno criticas esten presentes. Las faltantes
 * se loguean como warning pero no se lanza error para permitir arrancar en
 * modo emulador.
 */
export function validateConfig(): void {
  const missing: string[] = [];
  if (!geminiApiKey) missing.push("GEMINI_API_KEY");
  if (!playServiceAccountJson) missing.push("PLAY_SERVICE_ACCOUNT_JSON");
  if (!appStoreIssuerId) missing.push("APP_STORE_ISSUER_ID");
  if (!appStoreKeyId) missing.push("APP_STORE_KEY_ID");
  if (!appStorePrivateKey) missing.push("APP_STORE_PRIVATE_KEY");

  if (missing.length > 0) {
    logger.warn(
      `Variables de entorno faltantes (algunas funciones fallaran en runtime): ${missing.join(", ")}`,
      { missing },
    );
  } else {
    logger.info("Configuracion de Cloud Functions validada OK.");
  }
}

/**
 * Constantes de negocio ( alineadas con `docs/04-firestore-schema.md` ).
 */
export const BUSINESS_RULES = {
  /** Edad minima de un nino */
  MIN_AGE: 2,
  /** Edad maxima de un nino */
  MAX_AGE: 7,
  /** Maximo de perfiles de nino por padre */
  MAX_CHILDREN_PER_USER: 4,
  /** Longitud minima del nombre del nino */
  CHILD_NAME_MIN_LENGTH: 1,
  /** Longitud maxima del nombre del nino ( COPPA ) */
  CHILD_NAME_MAX_LENGTH: 20,
  /** Dias de retencion de reading_sessions antes de archivar a BigQuery */
  READING_SESSION_TTL_DAYS: 90,
  /** Dias tras soft delete antes de borrar fisicamente datos del nino */
  COPPA_GRACE_DAYS: 30,
  /** Maximo de minutos de uso diario permitido */
  MAX_DAILY_LIMIT_MINUTES: 480,
} as const;

/**
 * Configuracion de rate limiting por accion.
 * Alinia con `docs/05-security-and-privacy.md` seccion 8.
 */
export const RATE_LIMITS: Record<string, { max: number; windowSeconds: number }> =
  {
    verify_parental: { max: 3, windowSeconds: 60 * 60 }, // 3 / hora
    validate_play_receipt: { max: 10, windowSeconds: 60 * 60 * 24 }, // 10 / dia
    validate_appstore_receipt: { max: 10, windowSeconds: 60 * 60 * 24 }, // 10 / dia
    story_ingest: { max: 20, windowSeconds: 60 * 60 * 24 }, // 20 / dia ( admin )
    record_analytics_event: { max: 100, windowSeconds: 60 }, // 100 / minuto
    update_progress: { max: 6, windowSeconds: 60 }, // 6 / minuto
  };
