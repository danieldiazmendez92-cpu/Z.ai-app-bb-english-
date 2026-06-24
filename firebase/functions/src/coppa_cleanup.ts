/**
 * Cloud Function scheduled `coppaCleanup`.
 *
 * Cron diario ( 03:00 UTC ) que:
 *  1. Busca `children_profiles` con `deleted_at` > 30 dias.
 *  2. Para cada uno, borra fisicamente:
 *     - `children_profiles/{childId}`
 *     - Todos los `user_progress` donde `child_id == childId`.
 *     - Todos los `user_achievements` donde `child_id == childId`.
 *     - Todos los `reading_sessions` donde `child_id == childId`.
 *     - Todos los `analytics_events` donde `child_id_hash` ( hashed ) matchee.
 *     - El avatar en Cloud Storage `users/{uid}/children/{childId}/avatar.png`.
 *  3. Decrementa `users.children_count`.
 *  4. Escribe audit log.
 *
 * Referencia: `docs/05-security-and-privacy.md` seccion 5 ( derecho al
 * borrado ), `docs/06-roadmap.md` Sprint 3.3 ( T3.3.6 ).
 */

import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion, BUSINESS_RULES } from "./config";
import { db, bucket } from "./firebase";
import { writeAuditLog, hashString } from "./utils";
import type { ChildProfile } from "./types";

/**
 * Scheduled function que corre diariamente a las 03:00 UTC.
 *
 * Configura `maxInstances: 1` para evitar ejecuciones paralelas ( que podrian
 * duplicar borrados ).
 */
export const coppaCleanup = onSchedule(
  {
    schedule: "0 3 * * *",
    region: defaultRegion,
    memory: "512MiB",
    timeoutSeconds: 540, // 9 minutos
    maxInstances: 1,
  },
  async () => {
    logger.info("coppaCleanup: iniciando cron de borrado fisico COPPA");

    const cutoffDate = new Date(
      Date.now() - BUSINESS_RULES.COPPA_GRACE_DAYS * 24 * 60 * 60 * 1000,
    );
    logger.info(`coppaCleanup: cutoff date = ${cutoffDate.toISOString()}`);

    try {
      // Buscar children_profiles con deleted_at != null AND deleted_at < cutoff
      const toDeleteSnap = await db
        .collection("children_profiles")
        .where("deleted_at", "<", cutoffDate)
        .get();

      if (toDeleteSnap.empty) {
        logger.info("coppaCleanup: no hay perfiles pendientes de borrado.");
        return;
      }

      logger.info(
        `coppaCleanup: ${toDeleteSnap.size} perfiles pendientes de borrado fisico.`,
      );

      for (const doc of toDeleteSnap.docs) {
        try {
          await deleteChildDataCompletely(doc.id, doc.data() as ChildProfile);
        } catch (err) {
          logger.error(
            `coppaCleanup: error borrando childId=${doc.id}`,
            err,
          );
          // Continuamos con el siguiente
        }
      }

      logger.info("coppaCleanup: cron finalizado OK.");
    } catch (err) {
      logger.error("coppaCleanup: error fatal", err);
    }
  },
);

/**
 * Borra fisicamente TODOS los datos asociados a un childId.
 */
async function deleteChildDataCompletely(
  childId: string,
  child: ChildProfile,
): Promise<void> {
  const userUid = child.user_uid;
  logger.info(
    `Borrando datos de childId=${childId} userUid=${userUid}`,
    { deletedAt: child.deleted_at },
  );

  // 1. Borrar user_progress
  const progressSnap = await db
    .collection("user_progress")
    .where("child_id", "==", childId)
    .get();
  const progressBatch = db.batch();
  progressSnap.docs.forEach((d) => progressBatch.delete(d.ref));
  await progressBatch.commit();
  logger.info(`  - user_progress: ${progressSnap.size} docs borrados`);

  // 2. Borrar user_achievements
  const achSnap = await db
    .collection("user_achievements")
    .where("child_id", "==", childId)
    .get();
  const achBatch = db.batch();
  achSnap.docs.forEach((d) => achBatch.delete(d.ref));
  await achBatch.commit();
  logger.info(`  - user_achievements: ${achSnap.size} docs borrados`);

  // 3. Borrar reading_sessions
  const sessionsSnap = await db
    .collection("reading_sessions")
    .where("child_id", "==", childId)
    .get();
  const sessBatch = db.batch();
  sessionsSnap.docs.forEach((d) => sessBatch.delete(d.ref));
  await sessBatch.commit();
  logger.info(`  - reading_sessions: ${sessionsSnap.size} docs borrados`);

  // 4. Borrar analytics_events ( usamos hashed child_id )
  const childIdHash = hashString(childId);
  try {
    const eventsSnap = await db
      .collection("analytics_events")
      .where("child_id_hash", "==", childIdHash)
      .get();
    const evBatch = db.batch();
    eventsSnap.docs.forEach((d) => evBatch.delete(d.ref));
    await evBatch.commit();
    logger.info(`  - analytics_events: ${eventsSnap.size} docs borrados`);
  } catch (err) {
    logger.warn(`  - analytics_events: error ( continuando )`, err);
  }

  // 5. Borrar avatar en Cloud Storage
  try {
    const avatarPath = `users/${userUid}/children/${childId}/avatar.png`;
    await bucket.file(avatarPath).delete({ ignoreNotFound: true });
    logger.info(`  - storage avatar: ${avatarPath} borrado`);
  } catch (err) {
    logger.warn(`  - storage avatar: error ( continuando )`, err);
  }

  // 6. Borrar el documento children_profiles
  await db.collection("children_profiles").doc(childId).delete();
  logger.info(`  - children_profiles: doc borrado`);

  // 7. Decrementar users.children_count
  await db
    .collection("users")
    .doc(userUid)
    .set(
      {
        children_count: FieldValue.increment(-1),
        updated_at: FieldValue.serverTimestamp() as never,
      },
      { merge: true },
    );

  // 8. Audit log
  await writeAuditLog(
    userUid,
    "data_deleted",
    childId,
    "coppa_cleanup_cron",
    {
      reason: "coppa_grace_period_expired",
      grace_days: BUSINESS_RULES.COPPA_GRACE_DAYS,
      deleted: {
        user_progress: progressSnap.size,
        user_achievements: achSnap.size,
        reading_sessions: sessionsSnap.size,
      },
    },
  );

  logger.info(`childId=${childId} borrado completamente OK.`);
}
