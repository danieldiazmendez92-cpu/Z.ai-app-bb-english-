/**
 * Cloud Functions de validacion de receipts de billing.
 *
 *  - `validatePlayReceipt`: recibe `{ purchaseToken, productId }` y valida
 *    contra Google Play Developer API.
 *  - `validateAppStoreReceipt`: recibe `{ receiptData, transactionId }` y
 *    valida contra App Store Server API.
 *
 * Ambas funciones:
 *  - Tienen rate limit de 10 / dia ( accion `validate_play_receipt` /
 *    `validate_appstore_receipt` ).
 *  - Crea / actualiza documento en `subscriptions/{userUid}_{platform}`.
 *  - Sincroniza `users.is_premium` y `users.premium_expires_at`.
 *  - Escriben audit log.
 *
 * Referencia: `docs/06-roadmap.md` Sprint 3.1 ( T3.1.6, T3.1.7 ).
 */

import { onCall, HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";
import { google } from "googleapis";

import { defaultRegion } from "./config";
import {
  playServiceAccountJson,
  playPackageName,
  appStoreIssuerId,
  appStoreKeyId,
  appStorePrivateKey,
  appStoreBundleId,
  appStoreBaseUrl,
} from "./config";
import { db } from "./firebase";
import { enforceRateLimit } from "./rate_limiter";
import { requireAuth, writeAuditLog, hashString } from "./utils";
import type {
  ValidatePlayReceiptRequest,
  ValidateAppStoreReceiptRequest,
  ValidateReceiptResponse,
  Subscription,
  SubscriptionPlan,
  SubscriptionStatus,
} from "./types";

// =============================================================================
// GOOGLE PLAY
// =============================================================================

let playClientCache: { androidpublisher: ReturnType<typeof google.androidpublisher> } | null = null;
function getPlayClient() {
  if (!playServiceAccountJson) {
    throw new HttpsError(
      "failed-precondition",
      "PLAY_SERVICE_ACCOUNT_JSON no configurado.",
    );
  }
  if (!playClientCache) {
    const auth = new google.auth.GoogleAuth({
      credentials: JSON.parse(playServiceAccountJson),
      scopes: ["https://www.googleapis.com/auth/androidpublisher"],
    });
    playClientCache = {
      androidpublisher: google.androidpublisher({
        version: "v3",
        auth,
      }),
    };
  }
  return playClientCache.androidpublisher;
}

/**
 * Callable `validatePlayReceipt`.
 */
export const validatePlayReceipt = onCall(
  {
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 60,
    minInstances: 0,
    maxInstances: 10,
  },
  async (
    request: CallableRequest<ValidatePlayReceiptRequest>,
  ): Promise<ValidateReceiptResponse> => {
    const uid = requireAuth(request.auth);
    await enforceRateLimit(uid, "validate_play_receipt");

    const purchaseToken = request.data?.purchaseToken;
    const productId = request.data?.productId;
    if (!purchaseToken || typeof purchaseToken !== "string") {
      throw new HttpsError("invalid-argument", "purchaseToken es obligatorio.");
    }
    if (!productId || typeof productId !== "string") {
      throw new HttpsError("invalid-argument", "productId es obligatorio.");
    }

    logger.info(`validatePlayReceipt uid=${uid} product=${productId}`);

    try {
      const client = getPlayClient();
      const res = await client.purchases.subscriptionsv2.get({
        packageName: playPackageName,
        token: purchaseToken,
      });

      const sub = res.data;
      if (!sub) {
        return { valid: false, reason: "no_data_from_play" };
      }

      // Determinar estado y plan
      const status = mapPlaySubscriptionState(sub.subscriptionState);
      const plan: SubscriptionPlan =
        sub.lineItems?.[0]?.offerDetails?.basePlanId?.includes("annual") ||
        productId.includes("annual")
          ? "annual"
          : "monthly";

      const expiresAt = sub.lineItems?.[0]?.expiryTime
        ? new Date(sub.lineItems[0].expiryTime)
        : null;

      const subId = `${uid}_android`;
      const subData: Partial<Subscription> = {
        subscription_id: subId,
        user_uid: uid,
        plan,
        platform: "android",
        store_product_id: productId,
        started_at: (sub.startTime ?? new Date()) as never,
        expires_at: (expiresAt ?? new Date()) as never,
        auto_renew: sub.lineItems?.[0]?.autoRenewingPlan?.autoRenewEnabled ?? false,
        status,
        last_receipt_id: purchaseToken,
        canceled_at: null,
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const subDoc: any = {
        ...subData,
        updated_at: FieldValue.serverTimestamp(),
      };

      await db.collection("subscriptions").doc(subId).set(subDoc, { merge: true });

      // Sincronizar users.is_premium
      const premiumStatuses1: SubscriptionStatus[] = ["active", "grace_period"];
      const isPremium = premiumStatuses1.includes(status);
      await db
        .collection("users")
        .doc(uid)
        .set(
          {
            is_premium: isPremium,
            premium_expires_at: isPremium ? (expiresAt as never) : null,
            updated_at: FieldValue.serverTimestamp() as never,
          },
          { merge: true },
        );

      await writeAuditLog(
        uid,
        "subscription_started",
        subId,
        hashString(request.rawRequest?.ip ?? "unknown"),
        { platform: "android", productId, status, plan },
      );

      logger.info(`validatePlayReceipt OK uid=${uid} status=${status}`);

      return {
        valid: true,
        subscriptionId: subId,
        plan,
        status,
        expiresAt: expiresAt?.toISOString(),
      };
    } catch (err) {
      logger.error(`Error validatePlayReceipt uid=${uid}`, err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError(
        "internal",
        `Error validando receipt de Play: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  },
);

/**
 * Mapea el estado de Play Developer API al estado interno.
 */
function mapPlaySubscriptionState(
  state?: string | null,
): SubscriptionStatus {
  if (!state) return "expired";
  if (state === "SUBSCRIPTION_STATE_ACTIVE") return "active";
  if (state === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD") return "grace_period";
  if (state === "SUBSCRIPTION_STATE_ON_HOLD") return "grace_period";
  if (state === "SUBSCRIPTION_STATE_CANCELED") return "canceled";
  if (state === "SUBSCRIPTION_STATE_EXPIRED") return "expired";
  return "expired";
}

// =============================================================================
// APP STORE
// =============================================================================

/**
 * Callable `validateAppStoreReceipt`.
 *
 * Para el MVP usamos el endpoint de verifyReceipt legacy. En una iteracion
 * futura se migrara a App Store Server API v1 ( signed transactions ).
 *
 * Nota: apple-signin-auth provee helpers para JWT contra App Store Server API
 * v1; lo dejamos referenciado en package.json para uso futuro.
 */
export const validateAppStoreReceipt = onCall(
  {
    region: defaultRegion,
    memory: "256MiB",
    timeoutSeconds: 60,
    minInstances: 0,
    maxInstances: 10,
  },
  async (
    request: CallableRequest<ValidateAppStoreReceiptRequest>,
  ): Promise<ValidateReceiptResponse> => {
    const uid = requireAuth(request.auth);
    await enforceRateLimit(uid, "validate_appstore_receipt");

    const receiptData = request.data?.receiptData;
    const transactionId = request.data?.transactionId;
    if (!receiptData || typeof receiptData !== "string") {
      throw new HttpsError("invalid-argument", "receiptData es obligatorio.");
    }
    if (!transactionId || typeof transactionId !== "string") {
      throw new HttpsError("invalid-argument", "transactionId es obligatorio.");
    }

    logger.info(`validateAppStoreReceipt uid=${uid} tx=${transactionId}`);

    if (!appStoreIssuerId || !appStoreKeyId || !appStorePrivateKey) {
      throw new HttpsError(
        "failed-precondition",
        "App Store Server API no configurada.",
      );
    }

    try {
      // Validacion contra App Store Server API v1 ( signed transactions ).
      // Construimos JWT ( ES256 ) y llamamos a
      // GET /inApps/v1/transactions/{transactionId}
      const jwtToken = await buildAppStoreJwt();
      const url = `${appStoreBaseUrl}/inApps/v1/transactions/${transactionId}`;

      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const https = require("node:https");
      const response = await fetchAppStore(url, jwtToken);
      const signedInfo = response?.data?.signedTransactionInfo;
      const decoded = signedInfo ? decodeJwtPayload(signedInfo) : null;

      if (!decoded) {
        return { valid: false, reason: "no_data_from_appstore" };
      }

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const tx: any = decoded;
      const status: SubscriptionStatus =
        tx.revocationDate != null
          ? "canceled"
          : new Date(tx.expiresDateMs ?? 0) > new Date()
            ? "active"
            : "expired";
      const expiresAt = tx.expiresDateMs
        ? new Date(parseInt(tx.expiresDateMs, 10))
        : null;

      const plan: SubscriptionPlan = (tx.productId ?? "").includes("annual")
        ? "annual"
        : "monthly";

      const subId = `${uid}_ios`;
      const subDoc = {
        subscription_id: subId,
        user_uid: uid,
        plan,
        platform: "ios",
        store_product_id: tx.productId ?? "",
        started_at: tx.purchaseDateMs
          ? new Date(parseInt(tx.purchaseDateMs, 10))
          : new Date(),
        expires_at: expiresAt ?? new Date(),
        auto_renew: tx.renewalInfo?.autoRenewStatus === 1,
        status,
        last_receipt_id: transactionId,
        canceled_at: tx.revocationDateMs
          ? new Date(parseInt(tx.revocationDateMs, 10))
          : null,
        updated_at: FieldValue.serverTimestamp(),
      };

      await db.collection("subscriptions").doc(subId).set(subDoc, { merge: true });

      // AppStore nunca entra en grace_period pero incluimos el check por
      // consistencia con Play. Usamos Array.includes para evitar el narrowing
      // de TypeScript que considera "grace_period" imposible tras el check
      // de "active".
      const premiumStatuses: SubscriptionStatus[] = ["active", "grace_period"];
      const isPremium = premiumStatuses.includes(status);
      await db
        .collection("users")
        .doc(uid)
        .set(
          {
            is_premium: isPremium,
            premium_expires_at: isPremium ? expiresAt : null,
            updated_at: FieldValue.serverTimestamp() as never,
          },
          { merge: true },
        );

      await writeAuditLog(
        uid,
        "subscription_started",
        subId,
        hashString(request.rawRequest?.ip ?? "unknown"),
        { platform: "ios", transactionId, status, plan, bundleId: appStoreBundleId },
      );

      logger.info(`validateAppStoreReceipt OK uid=${uid} status=${status}`);

      return {
        valid: true,
        subscriptionId: subId,
        plan,
        status,
        expiresAt: expiresAt?.toISOString(),
      };
    } catch (err) {
      logger.error(`Error validateAppStoreReceipt uid=${uid}`, err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError(
        "internal",
        `Error validando receipt de App Store: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  },
);

/**
 * Construye el JWT ES256 para App Store Server API v1.
 */
async function buildAppStoreJwt(): Promise<string> {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const crypto = require("node:crypto");
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: appStoreIssuerId,
    iat: now,
    exp: now + 60 * 20, // 20 min
    aud: "appstoreconnect-v1",
    bid: appStoreBundleId,
  };
  const header = { alg: "ES256", kid: appStoreKeyId, typ: "JWT" };

  const enc = (o: unknown) =>
    Buffer.from(JSON.stringify(o)).toString("base64url");
  const signingInput = `${enc(header)}.${enc(payload)}`;

  const key = crypto.createPrivateKey({
    key: Buffer.from(
      (appStorePrivateKey ?? "").replace(/\\n/g, "\n"),
    ),
    format: "pem",
  });
  const sig = crypto.sign(null, Buffer.from(signingInput), key);
  return `${signingInput}.${sig.toString("base64url")}`;
}

/**
 * Hace un GET a la App Store Server API con el JWT en Authorization.
 */
async function fetchAppStore(
  url: string,
  jwt: string,
): Promise<{ data?: { signedTransactionInfo?: string } }> {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const https = require("node:https");
  return new Promise((resolve, reject) => {
    const req = https.get(
      url,
      {
        headers: {
          Authorization: `Bearer ${jwt}`,
          "User-Agent": "storyenglish-kids-functions/1.0",
        },
      },
      (res: { statusCode?: number; on: (e: string, cb: (c: Buffer) => void) => void }) => {
        let body = "";
        res.on("data", (c: Buffer) => (body += c.toString()));
        res.on("end", () => {
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            reject(e);
          }
        });
      },
    );
    req.on("error", reject);
    req.setTimeout(15000, () => req.destroy(new Error("timeout")));
  });
}

/**
 * Decodifica el payload de un JWT sin verificar firma.
 * ( Para produccion deberiamos validar la firma con la Apple Root CA. )
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function decodeJwtPayload(jwt: string): any {
  const parts = jwt.split(".");
  if (parts.length < 2) return null;
  const payload = Buffer.from(parts[1]!, "base64url").toString("utf8");
  return JSON.parse(payload);
}
