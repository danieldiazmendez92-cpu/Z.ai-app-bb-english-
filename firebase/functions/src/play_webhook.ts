/**
 * Cloud Function HTTP `playWebhook`.
 *
 * Recibe Real-time Developer Notifications ( RTDN ) de Google Play Pub/Sub.
 *
 * Flujo:
 *  1. Google Play publica un mensaje en el topic `play-developer-notifications`
 *     configurado en Google Play Console.
 *  2. Un subscription push a esta Cloud Function con el mensaje en el body.
 *  3. Decodificamos el base64 message.data y parseamos el JSON.
 *  4. Identificamos el `purchaseToken` y `subscriptionNotification` .
 *  5. Llamamos a Play Developer API para obtener el estado actualizado.
 *  6. Actualizamos `subscriptions/{userUid}_android` y `users.is_premium`.
 *
 * Idempotencia: si recibimos la misma notificacion varias veces ( retries de
 * Pub/Sub ), la operacion es idempotente porque usamos set({ merge: true }).
 *
 * Referencia: `docs/06-roadmap.md` Sprint 3.1 ( T3.1.8 ).
 */

import { onRequest } from "firebase-functions/v2/https";
import type { Response, Request as ExpressRequest } from "express";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";
import { google } from "googleapis";

import { defaultRegion } from "./config";
import { playServiceAccountJson, playPackageName } from "./config";
import { db } from "./firebase";
import { writeAuditLog } from "./utils";
import type { Subscription, SubscriptionStatus } from "./types";

let playClientCache: { androidpublisher: ReturnType<typeof google.androidpublisher> } | null = null;
function getPlayClient() {
  if (!playServiceAccountJson) {
    throw new Error("PLAY_SERVICE_ACCOUNT_JSON no configurado.");
  }
  if (!playClientCache) {
    const auth = new google.auth.GoogleAuth({
      credentials: JSON.parse(playServiceAccountJson),
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    });
    playClientCache = {
      androidpublisher: google.androidpublisher({ version: "v3", auth }),
    };
  }
  return playClientCache.androidpublisher;
}

/**
 * HTTP function para recibir RTDN de Google Play.
 *
 * El endpoint es publico ( Google Pub/Sub no envia Authorization ); la
 * validacion se hace por estructura del mensaje y por el hecho de que el
 * purchaseToken solo es valido via Play Developer API.
 *
 * Para mayor seguridad, configurar `PLAY_WEBHOOK_SECRET` y validar query
 * param `?secret=...` ( no implementado en este scaffold ).
 */
export const playWebhook = onRequest(
  {
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 60,
    maxInstances: 10,
  },
  async (req: ExpressRequest, res: Response) => {
    // Solo aceptar POST
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const body = req.body as {
        message?: { data?: string; messageId?: string };
      };

      if (!body?.message?.data) {
        logger.warn("playWebhook: mensaje sin data");
        res.status(400).send("Bad Request: missing message.data");
        return;
      }

      // Decodificar base64
      const decoded = Buffer.from(body.message.data, "base64").toString("utf8");
      const notification = JSON.parse(decoded) as {
        version?: string;
        packageName?: string;
        eventTimeMillis?: string;
        subscriptionNotification?: {
          version?: string;
          notificationType: number;
          purchaseToken: string;
          subscriptionId: string;
        };
        voidedPurchaseNotification?: unknown;
        testNotification?: unknown;
      };

      logger.info("playWebhook: notification recibida", {
        messageId: body.message.messageId,
        packageName: notification.packageName,
        notificationType: notification.subscriptionNotification?.notificationType,
      });

      // Validar que sea para nuestro package
      if (notification.packageName !== playPackageName) {
        logger.warn(
          `playWebhook: packageName mismatch (${notification.packageName})`,
        );
        res.status(200).send("OK - ignored package");
        return;
      }

      // Procesar subscriptionNotification si viene
      const subNotif = notification.subscriptionNotification;
      if (subNotif?.purchaseToken) {
        await processSubscriptionNotification(
          subNotif.purchaseToken,
          subNotif.subscriptionId,
          subNotif.notificationType,
        );
      }

      // 200 OK siempre para que Pub/Sub no reintente
      res.status(200).send("OK");
    } catch (err) {
      logger.error("Error en playWebhook", err);
      // Devolvemos 200 igual para evitar retries infinitos; el error esta
      // logueado para investigacion.
      res.status(200).send("OK - error logged");
    }
  },
);

/**
 * Procesa una notificacion de suscripcion consultando Play Developer API.
 */
async function processSubscriptionNotification(
  purchaseToken: string,
  subscriptionId: string,
  notificationType: number,
): Promise<void> {
  try {
    const client = getPlayClient();
    const res = await client.purchases.subscriptionsv2.get({
      packageName: playPackageName,
      token: purchaseToken,
    });
    const sub = res.data;
    if (!sub) {
      logger.warn("processSubscriptionNotification: sub vacio", {
        purchaseToken,
      });
      return;
    }

    const status = mapPlaySubscriptionState(sub.subscriptionState);
    const expiresAt = sub.lineItems?.[0]?.expiryTime
      ? new Date(sub.lineItems[0].expiryTime)
      : null;

    // Buscar el user_uid asociado al purchaseToken. Lo guardamos en
    // subscriptions.last_receipt_id cuando validatePlayReceipt se ejecuta.
    const subQuery = await db
      .collection("subscriptions")
      .where("last_receipt_id", "==", purchaseToken)
      .limit(1)
      .get();

    if (subQuery.empty) {
      logger.warn(
        `processSubscriptionNotification: no se encontro subscription para purchaseToken=${purchaseToken}. Se ignorara hasta que validatePlayReceipt se ejecute.`,
      );
      return;
    }

    const subDoc = subQuery.docs[0]!;
    const subData = subDoc.data() as Subscription;

    await subDoc.ref.set(
      {
        status,
        expires_at: expiresAt ?? subData.expires_at,
        auto_renew: sub.lineItems?.[0]?.autoRenewingPlan?.autoRenewEnabled ?? false,
        canceled_at:
          notificationType === 13 /* SUBSCRIPTION_CANCELED */ ||
          status === "canceled"
            ? FieldValue.serverTimestamp() as never
            : null,
        updated_at: FieldValue.serverTimestamp() as never,
      },
      { merge: true },
    );

    // Sincronizar users.is_premium
    const premiumStatuses: SubscriptionStatus[] = ["active", "grace_period"];
    const isPremium = premiumStatuses.includes(status);
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
      "play_webhook",
      { subscriptionId, notificationType, status },
    );

    logger.info(
      `playWebhook: subscription ${subDoc.id} actualizada status=${status}`,
    );
  } catch (err) {
    logger.error(
      `processSubscriptionNotification error para purchaseToken=${purchaseToken}`,
      err,
    );
  }
}

function mapPlaySubscriptionState(state?: string | null): SubscriptionStatus {
  if (!state) return "expired";
  if (state === "SUBSCRIPTION_STATE_ACTIVE") return "active";
  if (state === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD") return "grace_period";
  if (state === "SUBSCRIPTION_STATE_ON_HOLD") return "grace_period";
  if (state === "SUBSCRIPTION_STATE_CANCELED") return "canceled";
  if (state === "SUBSCRIPTION_STATE_EXPIRED") return "expired";
  return "expired";
}
