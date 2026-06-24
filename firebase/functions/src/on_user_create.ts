/**
 * Cloud Function trigger `onUserCreate`.
 *
 * Firestore trigger `onCreate` en `users/{uid}` que inicializa
 * `parental_settings` por defecto para el nuevo usuario.
 *
 * Esto evita que el cliente tenga que crear el documento de parental_settings
 * manualmente ( lo que podria dejar valores inconsistentes ).
 *
 * Referencia: `docs/06-roadmap.md` Sprint 1.1 ( T1.1.8 ).
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion } from "./config";
import { db } from "./firebase";
import type { ParentalSettings } from "./types";

/**
 * Trigger onCreate en `users/{uid}`.
 *
 * Crea `parental_settings/{uid}` con defaults COPPA-compliant:
 *  - allow_analytics = false ( opt-in )
 *  - allow_personalized_ads = false ( siempre )
 *  - daily_limit_minutes = 30 ( recomendado para ninos )
 *  - allow_offline_download = false ( requiere premium )
 */
export const onUserCreate = onDocumentCreated(
  {
    document: "users/{uid}",
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (event) => {
    const uid = event.params.uid;
    if (!uid) {
      logger.warn("onUserCreate disparado sin uid");
      return;
    }

    logger.info(`onUserCreate disparado para uid=${uid}`);

    try {
      const settingsRef = db.collection("parental_settings").doc(uid);
      const existing = await settingsRef.get();

      if (existing.exists) {
        logger.info(
          `parental_settings/${uid} ya existe; no se sobreescribe ( idempotente ).`,
        );
        return;
      }

      const defaultSettings: Omit<ParentalSettings, "user_uid"> = {
        daily_limit_minutes: 30,
        blocked_categories: [],
        allow_offline_download: false,
        allow_analytics: false, // COPPA opt-in, default false
        allow_personalized_ads: false, // COPPA inmutable
        bedtime_start: null,
        bedtime_end: null,
      };

      await settingsRef.set({
        ...defaultSettings,
        user_uid: uid,
        created_at: FieldValue.serverTimestamp(),
        updated_at: FieldValue.serverTimestamp(),
      });

      // Tambien inicializamos children_count = 0 en el documento de usuario.
      await db
        .collection("users")
        .doc(uid)
        .set(
          { children_count: 0, updated_at: FieldValue.serverTimestamp() },
          { merge: true },
        );

      logger.info(`parental_settings/${uid} creado con defaults COPPA.`);
    } catch (err) {
      logger.error(`Error en onUserCreate para uid=${uid}`, err);
      // No rethrow: los triggers onCreate no pueden "revertir" la creacion.
      // Si falla, el cliente vera que no tiene parental_settings y podra
      // crearlos manualmente como fallback.
    }
  },
);
