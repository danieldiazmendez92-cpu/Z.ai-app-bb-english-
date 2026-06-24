# 🚀 Setup Final — Cómo configurar Firebase y probar StoryEnglish Kids

Esta guía te lleva paso a paso desde cero hasta tener la app funcionando en tu celular o emulador.

---

## ⏱️ Tiempo estimado: 30-60 minutos

| Paso | Tiempo | Dificultad |
|------|--------|------------|
| 1. Prerrequisitos | 10 min | Fácil |
| 2. Crear proyecto Firebase | 5 min | Fácil |
| 3. Configurar Firebase en la app | 10 min | Media |
| 4. Deployar Cloud Functions | 10 min | Media |
| 5. Cargar cuentos | 5 min | Fácil |
| 6. Correr la app | 5 min | Fácil |
| 7. Probar el flujo | 10 min | Fácil |

---

## 1️⃣ Prerrequisitos

### En tu computadora:

```bash
# 1. Flutter SDK (3.24+)
# Instalar desde: https://docs.flutter.dev/get-started/install
flutter --version  # debería mostrar 3.24+

# 2. Node.js 20+ (para Cloud Functions)
node --version  # debería mostrar v20+

# 3. Firebase CLI
npm install -g firebase-tools
firebase --version

# 4. FlutterFire CLI
dart pub global activate flutterfire_cli

# 5. Clonar el repo
git clone https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-.git
cd Z.ai-app-bb-english-

# 6. Login a Firebase
firebase login
```

### Cuentas necesarias:
- Cuenta de Google (para Firebase)
- Cuenta de Apple Developer (si vas a probar en iOS, $99/año)
- Cuenta de Google Play Console (si vas a probar en Android, $25 one-time)

---

## 2️⃣ Crear proyecto Firebase

1. Andá a https://console.firebase.google.com
2. Click **"Agregar proyecto"**
3. Nombre: `storyenglish-kids-dev` (o el que prefieras)
4. **NO** habilites Google Analytics por ahora (lo activamos después)
5. Click **"Crear proyecto"**

### Habilitar servicios:

En el menú izquierdo del Firebase Console:

#### a) Authentication
- Click **"Authentication" → Comenzar**
- **Sign-in method**:
  - Email/contraseña: **Habilitar**
  - Google: **Habilitar** (proyecto de soporte: tu email)
  - Apple: **Habilitar** (requiere configuración adicional, ver docs)

#### b) Cloud Firestore
- Click **"Firestore Database" → Crear base de datos**
- Modo: **producción** (las reglas ya están en el repo)
- Región: la más cercana a tus usuarios (ej: `us-central1` para Latam)

#### c) Cloud Storage
- Click **"Storage" → Comenzar**
- Región: la misma que Firestore

#### d) Cloud Functions
- Click **"Functions" → Comenzar**
- Te va a pedir upgrade a plan **Blaze** (pay-as-you-go). Necesario.
- No te preocupes: con uso normal gastás < $5/mes (ver `docs/07-costs.md`)

#### e) App Check (opcional pero recomendado)
- Click **"App Check" → Apps → Registrar**
- Android: Play Integrity
- iOS: App Attest

---

## 3️⃣ Configurar Firebase en la app

```bash
# En la raíz del repo clonado:
flutterfire configure \
  --project=storyenglish-kids-dev \
  --platforms=android,ios,web \
  --ios-bundle-id=com.storyenglish.kids \
  --android-package-name=com.storyenglish.kids
```

Esto genera `lib/firebase_options.dart` automáticamente.

### Variables de entorno

Copia el ejemplo y completa tus API keys:

```bash
cp firebase/.env.example firebase/.env
```

Edita `firebase/.env` con:
```env
# Obligatorias para Cloud Functions
GEMINI_API_KEY=tu_gemini_api_key_aqui
GOOGLE_TTS_KEY=tu_google_tts_key_aqui

# Para billing (Fase 3)
PLAY_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
APP_STORE_ISSUER_ID=tu_app_store_issuer_id
APP_STORE_KEY_ID=tu_key_id
APP_STORE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"

# Para webhooks de billing (Fase 3)
PLAY_WEBHOOK_SECRET=tu_play_webhook_secret
APP_STORE_WEBHOOK_SECRET=tu_app_store_webhook_secret
```

#### Obtener Gemini API key:
- Andá a https://aistudio.google.com/apikey
- Crear API key
- Copiar

#### Obtener Google TTS key:
- Andá a https://console.cloud.google.com
- Habilitar "Text-to-Speech API"
- Crear credenciales (API key)

### Instalar dependencias y generar código

```bash
# En la raíz del repo:
flutter pub get

# Generar archivos freezed + json_serializable
dart run build_runner build --delete-conflicting-outputs
```

> ⚠️ Si tenés errores en este paso, asegurate de tener Flutter 3.24+ y haber corrido `flutter pub get` primero.

---

## 4️⃣ Deployar Cloud Functions + reglas

```bash
cd firebase

# Instalar dependencias de las functions
cd functions
npm install
npm run build  # compila TypeScript
cd ..

# Deployar TODO (functions + reglas + índices)
firebase deploy --only functions,firestore:rules,firestore:indexes,storage:rules
```

### Verificar deploy

```bash
firebase functions:list
# Deberías ver:
# - storyIngest
# - verifyParental
# - validatePlayReceipt
# - validateAppStoreReceipt
# - exportUserData
# - onUserCreate
# - onChildCreate
# - onStoryCompleted
# - playWebhook
# - appStoreWebhook
# - coppaCleanup
```

> El primer deploy tarda ~5 minutos. Los siguientes son más rápidos.

---

## 5️⃣ Cargar cuentos al catálogo

El repo trae 5 cuentos de Project Gutenberg listos para cargar.

```bash
# En la raíz del repo
npx tsx scripts/seed_stories.ts --project=storyenglish-kids-dev --limit=5 --verbose
```

Esto va a:
1. Llamar a Gemini para generar vocabulario + traducción + preguntas
2. Llamar a Google TTS para generar audio MP3 en inglés
3. Subir audio + timestamps JSON a Cloud Storage
4. Crear documentos en Firestore (`stories`, `story_sections`, `vocabulary`, `comprehension_questions`)
5. Marcar cada cuento como `published: true`

> Costo aproximado: ~$0.05 (Gemini + TTS) para 5 cuentos.

### Verificar cuentos cargados

```bash
firebase firestore:collection stories --project storyenglish-kids-dev
```

Deberías ver 5 documentos con `published: true`.

---

## 6️⃣ Correr la app

### En emulador Android

```bash
# Asegurate de tener un emulador corriendo
flutter emulators --launch <emulator-id>

# Correr la app
flutter run --flavor dev -t lib/main_dev.dart
```

### En simulador iOS (requiere Mac)

```bash
open -a Simulator
flutter run --flavor dev -t lib/main_dev.dart
```

### En celular físico

```bash
# Android (con USB debugging habilitado)
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>

# iOS (con cable, Xcode configurado)
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>
```

---

## 7️⃣ Probar el flujo completo

### Flujo de padre:

1. **Abrir app** → pantalla de login
2. **Crear cuenta** con email + password
   -Aceptar términos
3. **Verificación parental** → responder 3 preguntas matemáticas
4. **Onboarding**:
   - Elegir avatar (10 emojis animales)
   - Elegir edad (2-7)
   - Elegir intereses (Animales, Aventuras, etc.)
5. **Home screen** → ver recomendados para tu hijo

### Flujo de niño:

6. **Home** → tap en un cuento recomendado
7. **Story Detail** → ver info + vocabulario + botón "Empezar a leer"
8. **Reader**:
   - Tap "Play" para escuchar audio
   - Ver palabra actual resaltada en tiempo real
   - Tap en palabra destacada → popup con traducción
   - Toggle "Ver traducción" para ver texto en español
   - Ajustar velocidad (0.75x, 1x, 1.25x, 1.5x)
9. **Story End**:
   - Animación de celebración
   - Responder pregunta de comprensión
   - Ver logro desbloqueado (con confetti!)

### Verificar datos:

10. **Ir a Progreso** → ver stats: cuentos leídos, minutos, racha, palabras
11. **Ir a Padres** (PIN: `1234`):
    - Ver dashboard con resumen semanal
    - Configurar límite diario, bedtime, categorías bloqueadas
    - Ver estadísticas detalladas

### Probar suscripción (sandbox):

12. **Ir a Padres → Suscripción** → ver plan actual (Free)
13. **Tap "Ver planes"** → ver paywall con beneficios
14. (Opcional) Comprar en sandbox de Google Play / App Store

### Probar compliance:

15. **Ir a Padres → Privacidad** (desde settings):
    - Toggle analytics
    - **Exportar datos** → ver JSON con toda tu info
    - **Eliminar cuenta** → doble confirmación

---

## 🐛 Troubleshooting

### "Flutter SDK no encontrado"
Instalá desde https://docs.flutter.dev/get-started/install y reiniciá la terminal.

### "firebase: command not found"
```bash
npm install -g firebase-tools
```

### Error en `flutterfire configure`
- Verificá haber hecho `firebase login`
- Probá con `--debug` para más info

### "Permission denied" en Firestore
- Verificá que las reglas se deployaron: `firebase deploy --only firestore:rules`
- En Firestore Console → Reglas, deberías ver el contenido de `firebase/firestore.rules`

### Cloud Functions fallan
- Verificá variables de entorno: `firebase functions:config:get`
- Logs: `firebase functions:log`
- Verificá que `GEMINI_API_KEY` y `GOOGLE_TTS_KEY` están seteadas

### App no carga cuentos
- Verificá que el script `seed_stories.ts` corrió bien
- En Firestore Console, colección `stories`, deberías ver 5 docs con `published: true`

### Audio no reproduce
- Verificá que `story.audioUrlEn` tiene una URL de Storage válida
- Verificá reglas de Storage: `firebase deploy --only storage:rules`
- Probá abrir la URL en navegador

### Login con Google falla en Android
- Verificá que `google-services.json` está en `android/app/`
- Verificá el SHA-1 en Firebase Console → Project Settings → Android app

### Login con Apple falla
- Requiere Apple Developer Program ($99/año)
- Ver configuración en https://firebase.google.com/docs/auth/ios/apple

---

## 📞 Soporte

Si tenés problemas:
1. Revisá los logs: `flutter logs` y `firebase functions:log`
2. Buscá en los docs: `docs/SETUP.md`, `docs/CONTRIBUTING.md`
3. Abrí un issue: https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/issues

---

## ✅ Checklist final

Antes de decir "está listo":

- [ ] Flutter instalado y `flutter doctor` verde
- [ ] Proyecto Firebase creado con Auth, Firestore, Storage, Functions
- [ ] `flutterfire configure` corrió OK
- [ ] `.env` con Gemini y TTS keys completado
- [ ] `flutter pub get` sin errores
- [ ] `dart run build_runner build` generó archivos `.freezed.dart` y `.g.dart`
- [ ] `firebase deploy` completado sin errores
- [ ] Script `seed_stories.ts` cargó 5 cuentos
- [ ] App corre en emulador o dispositivo
- [ ] Login con email funciona
- [ ] Verificación parental funciona
- [ ] Onboarding completa y crea perfil de niño
- [ ] Home muestra cuentos recomendados
- [ │ Reader reproduce audio y resalta palabras
- [ ] Story End muestra celebración + pregunta
- [ ] Progress muestra stats y badges
- [ ] Panel padres accesible con PIN 1234

¡Listo! 🎉 La app está corriendo.

---

## 🚀 Próximos pasos (Fase 4 - Escala)

Cuando la app esté funcionando en dev y quieras prepararla para producción:

1. **Crear 2do proyecto Firebase**: `storyenglish-kids-prod`
2. **Configurar flavors**: `flutterfire configure` con `--out=lib/firebase_options_prod.dart`
3. **Apple App Store**: crear app, configurar In-App Purchases, sign in with Apple
4. **Google Play Console**: crear app, configurar suscripciones, subir AAB
5. **Cargar más cuentos**: ampliar catálogo a 50+
6. **Beta privada**: 20 familias, 1 semana
7. **Submit a stores** con políticas de privacidad + términos

Ver `docs/06-roadmap.md` para el detalle.
