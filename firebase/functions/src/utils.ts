/**
 * Helper utilities comunes a multiples Cloud Functions.
 */

import { logger } from "firebase-functions/v2";
import { HttpsError } from "firebase-functions/v2/https";

import { db } from "./firebase";
import type { AuditAction } from "./types";

/**
 * Crea una entrada en `audit_log` para compliance ( COPPA / GDPR-K ).
 *
 * @param actorUid  UID del usuario que realizo la accion.
 * @param action    Tipo de accion.
 * @param targetId  ID del recurso afectado ( opcional ).
 * @param ipHash    Hash SHA-256 de la IP del cliente ( nunca la IP real ).
 * @param metadata  Datos adicionales especificos de la accion.
 */
export async function writeAuditLog(
  actorUid: string,
  action: AuditAction,
  targetId: string | null,
  ipHash: string,
  metadata: Record<string, unknown> = {},
): Promise<void> {
  try {
    const event_id = `${actorUid}_${action}_${Date.now()}_${Math.random()
      .toString(36)
      .slice(2, 8)}`;
    await db.collection("audit_log").doc(event_id).set({
      event_id,
      actor_uid: actorUid,
      action,
      target_id: targetId,
      occurred_at: new Date(),
      ip_hash: ipHash,
      metadata,
    });
  } catch (err) {
    // No bloqueamos la operacion principal si el audit log falla, pero
    // logueamos para alertar.
    logger.error("Error escribiendo audit_log", err, { actorUid, action });
  }
}

/**
 * Obtiene el UID autenticado del contexto de una callable.
 * Lanza HttpsError unauthenticated si no hay auth.
 */
export function requireAuth(
  auth: { uid: string } | undefined,
): string {
  if (!auth || !auth.uid) {
    throw new HttpsError(
      "unauthenticated",
      "Debes estar autenticado para realizar esta accion.",
    );
  }
  return auth.uid;
}

/**
 * Valida que un string sea un entero entre min y max.
 */
export function assertIntInRange(
  value: unknown,
  min: number,
  max: number,
  fieldName: string,
): number {
  const n = typeof value === "string" ? parseInt(value, 10) : Number(value);
  if (!Number.isInteger(n) || n < min || n > max) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} debe ser un entero entre ${min} y ${max}.`,
    );
  }
  return n;
}

/**
 * Valida que un string no este vacio y cumpla con un maximo de longitud.
 */
export function assertNonEmptyString(
  value: unknown,
  fieldName: string,
  maxLength = 10000,
): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} es obligatorio.`,
    );
  }
  if (value.length > maxLength) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} no puede exceder ${maxLength} caracteres.`,
    );
  }
  return value;
}

/**
 * Convierte un string a slug ( para IDs de cuentos ).
 * Ej: "Little Red Riding Hood" -> "little-red-riding-hood"
 */
export function slugify(input: string): string {
  return input
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/[\s_-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

/**
 * Hash SHA-256 de un string ( para IPs ). Devuelve hex.
 */
export function hashString(input: string): string {
  // Implementacion simple sin dependencias externas ( node:crypto ).
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const crypto = require("node:crypto");
  return crypto.createHash("sha256").update(input).digest("hex");
}

/**
 * Genera 3 preguntas matematicas aleatorias y sus respuestas correctas.
 * Se usan para el challenge de verificacion parental.
 *
 * @returns Tupla [ preguntas, respuestas ] donde preguntas es un array de
 *          strings legibles y respuestas es un array de numbers.
 */
export function generateMathChallenge(): {
  questions: string[];
  answers: number[];
} {
  const questions: string[] = [];
  const answers: number[] = [];
  for (let i = 0; i < 3; i++) {
    const a = 5 + Math.floor(Math.random() * 15); // 5-19
    const b = 5 + Math.floor(Math.random() * 15); // 5-19
    questions.push(`Cuanto es ${a} + ${b}?`);
    answers.push(a + b);
  }
  return { questions, answers };
}
