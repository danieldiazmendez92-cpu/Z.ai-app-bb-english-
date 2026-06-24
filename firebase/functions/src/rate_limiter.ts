/**
 * Rate limiting por UID usando Firestore counters.
 *
 * Implementacion basada en `docs/05-security-and-privacy.md` seccion 8. Cada
 * accion sensible ( verifyParental, validateReceipts, storyIngest ) usa una
 * coleccion `rate_limit/{uid}_{action}` con un documento que lleva el conteo
 * y un `window_start` que indica cuando empezo la ventana actual.
 *
 * Estrategia:
 *  - Si no existe documento para `{uid}_{action}`, se crea con count=1.
 *  - Si existe y la ventana sigue abierta ( now - window_start < windowSeconds ),
 *    se incrementa count. Si count > max, se rechaza.
 *  - Si existe y la ventana expiro, se resetea count=1 y window_start=now.
 *
 * Para evitar hot-spots en escritura, las actualizaciones usan `FieldValue.
 * serverTimestamp()` + `FieldValue.increment(1)` ( atomicos en Firestore ).
 */

import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError } from "firebase-functions/v2/https";

import { db } from "./firebase";
import { RATE_LIMITS } from "./config";
import type { RateLimitEntry } from "./types";

/**
 * Verifica y consume un intento de la accion `action` para el `uid`.
 *
 * @param uid   UID del usuario autenticado.
 * @param action Nombre de la accion ( debe existir en RATE_LIMITS ).
 * @throws {HttpsError} `resource-exhausted` si se excede el limite.
 * @returns Promise<void> si el intento fue aceptado.
 */
export async function checkRateLimit(
  uid: string,
  action: string,
): Promise<void> {
  const limit = RATE_LIMITS[action];
  if (!limit) {
    // Accion sin rate limit configurado: permitir
    logger.warn(`Rate limit no configurado para accion: ${action}`);
    return;
  }

  const docId = `${uid}_${action}`;
  const docRef = db.collection("rate_limit").doc(docId);

  try {
    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(docRef);
      const now = Date.now();
      const windowStartMs = now - limit.windowSeconds * 1000;

      if (!snap.exists) {
        const newEntry: Partial<RateLimitEntry> = {
          uid,
          action,
          count: 1,
          window_start: FieldValue.serverTimestamp() as never,
          last_attempt_at: FieldValue.serverTimestamp() as never,
        };
        tx.set(docRef, newEntry);
        return { allowed: true, count: 1 };
      }

      const data = snap.data() as RateLimitEntry;
      const windowStart = (data.window_start as unknown as { toMillis: () => number }).toMillis
        ? (data.window_start as unknown as { toMillis: () => number }).toMillis()
        : (data.window_start as unknown as { _seconds: number })._seconds * 1000;

      if (windowStart < windowStartMs) {
        // Ventana expirada: resetear
        tx.update(docRef, {
          count: 1,
          window_start: FieldValue.serverTimestamp() as never,
          last_attempt_at: FieldValue.serverTimestamp() as never,
        });
        return { allowed: true, count: 1 };
      }

      // Ventana activa
      if (data.count >= limit.max) {
        return { allowed: false, count: data.count };
      }

      tx.update(docRef, {
        count: FieldValue.increment(1),
        last_attempt_at: FieldValue.serverTimestamp() as never,
      });
      return { allowed: true, count: data.count + 1 };
    });

    if (!result.allowed) {
      logger.warn(`Rate limit excedido para uid=${uid} action=${action}`, {
        count: result.count,
        max: limit.max,
        windowSeconds: limit.windowSeconds,
      });
      throw new HttpsError(
        "resource-exhausted",
        `Has excedido el limite de ${limit.max} intentos por ${Math.floor(
          limit.windowSeconds / 60,
        )} minutos. Intenta mas tarde.`,
      );
    }
  } catch (err) {
    if (err instanceof HttpsError) {
      throw err;
    }
    logger.error(
      `Error verificando rate limit para uid=${uid} action=${action}`,
      err,
    );
    // En caso de error de infraestructura, permitir el intento para no bloquear UX
    // pero loguear para investigar.
  }
}

/**
 * Helper para chequear rate limit y lanzar HttpsError si se excede.
 * Pensado para usarse al inicio de callables.
 */
export function enforceRateLimit(uid: string, action: string): Promise<void> {
  return checkRateLimit(uid, action);
}
