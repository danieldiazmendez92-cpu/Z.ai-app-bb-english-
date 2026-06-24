/**
 * Cloud Function trigger `onStoryCompleted`.
 *
 * Firestore trigger `onUpdate` en `user_progress` que cuando el campo
 * `completed` pasa de `false` a `true`, dispara `achievementEngine` para
 * evaluar si el nino desbloqueo nuevos logros.
 *
 * Referencia: `docs/06-roadmap.md` Sprint 1.5 ( T1.5.12 ) y Sprint 2.1 ( T2.1.2 ).
 */

import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";

import { defaultRegion } from "./config";
import { evaluateAchievementsForChild } from "./achievement_engine";

/**
 * Trigger onUpdate en `user_progress/{progressId}`.
 *
 * Solo dispara la evaluacion de logros si `completed` cambio de false a true.
 * Es idempotente: si el trigger se ejecuta varias veces para el mismo cambio
 * ( retries ), `achievementEngine` verifica internamente que no se recreen
 * logros ya desbloqueados.
 */
export const onStoryCompleted = onDocumentUpdated(
  {
    document: "user_progress/{progressId}",
    region: defaultRegion,
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  async (event) => {
    const progressId = event.params.progressId;
    if (!progressId) {
      logger.warn("onStoryCompleted disparado sin progressId");
      return;
    }

    const before = event.data?.before?.data() as { completed?: boolean } | undefined;
    const after = event.data?.after?.data() as
      | { completed?: boolean; child_id?: string; story_id?: string }
      | undefined;

    if (!before || !after) {
      logger.warn(
        `onStoryCompleted sin before/after para progressId=${progressId}`,
      );
      return;
    }

    // Solo disparar si completed paso de false/undefined a true
    const wasCompleted = before.completed === true;
    const isCompleted = after.completed === true;
    if (wasCompleted || !isCompleted) {
      return;
    }

    const childId = after.child_id;
    if (!childId) {
      logger.error(
        `user_progress/${progressId} completado sin child_id. No se evaluan logros.`,
      );
      return;
    }

    logger.info(
      `onStoryCompleted: childId=${childId} storyId=${after.story_id} progressId=${progressId}`,
    );

    try {
      const newlyUnlocked = await evaluateAchievementsForChild(childId);
      logger.info(
        `Logros nuevos tras completar story=${after.story_id}: ${newlyUnlocked.length}`,
        { newlyUnlocked },
      );

      // TODO(P2): enviar push notification al dispositivo del padre/niño
      // cuando se desbloquea un logro ( Firebase Cloud Messaging ).
    } catch (err) {
      logger.error(
        `Error en onStoryCompleted para progressId=${progressId}`,
        err,
      );
      // No rethrow: los triggers onUpdate no deben bloquear la escritura.
    }
  },
);
