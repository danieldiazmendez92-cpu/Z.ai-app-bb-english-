# 02 — Estructura de carpetas del proyecto Flutter

> Cómo se organiza el código dentro de la app Flutter. Adoptamos **feature-first architecture** con capas internas por feature.

---

## 1. Filosofía de organización

**Feature-first**: cada feature (auth, story, library, parent, etc.) es una carpeta autocontenida con sus propias pantallas, widgets, controllers, repositorios y modelos. Esto permite que un desarrollador trabaje en una feature sin tocar el resto.

Dentro de cada feature, se siguen las capas de arquitectura limpia (presentación → dominio → datos), pero simplificadas para no sobre-ingeniar.

---

## 2. Árbol de carpetas

```
storyenglish_kids/
├── android/                          # Config Android (Gradle, AndroidManifest, etc.)
├── ios/                              # Config iOS (Xcode project, Info.plist, etc.)
├── lib/                              # Código Dart de la app
│   ├── main.dart                     # Entry point
│   ├── main_dev.dart                 # Variant: dev (Firebase dev project)
│   ├── main_prod.dart                # Variant: prod (Firebase prod project)
│   │
│   ├── core/                         # Cosas compartidas por toda la app
│   │   ├── config/
│   │   │   ├── app_config.dart       # Env vars, flavors, URLs de APIs
│   │   │   ├── firebase_config.dart  # Inicialización Firebase por flavor
│   │   │   └── theme.dart            # Tema (colores, tipografías, formas)
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Strings hardcodeados, durations, etc.
│   │   │   ├── asset_paths.dart      # Rutas a assets
│   │   │   └── collection_names.dart # Nombres de colecciones Firestore
│   │   ├── errors/
│   │   │   ├── failures.dart         # Clases de error de dominio
│   │   │   └── exceptions.dart       # Excepciones de capa datos
│   │   ├── extensions/               # Extensiones Dart (string, datetime, etc.)
│   │   ├── network/
│   │   │   └── connectivity_service.dart  # Chequea online/offline
│   │   ├── router/
│   │   │   ├── app_router.dart       # GoRouter config principal
│   │   │   └── routes.dart           # Constantes de rutas
│   │   ├── services/                 # Servicios singleton (audio, analytics, etc.)
│   │   │   ├── audio_player_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   ├── crashlytics_service.dart
│   │   │   └── remote_config_service.dart
│   │   ├── utils/
│   │   │   ├── logger.dart
│   │   │   ├── validators.dart       # Email, password, etc.
│   │   │   └── debounce.dart
│   │   └── widgets/                  # Widgets UI compartidos
│   │       ├── se_button.dart        # "SE" = StoryEnglish
│   │       ├── se_text_field.dart
│   │       ├── se_loading_indicator.dart
│   │       ├── se_error_widget.dart
│   │       └── se_empty_state.dart
│   │
│   ├── features/                     # Cada feature autocontenida
│   │   ├── auth/                     # Login, signup, parental verification
│   │   │   ├── data/
│   │   │   │   ├── auth_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       └── firebase_auth_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── app_user.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart  # abstract
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   ├── auth_controller.dart
│   │   │       │   └── parental_verification_controller.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── signup_screen.dart
│   │   │       │   └── parental_verification_screen.dart
│   │   │       └── widgets/
│   │   │           └── social_login_buttons.dart
│   │   │
│   │   ├── onboarding/               # Primer setup: avatar, edad, intereses
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── home/                     # Pantalla home con recomendados
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── home_controller.dart
│   │   │       └── screens/
│   │   │           └── home_screen.dart
│   │   │
│   │   ├── library/                  # Catálogo navegable
│   │   │   ├── data/
│   │   │   │   └── library_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── library_repository.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── library_controller.dart
│   │   │       ├── screens/
│   │   │       │   └── library_screen.dart
│   │   │       └── widgets/
│   │   │           ├── story_card.dart
│   │   │           ├── category_chip.dart
│   │   │           └── age_filter.dart
│   │   │
│   │   ├── story/                    # Detalle + reader + vocab + end screen
│   │   │   ├── data/
│   │   │   │   ├── story_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── story_firestore_datasource.dart
│   │   │   │       └── story_storage_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── story.dart
│   │   │   │   │   ├── story_section.dart
│   │   │   │   │   ├── vocabulary_word.dart
│   │   │   │   │   └── audio_timestamps.dart
│   │   │   │   └── repositories/
│   │   │   │       └── story_repository.dart
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   ├── story_detail_controller.dart
│   │   │       │   └── reader_controller.dart
│   │   │       ├── screens/
│   │   │       │   ├── story_detail_screen.dart
│   │   │       │   ├── reader_screen.dart
│   │   │       │   └── story_end_screen.dart
│   │   │       └── widgets/
│   │   │           ├── highlighted_text.dart     # resaltado palabra-a-palabra
│   │   │           ├── audio_controls.dart
│   │   │           ├── vocabulary_popup.dart
│   │   │           └── comprehension_question.dart
│   │   │
│   │   ├── progress/                 # Logros, insignias, stats
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── progress_screen.dart
│   │   │           └── achievement_detail_screen.dart
│   │   │
│   │   ├── parent/                   # Panel padres
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── parent_dashboard_screen.dart
│   │   │       │   ├── parental_controls_screen.dart
│   │   │       │   └── parent_reports_screen.dart
│   │   │       └── widgets/
│   │   │           ├── usage_chart.dart
│   │   │           └── time_limit_dialog.dart
│   │   │
│   │   ├── subscription/             # Suscripción, paywall, billing
│   │   │   ├── data/
│   │   │   │   ├── billing_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── play_billing_datasource.dart  # Android
│   │   │   │       └── storekit_billing_datasource.dart  # iOS
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── subscription_controller.dart
│   │   │       └── screens/
│   │   │           ├── paywall_screen.dart
│   │   │           └── manage_subscription_screen.dart
│   │   │
│   │   └── child_profile/            # Gestión de perfiles de niños
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── controllers/
│   │           │   └── child_profile_controller.dart
│   │           └── screens/
│   │               ├── child_picker_screen.dart
│   │               └── edit_child_screen.dart
│   │
│   └── shared/                       # Cosas compartidas entre features
│       ├── models/                   # Modelos de datos compartidos
│       │   ├── story_model.dart      # DTO que mapea a/desde Firestore
│       │   ├── user_model.dart
│       │   └── child_profile_model.dart
│       ├── providers/                # Providers Riverpod globales
│       │   ├── auth_provider.dart
│       │   ├── active_child_provider.dart
│       │   └── connectivity_provider.dart
│       └── widgets/
│           ├── child_avatar.dart
│           └── story_grid.dart
│
├── test/                             # Tests unitarios y de widget
│   ├── core/
│   │   └── utils/
│   │       └── validators_test.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository_impl_test.dart
│   │   │   └── presentation/
│   │   │       └── controllers/
│   │   │           └── auth_controller_test.dart
│   │   ├── story/
│   │   │   └── presentation/
│   │   │       └── controllers/
│   │   │           └── reader_controller_test.dart
│   │   └── ...
│   └── integration/                  # Tests de integración
│       └── story_reading_flow_test.dart
│
├── integration_test/                 # Tests end-to-end (instrumentación)
│   └── onboarding_test.dart
│
├── assets/                           # Assets estáticos de la app
│   ├── images/
│   │   ├── logos/
│   │   ├── avatars/                  # Avatares predefinidos para niños
│   │   ├── achievements/             # Iconos de insignias
│   │   └── onboarding/               # Ilustraciones del onboarding
│   ├── icons/
│   ├── fonts/
│   │   ├── OpenDyslexic/             # Fuente accesible opcional
│   │   └── Fredoka/                  # Fuente principal lúdica
│   ├── animations/                   # Lottie JSONs (celebraciones, etc.)
│   └── l10n/                         # Localización EN/ES
│       ├── app_en.arb
│       └── app_es.arb
│
├── firebase/                         # Config y reglas de Firebase
│   ├── firestore.rules               # Reglas de seguridad Firestore
│   ├── storage.rules                 # Reglas de seguridad Storage
│   ├── functions/                    # Cloud Functions (Node/TS)
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── story_ingest.ts       # Ingesta de cuentos (Gemini + TTS)
│   │   │   ├── billing_validation.ts # Validación de receipts
│   │   │   ├── achievement_engine.ts # Trigger de logros
│   │   │   ├── analytics_aggregator.ts
│   │   │   └── coppa_cleanup.ts      # Borrado de datos de niños
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── firebase.json
│
├── scripts/                          # Scripts utilitarios (no se deployan)
│   ├── seed_stories.ts               # Cargar cuentos de dominio público
│   └── backfill_audio.ts             # Regenerar audio si cambian voces TTS
│
├── docs/                             # Esta documentación
│   ├── 00-index.md
│   ├── 01-architecture.md
│   └── ...
│
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Lint + tests en cada PR
│       ├── cd_dev.yml                # Deploy a Firebase dev project
│       └── cd_prod.yml               # Deploy a Firebase prod project
│
├── pubspec.yaml                      # Dependencias Dart
├── pubspec.lock
├── analysis_options.yaml             # Reglas de lint (flutter_lints + custom)
├── .gitignore
├── .env.example                      # Variables de entorno de ejemplo
└── README.md
```

---

## 3. Reglas de organización

### 3.1 Una feature = una carpeta

Cualquier cosa que tenga que ver con "cuentos" (pantallas, controllers, modelos, datasources) vive en `lib/features/story/`. Si la feature crece mucho, se subdivide internamente pero la carpeta raíz sigue siendo `story/`.

### 3.2 Imports: de afuera hacia adentro

```
presentation  →  domain  →  data
     ↑              ↑          ↑
     |              |          |
  no puede importar data   no puede importar presentation
```

Es decir:
- `presentation/` puede importar de `domain/` pero NO de `data/`.
- `domain/` NO puede importar de `presentation/` ni de `data/`.
- `data/` implementa interfaces de `domain/` y puede importar de `core/` y `shared/`.

Esto se hace cumplir con el linter `import_lint` o `dart_code_metrics`.

### 3.3 Inyección de dependencias con Riverpod

Los Controllers dependen de interfaces (`abstract class`) declaradas en `domain/repositories/`. Las implementaciones viven en `data/` y se inyectan vía Riverpod:

```dart
// En shared/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: FirebaseAuthDatasource(),
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
  );
});
```

Esto permite que en tests reemplacemos `AuthRepositoryImpl` por un `MockAuthRepository`.

### 3.4 Nombres de archivos

- Pantallas: `<name>_screen.dart` (ej: `login_screen.dart`)
- Widgets: `<name>.dart` o `<name>_widget.dart` (sin sufijo si es obvio)
- Controllers: `<name>_controller.dart`
- Repositories: `<name>_repository.dart` (abstracto) y `<name>_repository_impl.dart` (implementación)
- Datasources: `<name>_datasource.dart`
- Modelos/Entidades: `<name>.dart` (sin sufijo)
- Tests: mismo nombre que el archivo bajo test + `_test.dart`

### 3.5 Convenciones de nombres

- **Clases**: `PascalCase` (`AuthController`, `StoryRepository`)
- **Variables y funciones**: `camelCase` (`getCurrentChild`, `isPremium`)
- **Constantes**: `camelCase` o `lowerCamelCase` (`defaultAvatar`, no `DEFAULT_AVATAR`)
- **Archivos**: `snake_case` (`auth_controller.dart`)
- **Colecciones Firestore**: `snake_case` plural (`user_progress`, `stories`)

---

## 4. Dependencias clave (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
  cloud_functions: ^5.1.0
  firebase_analytics: ^11.3.3
  firebase_crashlytics: ^4.1.3
  firebase_app_check: ^0.3.1+7
  firebase_remote_config: ^5.1.3

  # Routing
  go_router: ^14.2.7

  # Audio
  just_audio: ^0.5.37       # Reproductor de audio principal
  audio_service: ^0.18.15   # Soporte background audio

  # Local storage / cache
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_cache_manager: ^3.4.1

  # Billing
  in_app_purchase: ^3.2.0   # Multiplataforma (Play + App Store)

  # Networking
  dio: ^5.7.0

  # Localization
  intl: ^0.19.0
  flutter_localizations:
    sdk: flutter

  # UI
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.2
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0

  # Utils
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  uuid: ^4.5.1
  logger: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

  flutter_lints: ^4.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  mocktail: ^1.0.4
  firebase_auth_mocks: ^0.14.0
  fake_cloud_firestore: ^3.0.3
  firebase_storage_mocks: ^0.7.0
```

---

## 5. Notas para no-programadores

Si estás revisando el repo y no sos programador, lo importante a entender es:

- **`lib/`** es donde vive todo el código de la app. Lo demás (`android/`, `ios/`, `assets/`) son configuraciones y recursos.
- **`lib/features/`** es donde están las funcionalidades: cada carpeta es una parte de la app (login, cuentos, progreso, panel padres, etc.).
- **`lib/core/`** es lo compartido por toda la app: tema visual, configuración, utilidades.
- **`firebase/functions/`** es código del backend (serverless). Lo escribe el equipo y se deploya a Firebase.
- **`docs/`** es esta documentación.
- **`test/`** y **`integration_test/`** son tests automatizados que validan que el código funciona.

Cuando leas o pidas cambios, te conviene referenciar por feature: "en la feature de story" o "en el panel de padres", en lugar de por archivo específico.
