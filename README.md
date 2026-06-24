# StoryEnglish Kids

<p align="center">
  <em>App móvil de cuentos narrados en inglés para niños de 2-7 años. Aprenden inglés escuchando y leyendo cuentos clásicos con audio sincronizado y resaltado palabra-a-palabra.</em>
</p>

<p align="center">
  <!-- CI badge (workflow: ci.yml) -->
  <a href="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/ci.yml">
    <img alt="CI" src="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/ci.yml/badge.svg?branch=develop" />
  </a>
  <!-- CD Dev badge -->
  <a href="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/cd_dev.yml">
    <img alt="Deploy Dev" src="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/cd_dev.yml/badge.svg" />
  </a>
  <!-- CD Prod badge -->
  <a href="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/cd_prod.yml">
    <img alt="Deploy Prod" src="https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/actions/workflows/cd_prod.yml/badge.svg" />
  </a>
  <!-- Coverage badge (Codecov) -->
  <a href="https://codecov.io/gh/danieldiazmendez92-cpu/Z.ai-app-bb-english-">
    <img alt="Coverage" src="https://codecov.io/gh/danieldiazmendez92-cpu/Z.ai-app-bb-english-/branch/develop/graph/badge.svg" />
  </a>
  <!-- License -->
  <a href="./LICENSE">
    <img alt="License" src="https://img.shields.io/badge/license-All%20Rights%20Reserved-red" />
  </a>
  <!-- Flutter version -->
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter" />
  <!-- Platform -->
  <img alt="Platform" src="https://img.shields.io/badge/platform-Android%20%7C%20iOS-green" />
</p>

---

## 📖 Sobre el proyecto

**StoryEnglish Kids** es una app móvil (Flutter + Firebase) diseñada para que
niños hispanohablantes de 2 a 7 años aprendan inglés escuchando y leyendo
cuentos clásicos de dominio público. La app:

- 🎧 Narra cada cuento en inglés con voz natural (Google Cloud TTS).
- 🎨 Resalta palabra-a-palabra lo que se va narrando (karaoke-style).
- 🌍 Traduce al español y explica vocabulario nuevo.
- 🧒 Permite hasta 4 perfiles de niño por cuenta familiar.
- 🏆 Premia la lectura con logros e insignias.
- 🔒 Cumple **COPPA**, **GDPR-K** y políticas de privacidad infantil
  (verificación parental, sin publicidad personalizada, límite de tiempo
  diario, borrado de datos tras 30 días de inactividad).

---

## 🛠️ Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| **Mobile app** | Flutter 3.24 (Android + iOS), Dart 3.5 |
| **State management** | Riverpod 2 + riverpod_generator |
| **Routing** | go_router 14 |
| **Backend** | Firebase (Auth, Firestore, Storage, Cloud Functions v2, Analytics, Crashlytics, Remote Config, App Check) |
| **Cloud Functions runtime** | Node.js 20 LTS, TypeScript 5 (strict mode) |
| **AI** | Google Gemini (generación de vocabulario, traducciones, preguntas de comprensión) |
| **TTS** | Google Cloud Text-to-Speech (Neural2, con SSML marks para timestamps por palabra) |
| **Billing** | in_app_purchase (Play Billing + App Store StoreKit) |
| **Audio** | just_audio + audio_service (background audio, sync con timestamps) |
| **Local storage** | Hive (offline cache de cuentos descargados) |
| **Modelos** | freezed + json_serializable |
| **Testing** | flutter_test, mocktail, fake_cloud_firestore, firebase_auth_mocks, vitest, @firebase/rules-unit-testing |
| **CI/CD** | GitHub Actions (4 workflows: ci, cd_dev, cd_prod, labeler) |
| **Code quality** | flutter_lints + dart_code_metrics (strict), Codecov, Dependabot |

---

## 🚀 Quick start

Guía completa en [`docs/SETUP.md`](./docs/SETUP.md). Resumen ejecutivo:

```bash
# 1. Prerrequisitos (ver docs/SETUP.md sección 1):
#    Flutter 3.24+, Node 20+, Firebase CLI, FlutterFire CLI.

# 2. Clone + deps
git clone <repo-url> storyenglish_kids
cd storyenglish_kids
flutter pub get
cd firebase/functions && npm ci && cd ../..
dart run build_runner build --delete-conflicting-outputs

# 3. Configurar Firebase (pedir acceso al tech lead)
firebase login
flutterfire configure --project=storyenglish-kids-dev \
  --out=lib/firebase_options_dev.dart --platforms=android,ios,web

# 4. (Opcional) Levantar Firebase Emulator local
cd firebase && firebase emulators:start --only auth,firestore,functions,storage &

# 5. Correr la app
flutter run --flavor dev -t lib/main_dev.dart
```

> 💡 Si algo falla, mirá el [Troubleshooting](./docs/SETUP.md#9-troubleshooting)
> en `docs/SETUP.md`.

---

## 📂 Estructura del repo

```
storyenglish_kids/
├── .github/
│   ├── workflows/         CI/CD (ci.yml, cd_dev.yml, cd_prod.yml, labeler.yml)
│   ├── ISSUE_TEMPLATE/    bug_report, feature_request, task
│   ├── pull_request_template.md
│   ├── labeler.yml        Auto-label por paths cambiados
│   └── dependabot.yml     Auto-PR de actualización de deps
├── android/               Proyecto Android (Gradle, Manifest, flavors)
├── ios/                   Proyecto iOS (Xcode, Info.plist, flavors)
├── lib/                   Código Dart
│   ├── core/              Config, theme, utils, widgets compartidos
│   ├── features/          Cada feature autocontenida (auth, story, library, ...)
│   ├── shared/            Providers y widgets cross-feature
│   ├── main.dart          Entry point común
│   ├── main_dev.dart      Flavor dev
│   └── main_prod.dart     Flavor prod
├── test/                  Unit + widget tests
├── integration_test/      Integration tests (con Firebase Emulator)
├── firebase/              Backend Firebase
│   ├── functions/         Cloud Functions (TypeScript)
│   ├── firestore.rules    Reglas de seguridad Firestore
│   ├── storage.rules      Reglas de seguridad Storage
│   ├── firestore.indexes.json
│   └── firebase.json      Config Firebase CLI + emuladores
├── scripts/               Scripts utilitarios (seed_stories.ts, ...)
├── assets/                Imágenes, fuentes, lottie, l10n
├── docs/                  Documentación (SETUP, CONTRIBUTING, diseño)
├── pubspec.yaml           Dependencias Dart
├── analysis_options.yaml  Reglas de lint
├── CODE_OF_CONDUCT.md     Contributor Covenant 2.1
├── LICENSE                Placeholder (TBD)
└── README.md              Este archivo
```

Detalle de `lib/` en [`docs/02-folder-structure.md`](./docs/02-folder-structure.md).

---

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| [`docs/SETUP.md`](./docs/SETUP.md) | Guía paso a paso para correr la app localmente |
| [`docs/CONTRIBUTING.md`](./docs/CONTRIBUTING.md) | Cómo contribuir (branching, commits, review, coverage) |
| [`docs/00-index.md`](./docs/00-index.md) | Índice de la documentación de diseño |
| [`docs/01-architecture.md`](./docs/01-architecture.md) | Arquitectura general y stack |
| [`docs/02-folder-structure.md`](./docs/02-folder-structure.md) | Estructura de carpetas en `lib/` |
| [`docs/03-data-models.md`](./docs/03-data-models.md) | Modelos de datos |
| [`docs/04-firestore-schema.md`](./docs/04-firestore-schema.md) | Schema de Firestore (colecciones, índices) |
| [`docs/05-security-and-privacy.md`](./docs/05-security-and-privacy.md) | Seguridad, COPPA, GDPR-K |
| [`docs/06-roadmap.md`](./docs/06-roadmap.md) | Roadmap (Fase 0 → Fase 4) |
| [`docs/07-costs.md`](./docs/07-costs.md) | Estimación de costos Firebase |
| [`docs/08-monetization.md`](./docs/08-monetization.md) | Modelo de monetización (freemium + suscripción) |
| [`docs/09-testing.md`](./docs/09-testing.md) | Estrategia de testing |
| [`docs/10-accessibility.md`](./docs/10-accessibility.md) | Accesibilidad (WCAG AA, dislexia, color blindness) |
| [`docs/11-risks.md`](./docs/11-risks.md) | Riesgos y mitigaciones |
| [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) | Código de conducta (Contributor Covenant 2.1) |
| [`LICENSE`](./LICENSE) | Licencia (placeholder — TBD) |

> **Nota:** Los docs de arquitectura (`00-index.md` a `11-risks.md`) viven
> temporalmente en `/scripts/storyenglish-docs/docs/`. Antes del primer
> release público, se copiarán a `storyenglish_kids/docs/` para que el repo
> sea self-contained.

---

## 🤝 Contribuir

¡Contribuciones bienvenidas! Antes de tu primer PR:

1. Leé [`docs/CONTRIBUTING.md`](./docs/CONTRIBUTING.md) — branching model,
   Conventional Commits, code review checklist, reglas de linting, cobertura
   mínima.
2. Leé [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md).
3. Elegí un issue del [board de GitHub](https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/projects)
   (empezá por `phase-0` o `phase-1` si sos nueve).
4. Abrí una branch `feature/<T-ID>-<nombre>` desde `develop` y a codear.

### Cobertura mínima

- **Total:** 70% (CI falla si baja)
- **Domain layer:** 85%
- **Firestore rules:** 90%
- **Cloud Functions:** 70%

CI corre automáticamente en cada PR: `flutter analyze` + dart_code_metrics,
`flutter test --coverage`, vitest para Cloud Functions, integration tests con
Firebase Emulator. Ver [`.github/workflows/ci.yml`](./.github/workflows/ci.yml).

---

## 🔁 CI/CD

| Workflow | Trigger | Qué hace |
|----------|---------|----------|
| [`ci.yml`](./.github/workflows/ci.yml) | PR a `main`/`develop`, push a `develop` | Analyze + unit tests (coverage) + Firestore rules tests + integration tests (macOS) |
| [`cd_dev.yml`](./.github/workflows/cd_dev.yml) | Push a `develop` | Deploy Cloud Functions + Firestore/Storage rules a Firebase dev |
| [`cd_prod.yml`](./.github/workflows/cd_prod.yml) | Tag `v*` en `main` | Deploy a Firebase prod (con approval manual) |
| [`labeler.yml`](./.github/workflows/labeler.yml) | Abierto/editado PR | Auto-etiqueta según paths cambiados + size label |

Secrets requeridos (Settings → Secrets and variables → Actions):
- `FIREBASE_TOKEN_DEV` — Firebase CLI token para deploy dev
- `FIREBASE_TOKEN_PROD` — Firebase CLI token para deploy prod
- `CODECOV_TOKEN` — para subir coverage a codecov.io

---

## 📦 Roadmap

Ver [`docs/06-roadmap.md`](./docs/06-roadmap.md) para el detalle completo.
Resumen de fases:

| Fase | Nombre | Duración | Estado |
|------|--------|----------|--------|
| 0 | Setup | 2 semanas | 🟡 En progreso |
| 1 | MVP | 10 semanas | ⬜ Pendiente |
| 2 | Engagement | 8 semanas | ⬜ Pendiente |
| 3 | Monetización | 6 semanas | ⬜ Pendiente |
| 4 | Escala | 8 semanas | ⬜ Pendiente |

---

## 📄 Licencia

Por ahora el código es **propiedad de StoryEnglish Kids** (All Rights Reserved).
La licencia final (open-source o comercial) se definirá antes del primer
release público. Ver [`LICENSE`](./LICENSE).

---

## 💬 Contacto

- **Issues técnicos:** [GitHub Issues](https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/issues)
- **Slack:** canal `#storyenglish-dev` (interno)
- **Email:** `maintainers@storyenglish.app`
- **Code of Conduct reports:** `conduct@storyenglish.app`

---

<sub>
  Scaffold inicial creado por el Agente B (P0-B). Cloud Functions por el
  Agente C (P0-C). CI/CD + docs por el Agente D (P0-D). Issues, labels y
  milestones por el Agente A (P0-A).
</sub>
