/**
 * Cloud Function `verifyParental`.
 *
 * Verifica que el usuario es un adulto mediante un challenge de 3 preguntas
 * matematicas. Si las 3 respuestas son correctas, actualiza
 * `users/{uid}.parental_verified_at = now` en Firestore.
 *
 * Reglas:
 *  - Rate limit: 3 intentos / hora ( accion `verify_parental` ).
 *  - Si `parental_verified_at` ya estaba seteado, no se sobreescribe.
 *  - Las preguntas se generan en el cliente ( `generateMathChallenge` no se
 *    expone por seguridad de rate limiting; el cliente las pide una vez por
 *    sesion ). Para este MVP, el cliente envia las 3 respuestas y se asume
 *    que las preguntas fueron las generadas en cliente con la misma formula.
 *    En una version futura el challenge se servira desde otra callable.
 *
 * Referencia: `docs/05-security-and-privacy.md` seccion 2, `docs/06-roadmap.md`
 * Sprint 1.1 ( T1.1.6 ).
 */

import { onCall, HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion } from "./config";
import { db } from "./firebase";
import { enforceRateLimit } from "./rate_limiter";
import { requireAuth, writeAuditLog, hashString } from "./utils";
import type { VerifyParentalRequest, VerifyParentalResponse } from "./types";

/**
 * Set de preguntas matematicas pre-armadas para el MVP.
 * En una version futura se serviran dinamicamente desde otra callable.
 *
 * El cliente recibe estas mismas preguntas ( hardcodeadas en la app ) y envia
 * las 3 respuestas en orden. Para validar, comparamos contra las respuestas
 * correctas conocidas.
 *
 * Nota: aunque el cliente conozca las preguntas, el rate limiting evita
 * fuerza bruta y la verificacion es una "senal" de adulto, no un mecanismo
 * criptografico.
 */
const EXPECTED_ANSWERS: number[] = [12, 18, 15]; // 7+5, 9+9, 8+7

/**
 * Callable `verifyParental`.
 *
 * @param request.data.answers Array de 3 numeros con las respuestas del usuario.
 * @returns `{ verified, verifiedAt, reason }`
 */
export const verifyParental = onCall(
  {
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 30,
    minInstances: 0,
    maxInstances: 50,
  },
  async (
    request: CallableRequest<VerifyParentalRequest>,
  ): Promise<VerifyParentalResponse> => {
    const uid = requireAuth(request.auth);
    await enforceRateLimit(uid, "verify_parental");

    const answers = request.data?.answers;
    if (!Array.isArray(answers) || answers.length !== 3) {
      throw new HttpsError(
        "invalid-argument",
        "Debes enviar 3 respuestas numericas.",
      );
    }

    // Validar que sean enteros
    for (const a of answers) {
      if (typeof a !== "number" || !Number.isInteger(a)) {
        throw new HttpsError(
          "invalid-argument",
          "Todas las respuestas deben ser enteros numericos.",
        );
      }
    }

    try {
      const userRef = db.collection("users").doc(uid);
      const userSnap = await userRef.get();

      if (!userSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Tu usuario no existe en Firestore. Contacta soporte.",
        );
      }

      const userData = userSnap.data() as { parental_verified_at?: unknown };

      // Si ya estaba verificado, no se hace nada ( idempotente ).
      if (userData.parental_verified_at != null) {
        logger.info(
          `Usuario ${uid} ya estaba parental-verified; no se actualiza.`,
        );
        return {
          verified: true,
          verifiedAt: (userData.parental_verified_at as { toDate: () => Date }).toDate().toISOString(),
          reason: "already_verified",
        };
      }

      // Validar respuestas
      const correct = answers.every(
        (a, idx) => a === EXPECTED_ANSWERS[idx],
      );

      if (!correct) {
        logger.warn(`Verificacion parental FALLIDA para uid=${uid}`, { answers });
        return {
          verified: false,
          verifiedAt: null,
          reason: "wrong_answers",
        };
      }

      // Actualizar Firestore
      await userRef.update({
        parental_verified_at: FieldValue.serverTimestamp() as never,
        updated_at: FieldValue.serverTimestamp() as never,
      });

      // Audit log ( sin IP real, solo hash si esta disponible )
      const ipHash = hashString(request.rawRequest?.ip ?? "unknown");
      await writeAuditLog(
        uid,
        "parental_verified",
        uid,
        ipHash,
        { method: "math_challenge" },
      );

      logger.info(`Verificacion parental OK para uid=${uid}`);

      // Releer para obtener el timestamp server-side
      const updated = await userRef.get();
      const updatedData = updated.data() as { parental_verified_at: { toDate: () => Date } };
      return {
        verified: true,
        verifiedAt: updatedData.parental_verified_at.toDate().toISOString(),
        reason: "ok",
      };
    } catch (err) {
      logger.error(`Error en verifyParental para uid=${uid}`, err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError(
        "internal",
        `Error al verificar parental: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  },
);
