/**
 * Cloud Function HTTP `appStoreWebhook`.
 *
 * Recibe App Store Server Notifications V2 ( signed payloads JWS ).
 *
 * Flujo:
 *  1. App Store envia un POST con body `{ signedPayload: "<JWS>" }`.
 *  2. Decodificamos el JWS ( sin validar firma en este scaffold ) para
 *     obtener el `responseBodyV2DecodedPayload`.
 *  3. Identificamos `signedTransactionInfo` y `signedRenewalInfo`.
 *  4. Mapeamos `notificationType` a estados internos.
 *  5. Actualizamos `subscriptions/{userUid}_ios` y `users.is_premium`.
 *
 * Idempotencia: usamos `transactionId` como dedupe key. Si procesamos la
 * misma notification dos veces, la operacion es idempotente por set merge.
 *
 * Referencia: `docs/06-roadmap.md` Sprint 3.1 ( T3.1.9 ).
 */

import { onRequest } from "firebase-functions/v2/https";
import type { Response, Request as ExpressRequest } from "express";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion } from "./config";
import { db } from "./firebase";
import { writeAuditLog } from "./utils";
import type { Subscription, SubscriptionStatus } from "./types";

/**
 * HTTP function para recibir App Store Server Notifications V2.
 */
export const appStoreWebhook = onRequest(
  {
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 60,
    maxInstances: 10,
  },
  async (req: ExpressRequest, res: Response) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const body = req.body as { signedPayload?: string };
      if (!body?.signedPayload) {
        logger.warn("appStoreWebhook: missing signedPayload");
        res.status(400).send("Bad Request");
        return;
      }

      // Decodificar JWS sin validar firma ( TODO: validar con Apple Root CA ).
      const payload = decodeJwsPayload(body.signedPayload) as {
        notificationType?: string;
        subtype?: string;
        data?: {
          signedTransactionInfo?: string;
          signedRenewalInfo?: string;
          environment?: string;
          bundleId?: string;
        };
      };

      logger.info("appStoreWebhook: notification recibida", {
        notificationType: payload.notificationType,
        subtype: payload.subtype,
        bundleId: payload.data?.bundleId,
      });

      if (!payload.data?.signedTransactionInfo) {
        logger.warn("appStoreWebhook: payload sin signedTransactionInfo");
        res.status(200).send("OK - no transaction info");
        return;
      }

      const tx = decodeJwsPayload(payload.data.signedTransactionInfo) as {
        originalTransactionId?: string;
        transactionId?: string;
        productId?: string;
        expiresDateMs?: number;
        purchaseDateMs?: number;
        revocationDateMs?: number;
        bundleId?: string;
      };

      if (!tx.originalTransactionId) {
        logger.warn("appStoreWebhook: tx sin originalTransactionId");
        res.status(200).send("OK - no tx id");
        return;
      }

      await processAppStoreNotification(
        payload.notificationType ?? "UNKNOWN",
        tx,
      );

      res.status(200).send("OK");
    } catch (err) {
      logger.error("Error en appStoreWebhook", err);
      res.status(200).send("OK - error logged");
    }
  },
);

/**
 * Procesa una notification de App Store: actualiza `subscriptions` y
 * `users.is_premium`.
 */
async function processAppStoreNotification(
  notificationType: string,
  tx: {
    originalTransactionId?: string;
    transactionId?: string;
    productId?: string;
    expiresDateMs?: number;
    purchaseDateMs?: number;
    revocationDateMs?: number;
    bundleId?: string;
  },
): Promise<void> {
  // Buscar la subscription por transactionId ( guardado en last_receipt_id )
  const txId = tx.originalTransactionId ?? tx.transactionId;
  if (!txId) return;

  const subQuery = await db
    .collection("subscriptions")
    .where("last_receipt_id", "==", txId)
    .limit(1)
    .get();

  if (subQuery.empty) {
    logger.warn(
      `appStoreWebhook: no se encontro subscription para txId=${txId}. Se ignora hasta que validateAppStoreReceipt se ejecute.`,
    );
    return;
  }

  const subDoc = subQuery.docs[0]!;
  const subData = subDoc.data() as Subscription;

  const status = mapAppStoreNotificationType(notificationType, tx);
  const expiresAt = tx.expiresDateMs
    ? new Date(parseInt(String(tx.expiresDateMs), 10))
    : null;

  await subDoc.ref.set(
    {
      status,
      expires_at: expiresAt ?? subData.expires_at,
      canceled_at:
        status === "canceled"
          ? FieldValue.serverTimestamp() as never
          : null,
      updated_at: FieldValue.serverTimestamp() as never,
    },
    { merge: true },
  );

  const isPremium = status === "active" || status === "grace_period";
  await db
    .collection("users")
    .doc(subData.user_uid)
    .set(
      {
        is_premium: isPremium,
        premium_expires_at: isPremium ? expiresAt : null,
        updated_at: FieldValue.serverTimestamp() as never,
      },
      { merge: true },
    );

  await writeAuditLog(
    subData.user_uid,
    status === "canceled" || status === "expired"
      ? "subscription_canceled"
      : "subscription_started",
    subDoc.id,
    "appstore_webhook",
    { notificationType, txId },
  );

  logger.info(
    `appStoreWebhook: subscription ${subDoc.id} actualizada status=${status}`,
  );
}

/**
 * Mapea el notificationType de App Store a estado interno.
 *
 * Tipos relevantes ( App Store Server Notifications V2 ):
 *  - DID_RENEW: subscripcion renovada -> active
 *  - EXPIRED: expiro -> expired
 *  - GRACE_PERIOD_EXPIRED: termino el grace period -> expired
 *  - DID_FAIL_TO_RENEW: fallo el renew -> grace_period
 *  - REFUND: reembolsado -> canceled
 *  - REVOKE: revocado por family sharing -> canceled
 *  - SUBSCRIBED: nueva suscripcion o reactivacion -> active
 *  - PRICE_INCREASE: cambio de precio ( no afecta estado )
 */
function mapAppStoreNotificationType(
  notificationType: string,
  tx: { revocationDateMs?: number; expiresDateMs?: number },
): SubscriptionStatus {
  if (tx.revocationDateMs != null) return "canceled";
  switch (notificationType) {
    case "SUBSCRIBED":
    case "DID_RENEW":
    case "OFFER_REDEEMED":
      return "active";
    case "DID_FAIL_TO_RENEW":
      return "grace_period";
    case "EXPIRED":
    case "GRACE_PERIOD_EXPIRED":
      return "expired";
    case "REFUND":
    case "REVOKE":
      return "canceled";
    default:
      // Default: mantener estado basado en expiryDate
      if (tx.expiresDateMs) {
        const expires = new Date(parseInt(String(tx.expiresDateMs), 10));
        return expires > new Date() ? "active" : "expired";
      }
      return "active";
  }
}

/**
 * Decodifica el payload de un JWS sin validar la firma.
 * Para produccion hay que validar con la Apple Root CA.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function decodeJwsPayload(jws: string): any {
  const parts = jws.split(".");
  if (parts.length < 2) return {};
  return JSON.parse(Buffer.from(parts[1]!, "base64url").toString("utf8"));
}
