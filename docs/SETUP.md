# Setup guide — StoryEnglish Kids

> Guía paso a paso para que una persona nueva en el equipo pueda correr la app
> localmente en menos de 30 minutos. Si algo te falla y no está en
> [Troubleshooting](#9-troubleshooting), abrí un issue con label `infra` y
> describe el comando y el error.

---

## 1. Prerrequisitos

Antes de clonar el repo, instalá lo siguiente en tu máquina (macOS, Linux o
Windows + WSL2). Las versiones son las **mínimas soportadas**; si tenés más
nuevas, mejor.

| Herramienta | Versión mínima | Para qué se usa | Cómo verificar |
|-------------|-----------------|-----------------|----------------|
| **Flutter SDK** | 3.24.0 (stable) | Compilar y correr la app | `flutter --version` |
| **Dart SDK** | 3.5.0 (incluido con Flutter) | Lenguaje de la app | `dart --version` |
| **Node.js** | 20.x LTS | Cloud Functions + Firebase CLI | `node --version` |
| **npm** | 10.x (incluido con Node) | Gestión de dependencias JS | `npm --version` |
| **Firebase CLI** | 13.x | Deploy + Emulator | `firebase --version` |
| **FlutterFire CLI** | 1.x | Generar `firebase_options.dart` | `dart pub global run flutterfire --version` |
| **Xcode** | 16.x (solo macOS) | Build iOS | `xcodebuild -version` |
| **Android Studio** | Hedgehog (2023.1) o superior | SDK Android + emulador | `adb --version` |
| **Java JDK** | 17 (incluido con Android Studio) | Builds Android | `java -version` |
| **Git** | 2.40+ | Versionado | `git --version` |

### 1.1 Instalación rápida

**Flutter:**

```bash
# Opción recomendada: usar FVM (Flutter Version Manager)
dart pub global activate fvm
fvm install 3.24.0
fvm use 3.24.0

# O sin FVM:
# macOS (Homebrew):
brew install --cask flutter
# Linux: descargar tarball de https://docs.flutter.dev/get-started/install
```

**Node + Firebase CLI:**

```bash
# Node (recomendado con nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20
nvm use 20

# Firebase CLI + FlutterFire CLI
npm install -g firebase-tools@13
dart pub global activate flutterfire_cli
```

**Verificación global:**

```bash
flutter doctor -v
firebase --version   # >= 13
node --version       # v20.x
```

`flutter doctor` te va a marcar qué falta para Android y/o iOS. Resolvé los
issues que marque antes de continuar.

---

## 2. Setup inicial del proyecto

### 2.1 Clone y dependencias

```bash
git clone <repo-url> storyenglish_kids
cd storyenglish_kids

# Dependencias Dart
flutter pub get

# Generar código de freezed/json_serializable/riverpod_generator
dart run build_runner build --delete-conflicting-outputs

# Dependencias de Cloud Functions
cd firebase/functions
npm ci
cd ../..
```

### 2.2 Acceso a Firebase (solo la primera vez)

Pedile al tech lead que te agregue como miembro del proyecto Firebase dev:
`storyenglish-kids-dev` (proyecto de Firebase, no de Google Cloud Console).

Una vez agregado, logueate:

```bash
firebase login
# Abrirá el navegador. Autenticá con el mail con el que te invitaron.
firebase projects:list   # deberías ver storyenglish-kids-dev
```

### 2.3 Configurar FlutterFire (genera `firebase_options.dart`)

El proyecto usa dos **flavors**: `dev` y `prod`. Cada uno apunta a un
proyecto Firebase distinto. La configuración vive en
`lib/firebase_options_*.dart` (ignorado por git).

```bash
# DEV
flutterfire configure \
  --project=storyenglish-kids-dev \
  --out=lib/firebase_options_dev.dart \
  --platforms=android,ios,web \
  --android-package-id=com.storyenglish.kids.dev \
  --ios-bundle-id=com.storyenglish.kids.dev

# PROD (solo si tenés acceso al proyecto prod)
flutterfire configure \
  --project=storyenglish-kids-prod \
  --out=lib/firebase_options_prod.dart \
  --platforms=android,ios \
  --android-package-id=com.storyenglish.kids \
  --ios-bundle-id=com.storyenglish.kids
```

Esto genera los archivos `google-services.json` (Android) y
`GoogleService-Info.plist` (iOS) que **NO se commitean** (están en `.gitignore`).

### 2.4 Variables de entorno

Copiá los `.env.example` a `.env` y completá los valores (pedíselos al tech lead):

```bash
cp .env.example .env
cp firebase/.env.example firebase/functions/.env
```

Editá ambos archivos con los valores reales de API keys, IDs, etc.

---

## 3. Correr la app localmente

### 3.1 En dispositivo/emulador

```bash
# Listar dispositivos disponibles
flutter devices

# Correr con flavor dev (recomendado para desarrollo)
flutter run --flavor dev -t lib/main_dev.dart

# Correr con flavor prod (solo si sabés lo que hacés)
flutter run --flavor prod -t lib/main_prod.dart
```

> **Nota sobre flavors:** los flavors están configurados en
> `android/app/build.gradle` (productFlavors) y `ios/Runner/Configs/`. Si ves
> un error "Flavor dev not found", asegurate de haber corrido
> `flutter pub get` y de abrir el proyecto iOS en Xcode al menos una vez.

### 3.2 Hot reload / hot restart

Mientras la app corre, en la terminal donde está `flutter run`:

- `r` — Hot reload (recarga cambios en widgets, mantiene estado)
- `R` — Hot restart (reinicia la app, pierde estado)
- `q` — Quit

### 3.3 Generar código (cuando修改ás modelos)

Cualquier archivo `.freezed.dart` o `.g.dart` se regenera con:

```bash
# Una vez
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recarga automáticamente al guardar)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 4. Firebase Emulator (backend local)

Para desarrollo y para integration tests, usamos el Firebase Emulator Suite en
vez de pegarle al proyecto dev de Firebase (más rápido, gratis, sin
side-effects).

### 4.1 Arrancar el emulador

```bash
cd firebase

# Primera vez: instalar configuración
firebase init emulators   # ya está preconfigurado en firebase.json, solo confirmar

# Levantar emulador
firebase emulators:start --only auth,firestore,functions,storage,pubsub,scheduler
```

El emulador queda corriendo en:
- **UI:** http://localhost:4000
- **Auth:** http://localhost:9099
- **Firestore:** http://localhost:8080
- **Functions:** http://localhost:5001
- **Storage:** http://localhost:9199

### 4.2 Conectar la app al emulador

En `lib/main_dev.dart`, el `FirebaseConfig` detecta automáticamente si existe
la var de entorno `USE_FIREBASE_EMULATOR=true` y redirige las llamadas al
localhost correspondiente. Podés correr así:

```bash
# Linux/macOS
USE_FIREBASE_EMULATOR=true flutter run --flavor dev -t lib/main_dev.dart

# Windows PowerShell
$env:USE_FIREBASE_EMULATOR="true"; flutter run --flavor dev -t lib/main_dev.dart
```

### 4.3 Cargar datos de prueba al emulador

```bash
# Cargar cuentos de dominio público (Project Gutenberg)
cd firebase
firebase functions:shell
# adentro:
> storyIngest({title:"Little Red Riding Hood", textEn:"...", sourceUrl:"..."})
```

O usar el script utilitario `scripts/seed_stories.ts` (ver sección 6).

### 4.4 Detener el emulador

`Ctrl+C` en la terminal donde está corriendo. Los datos del emulador **se
pierden** al cerrarlo, salvo que exportes:

```bash
firebase emulators:export ./emulator-data
# Para restaurar:
firebase emulators:start --import ./emulator-data
```

---

## 5. Tests

Ver [`docs/09-testing.md`](./09-testing.md) para la estrategia completa. Resumen
ejecutivo:

### 5.1 Unit & widget tests (rápidos)

```bash
# Todos los tests
flutter test

# Con coverage
flutter test --coverage

# Un solo archivo
flutter test test/features/auth/presentation/controllers/auth_controller_test.dart

# Tag específica
flutter test --tags smoke

# Excluir tag
flutter test --exclude-tags slow
```

Reporte de coverage se genera en `coverage/lcov.info`. Visualizalo con:

```bash
# Install genhtml (parte de lcov)
brew install lcov   # macOS
# sudo apt install lcov   # Linux

genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 5.2 Firestore rules tests (Node + vitest)

```bash
cd firebase/functions
npm test                 # todos los tests
npm test -- --watch      # watch mode
npx vitest run firestore.rules   # solo rules
```

### 5.3 Integration tests (con Firebase Emulator)

Los integration tests viven en `integration_test/` y requieren el emulador
corriendo:

```bash
# 1. En una terminal, levantar el emulador
cd firebase
firebase emulators:start --only auth,firestore,functions,storage

# 2. En otra terminal, correr los integration tests
flutter test integration_test
```

Para correr en dispositivo físico o emulador (no headless):

```bash
flutter test integration_test -d <device-id>
```

### 5.4 Cobertura mínima

- **Total:** 70% (CI falla si baja)
- **Domain layer:** 85%
- **Data layer:** 70%
- **Presentation controllers:** 75%
- **Firestore rules:** 90%
- **Cloud Functions:** 70%

---

## 6. Scripts utilitarios

### 6.1 `scripts/seed_stories.ts`

Carga cuentos de dominio público (Project Gutenberg) en el catálogo llamando a
la Cloud Function `storyIngest`.

```bash
# Requiere Node 20 y haber hecho npm install en firebase/functions
cd firebase/functions
npx tsx ../../scripts/seed_stories.ts --project=dev --limit=5
```

Ver la documentación al inicio del archivo para todos los flags.

### 6.2 Regenerar audio (cuando cambian voces TTS)

Si en algún momento cambiamos la voz de TTS (ej: pasamos de `en-US-Neural2-F`
a `en-US-Studio-Q`), hay que regenerar el audio de todos los cuentos. Script
planeado (no implementado aún): `scripts/backfill_audio.ts`. Tracking en
[T4.2.3].

---

## 7. Deploy

### 7.1 Deploy automático (recomendado)

El deploy está automatizado vía GitHub Actions:

| Ambiente | Trigger | Workflow | Secret requerido |
|----------|---------|----------|------------------|
| **DEV**  | Push a `develop` | `.github/workflows/cd_dev.yml` | `FIREBASE_TOKEN_DEV` |
| **PROD** | Push de tag `v*` a `main` | `.github/workflows/cd_prod.yml` | `FIREBASE_TOKEN_PROD` + approval manual |

No deployes manualmente a menos que sea emergencia. Siempre mergeá a `develop`
o creá un release tag.

### 7.2 Deploy manual (emergencias)

Solo si CI está roto o necesitás deployar un hotfix urgente:

```bash
cd firebase
firebase use storyenglish-kids-dev   # o -prod
firebase deploy --only functions,firestore:rules,firestore:indexes,storage
```

> Si deployás manualmente, dejá un mensaje en el canal `#deploys` de Slack
> indicando qué, cuándo y por qué.

### 7.3 Rollback

```bash
# Listar versiones deployadas
firebase functions:list --project=storyenglish-kids-prod

# Rollback a la versión anterior
firebase functions:rollback --project=storyenglish-kids-prod
```

Para reglas de Firestore/Storage, el rollback es restaurar el commit anterior
en git y redeployar.

---

## 8. Estructura del repo

```
storyenglish_kids/
├── .github/             Workflows CI/CD, templates de PR/issue, dependabot
├── android/             Proyecto Android (Gradle, Manifest)
├── ios/                 Proyecto iOS (Xcode, Info.plist)
├── lib/                 Código Dart (app Flutter)
│   ├── core/            Config, theme, utils, widgets compartidos
│   ├── features/        Cada feature autocontenida (auth, story, ...)
│   ├── shared/          Providers y widgets cross-feature
│   ├── main_dev.dart    Entry point flavor dev
│   └── main_prod.dart   Entry point flavor prod
├── test/                Unit + widget tests
├── integration_test/    Integration tests (con emulador)
├── firebase/            Backend Firebase
│   ├── functions/       Cloud Functions (TypeScript)
│   ├── firestore.rules  Reglas de seguridad Firestore
│   ├── storage.rules    Reglas de seguridad Storage
│   └── firebase.json    Config de Firebase CLI
├── scripts/             Scripts utilitarios (seed, backfill, ...)
├── docs/                Documentación del proyecto (este archivo vive acá)
├── assets/              Imágenes, fuentes, lottie, l10n
├── pubspec.yaml         Dependencias Dart
└── analysis_options.yaml Reglas de lint
```

Detalle completo de `lib/` en [`docs/02-folder-structure.md`](./02-folder-structure.md).

---

## 9. Troubleshooting

### 9.1 `flutter pub get` falla con "version solving failed"

Causa común: una dependencia se actualizó y rompe compatibilidad. Solución:

```bash
flutter pub upgrade --major-versions
flutter pub get
```

Si persiste, mirá `pubspec.lock` y compará con la rama `develop`. Probablemente
alguien subió un `pubspec.yaml` sin actualizar el lock.

### 9.2 `dart run build_runner` falla con "conflicting outputs"

```bash
dart run build_runner build --delete-conflicting-outputs
```

El flag `--delete-conflicting-outputs` borra los `.g.dart`/`.freezed.dart`
anteriores. Si el error persiste, borrá a mano:

```bash
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete
dart run build_runner build --delete-conflicting-outputs
```

### 9.3 `flutter run` falla con "No connected devices"

- Asegurate de tener un emulador corriendo o un dispositivo físico conectado.
- `flutter devices` debe listar al menos un dispositivo.
- En Android: habilitá "Depuración USB" en Opciones de desarrollador.
- En iOS: abrí el simulador con `open -a Simulator`.

### 9.4 "MissingPluginException" al usar Firebase

Pasaste Firebase de una versión a otra y falta el plugin nativo. En Android:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

En iOS:

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### 9.5 Firebase Emulator no arranca (puerto en uso)

```bash
# Ver qué proceso usa el puerto
lsof -i :8080   # o el puerto que reporte el error

# Matar el proceso
kill -9 <PID>

# O cambiar el puerto en firebase.json
```

### 9.6 "Cloud Functions deploy fails: functions folder not found"

Asegurate de haber compilado las Cloud Functions antes del deploy:

```bash
cd firebase/functions
npm run build
cd ..
firebase deploy --only functions
```

### 9.7 `firebase login` falla con "cannot open browser"

En un entorno headless (SSH, CI, WSL sin GUI):

```bash
firebase login --no-localhost
```

Te dará una URL para abrir en tu navegador local. Después pegás el token
devuelto en la terminal.

### 9.8 Integration tests flakean en CI

Los integration tests dependen del Firebase Emulator. Si flakean:
- Aumentá el `sleep` inicial en `.github/workflows/ci.yml` (job `integration-tests`).
- Verificá que `firebase emulators:start` esté realmente listo antes de correr
  los tests (el job ya hace polling a `/emulators`, pero a veces 60s no alcanza
  en macOS runners fríos).

### 9.9 Coverage report dice 0% pero los tests pasan

Asegurate de correr `flutter test --coverage` (no `flutter test` solo). El
archivo `coverage/lcov.info` debe existir. Si existe pero dice 0%, los tests
están en una carpeta que `flutter test` no scanea por defecto (debe ser
`test/`).

### 9.10 Dart Code Metrics falla en CI pero no localmente

Tenés una versión distinta de `dart_code_metrics`. Fijate en `pubspec.yaml`
cuál está pinned y hace `flutter pub get` de nuevo. En CI se usa la versión
exacta del lockfile.

---

## 10. Próximos pasos

Una vez que tengas la app corriendo:

1. Leé [`docs/01-architecture.md`](./01-architecture.md) para entender el stack.
2. Leé [`docs/02-folder-structure.md`](./02-folder-structure.md) para saber
   dónde vive cada cosa.
3. Leé [`CONTRIBUTING.md`](./CONTRIBUTING.md) antes de tu primer PR.
4. Elegí un issue de Fase 0 o Fase 1 en el board de GitHub (label `phase-0` o
   `phase-1`) y asignátelo.
5. Creá una branch `feature/<nombre-del-issue>` desde `develop` y a codear.

Bienvenide al equipo! 🚀
