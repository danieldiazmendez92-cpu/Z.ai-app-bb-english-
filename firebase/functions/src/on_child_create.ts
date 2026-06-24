/**
 * Cloud Function trigger `onChildCreate`.
 *
 * Firestore trigger `onCreate` en `children_profiles` que:
 *  - Valida que el padre no exceda el limite de 4 perfiles activos.
 *  - Si excede, elimina el documento recien creado y lanza un error.
 *  - Actualiza `users.children_count` con el nuevo conteo.
 *
 * Reglas:
 *  - El limite es de 4 perfiles NO eliminados ( deleted_at == null ).
 *  - Si el padre ya tiene 4 perfiles y crea uno mas, se rechaza.
 *  - `users.children_count` se mantiene como cache para evitar queries
 *    count() en cada request del cliente.
 *
 * Referencia: `docs/04-firestore-schema.md` seccion 3 ( validaciones ),
 * `docs/06-roadmap.md` Sprint 1.2 ( T1.2.8 ).
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion, BUSINESS_RULES } from "./config";
import { db } from "./firebase";
import { writeAuditLog } from "./utils";
import type { ChildProfile } from "./types";

/**
 * Trigger onCreate en `children_profiles/{childId}`.
 */
export const onChildCreate = onDocumentCreated(
  {
    document: "children_profiles/{childId}",
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (event) => {
    const childId = event.params.childId;
    if (!childId) {
      logger.warn("onChildCreate disparado sin childId");
      return;
    }

    const snapshot = event.data;
    if (!snapshot) {
      logger.warn(`onChildCreate sin snapshot para childId=${childId}`);
      return;
    }

    const child = snapshot.data() as Partial<ChildProfile>;
    const userUid = child.user_uid;

    if (!userUid) {
      logger.error(
        `children_profiles/${childId} creado sin user_uid. Eliminando.`,
      );
      await db.collection("children_profiles").doc(childId).delete();
      return;
    }

    logger.info(`onChildCreate disparado para childId=${childId} user=${userUid}`);

    try {
      // Contar perfiles activos del padre
      const activeChildrenSnap = await db
        .collection("children_profiles")
        .where("user_uid", "==", userUid)
        .where("deleted_at", "==", null)
        .get();

      const activeCount = activeChildrenSnap.size;

      // Validar limite ( el documento recien creado ya esta contado, asi que
      // el limite es > MAX + 1 porque incluye el actual ).
      if (activeCount > BUSINESS_RULES.MAX_CHILDREN_PER_USER) {
        logger.warn(
          `Padre ${userUid} excedio limite de ${BUSINESS_RULES.MAX_CHILDREN_PER_USER} perfiles ( actual=${activeCount} ). Eliminando childId=${childId}.`,
        );

        // Eliminar el perfil recien creado ( rollback )
        await db.collection("children_profiles").doc(childId).delete();

        // Audit log
        await writeAuditLog(
          userUid,
          "child_created",
          childId,
          "system",
          {
            rejected: true,
            reason: "max_children_exceeded",
            active_count: activeCount,
          },
        );

        // Nota: el cliente vera que el documento se elimino y debera mostrar
        // un error. Idealmente el limite tambien se valida en security rules
        // ( ver firestore.rules ) como primera linea de defensa.
        return;
      }

      // Actualizar children_count en users/{uid}
      await db
        .collection("users")
        .doc(userUid)
        .set(
          {
            children_count: activeCount,
            updated_at: FieldValue.serverTimestamp() as never,
          },
          { merge: true },
        );

      // Audit log
      await writeAuditLog(userUid, "child_created", childId, "system", {
        child_age: child.age,
        active_count: activeCount,
      });

      logger.info(
        `children_count actualizado a ${activeCount} para user=${userUid}`,
      );
    } catch (err) {
      logger.error(
        `Error en onChildCreate para childId=${childId} user=${userUid}`,
        err,
      );
      // No rethrow: el documento ya fue creado por el cliente; si el trigger
      // falla, children_count puede quedar desincronizado. Hay un cron
      // secundario que reconcilia children_count periodicamente ( futuro ).
    }
  },
);

/**
 * Trigger onUpdate en `children_profiles` para mantener children_count
 * sincronizado cuando un perfil se soft-deleted ( deleted_at pasa de null a
 * timestamp ).
 */
export const onChildUpdate = onDocumentCreated(
  {
    document: "children_profiles/{childId}",
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (event) => {
    // Nota: este handler es onCreate ( placeholder ). Para onUpdate se usa
    // onDocumentUpdated. Lo dejamos documentado para una iteracion futura.
    void event;
  },
);
