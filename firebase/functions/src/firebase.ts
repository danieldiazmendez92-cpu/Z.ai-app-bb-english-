/**
 * Inicializacion compartida de `firebase-admin`.
 *
 * En Cloud Functions v2, `firebase-admin` debe inicializarse una sola vez por
 * instancia de cold start. Este modulo es un singleton que:
 *  - Inicializa la app con `credential: applicationDefault()` ( runtime de
 *    Firebase inyecta las credenciales automaticamente ).
 *  - Expone `db` ( Firestore ), `storage` ( Cloud Storage ) y `auth`.
 *  - En modo emulador respeta `FIRESTORE_EMULATOR_HOST`.
 */

import { initializeApp, getApps, cert, type App } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { getStorage, type Storage } from "firebase-admin/storage";
import { getAuth, type Auth } from "firebase-admin/auth";
import { logger } from "firebase-functions/v2";

import { projectId, storageBucket } from "./config";

let app: App;

if (getApps().length === 0) {
  // En emulador o runtime de Firebase las credenciales default sirven.
  // Si esta definida FIREBASE_SERVICE_ACCOUNT ( JSON string ) la usamos.
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (serviceAccountJson) {
    try {
      const parsed = JSON.parse(serviceAccountJson);
      app = initializeApp({
        credential: cert(parsed),
        projectId,
        storageBucket,
      });
    } catch (err) {
      logger.error(
        "FIREBASE_SERVICE_ACCOUNT malformado, fallback a applicationDefault",
        err,
      );
      app = initializeApp({ projectId, storageBucket });
    }
  } else {
    app = initializeApp({ projectId, storageBucket });
  }
} else {
  app = getApps()[0]!;
}

export const db: Firestore = getFirestore(app);
export const storage: Storage = getStorage(app);
export const bucket = storage.bucket(storageBucket);
export const auth: Auth = getAuth(app);
export const adminApp: App = app;

export default app;
