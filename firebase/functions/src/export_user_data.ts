/**
 * exportUserData - Cloud Function callable
 *
 * GDPR Art. 20 - Derecho a la portabilidad de los datos.
 * Recopila TODOS los datos del usuario + sus hijos en formato JSON.
 *
 * Datos recopilados:
 * - users/{uid}
 * - parental_settings/{uid}
 * - user_consents/{uid}
 * - subscriptions/{uid}_{platform}
 * - children_profiles (donde user_uid == uid)
 * - user_progress (donde child_id pertenece a un child del usuario)
 * - user_achievements (idem)
 * - reading_sessions (idem, últimos 90 días)
 * - audit_log (eventos del usuario)
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/init';
import { logger } from 'firebase-functions';

export const exportUserData = onCall(
  { region: 'us-central1', memory: '512MiB', maxInstances: 10 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Debes estar autenticado.');
    }

    const callerUid = request.auth.uid;
    const targetUid = (request.data as { uid?: string })?.uid || callerUid;

    // Solo el propio usuario o un admin puede exportar
    if (targetUid !== callerUid) {
      // TODO: verificar si callerUid es admin
      throw new HttpsError(
        'permission-denied',
        'Solo podés exportar tus propios datos.'
      );
    }

    logger.info(`exportUserData iniciado para ${targetUid}`);

    const db = getFirestore();
    const export: Record<string, unknown> = {
      _metadata: {
        exported_at: new Date().toISOString(),
        user_uid: targetUid,
        app: 'StoryEnglish Kids',
        version: '1.0',
      },
    };

    try {
      // 1. user doc
      const userDoc = await db.collection('users').doc(targetUid).get();
      export.user = userDoc.exists ? userDoc.data() : null;

      // 2. parental_settings
      const psDoc = await db
        .collection('parental_settings')
        .doc(targetUid)
        .get();
      export.parental_settings = psDoc.exists ? psDoc.data() : null;

      // 3. user_consents
      const ucDoc = await db.collection('user_consents').doc(targetUid).get();
      export.user_consents = ucDoc.exists ? ucDoc.data() : null;

      // 4. subscriptions
      const subSnap = await db
        .collection('subscriptions')
        .where('user_uid', '==', targetUid)
        .get();
      export.subscriptions = subSnap.docs.map((d) => d.data());

      // 5. children_profiles
      const childrenSnap = await db
        .collection('children_profiles')
        .where('user_uid', '==', targetUid)
        .get();
      const children = childrenSnap.docs.map((d) => d.data());
      export.children_profiles = children;

      // 6. user_progress, user_achievements, reading_sessions por cada child
      const childIds = children.map((c: any) => c.child_id);
      if (childIds.length > 0) {
        const [progressSnap, achievementsSnap, sessionsSnap] = await Promise.all([
          db
            .collection('user_progress')
            .where('child_id', 'in', childIds)
            .get(),
          db
            .collection('user_achievements')
            .where('child_id', 'in', childIds)
            .get(),
          db
            .collection('reading_sessions')
            .where('child_id', 'in', childIds)
            .limit(1000)
            .get(),
        ]);

        export.user_progress = progressSnap.docs.map((d) => d.data());
        export.user_achievements = achievementsSnap.docs.map((d) => d.data());
        export.reading_sessions = sessionsSnap.docs.map((d) => d.data());
      } else {
        export.user_progress = [];
        export.user_achievements = [];
        export.reading_sessions = [];
      }

      // 7. audit_log (eventos del usuario)
      const auditSnap = await db
        .collection('audit_log')
        .where('actor_uid', '==', targetUid)
        .limit(100)
        .get();
      export.audit_log = auditSnap.docs.map((d) => d.data());

      logger.info(
        `exportUserData completado para ${targetUid}: ${JSON.stringify(export).length} chars`
      );

      return {
        json: JSON.stringify(export, null, 2),
        size_bytes: JSON.stringify(export).length,
      };
    } catch (error) {
      logger.error('exportUserData error:', error);
      throw new HttpsError(
        'internal',
        'Error al exportar datos. Intentá de nuevo.'
      );
    }
  }
);
