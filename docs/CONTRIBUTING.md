# Contributing to StoryEnglish Kids

¡Gracias por interesarte en contribuir a **StoryEnglish Kids**! Este documento
describe cómo trabajar en el proyecto: branching, commits, code review, testing
y reglas de calidad.

Si es tu primera vez en el repo, leé primero [`SETUP.md`](./SETUP.md) para
tener la app corriendo localmente.

---

## 1. Código de conducta

Todos los contribuidores deben respetar el
[Code of Conduct](../CODE_OF_CONDUCT.md). Sé amable, paciente y respetuose.
Incumplimientos se reportan a `maintainers@storyenglish.app`.

---

## 2. Branching model

Usamos **Git Flow simplificado** con dos branches perpetuas:

- `main` — Código en producción. Solo recibe merges desde `develop` (vía
  release PR) o hotfixes directos.
- `develop` — Código en desarrollo. Es la branch default del repo. Aquí se
  mergean las features terminadas.

### 2.1 Crear una branch

```bash
# Actualizá develop
git checkout develop
git pull origin develop

# Creá tu branch de feature
git checkout -b feature/T1.2.3-add-login-screen
```

### 2.2 Convención de nombres de branches

| Prefijo | Uso | Ejemplo |
|---------|-----|---------|
| `feature/` | Nueva funcionalidad | `feature/T1.2.3-avatar-picker` |
| `fix/` | Bug fix | `fix/T2.1.4-streak-not-incrementing` |
| `chore/` | Mantenimiento, deps, tooling | `chore/upgrade-flutter-3.27` |
| `docs/` | Solo documentación | `docs/update-setup-guide` |
| `refactor/` | Refactor sin cambio de comportamiento | `refactor/auth-controller-cleanup` |
| `test/` | Agregar o mejorar tests | `test/T1.1.5-auth-controller-coverage` |
| `hotfix/` | Fix urgente a producción (desde `main`) | `hotfix/T3.2.1-crash-on-paywall` |

**Incluí el ID del issue** (`T<fase>.<sprint>.<n>`) cuando exista, al inicio
del nombre. Esto facilita el traceabilidad entre branches, PRs e issues.

### 2.3 Mantener tu branch actualizada

```bash
# Rebase sobre develop (preferido sobre merge para histórico limpio)
git fetch origin
git rebase origin/develop
```

Si hay conflictos, resolvelos localmente y continuá. Si el rebase se complica,
podés hacer merge en su lugar:

```bash
git merge origin/develop
```

---

## 3. Convención de commits — Conventional Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/) para que el
histórico sea legible y para automatizar el changelog y el versionado.

### 3.1 Formato

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 3.2 Types válidos

| Type | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva feature visible al usuario |
| `fix` | Bug fix |
| `docs` | Cambios en documentación (`.md`, comentarios de API) |
| `style` | Cambios que no afectan el código (formato, espacios, comas) |
| `refactor` | Refactor de código sin cambio de comportamiento |
| `perf` | Mejora de performance |
| `test` | Agregar o corregir tests |
| `build` | Cambios en build system, deps, pubspec |
| `ci` | Cambios en CI/CD |
| `chore` | Tareas de mantenimiento que no entran en otras |
| `revert` | Revierte un commit anterior |

### 3.3 Scope (opcional pero recomendado)

El scope indica la parte del código afectada. Usualmente coincide con una
feature o capa:

```
feat(auth): agregar login con Apple
fix(story): corregir resaltado cuando el audio termina
refactor(parent-controller): extraer validación a método privado
docs(setup): agregar troubleshooting de pod install
ci(cd-prod): agregar aprobación manual
```

### 3.4 Reglas

- **Descripción:** en imperativo, minúsculas, sin punto final, máx 72 chars.
  - ✅ `feat(auth): agregar login con Apple`
  - ❌ `Agregué login con Apple.`
  - ❌ `feat(auth): Este commit agrega la funcionalidad de login con Apple ID para que los usuarios puedan autenticarse usando su cuenta de Apple.` (muy largo)
- **Body (opcional):** explica el **porqué**, no el qué. Wrap a 72 chars.
- **Footer (opcional):** `Closes #123`, `BREAKING CHANGE:`, `Co-authored-by:`.
- **Un commit = un cambio lógico.** No mezcles refactor con feature en el mismo
  commit. Si necesitás refactor antes de la feature, hacé dos commits.

### 3.5 Ejemplos

```
feat(story): resaltar palabra actual durante playback

El reader_controller ahora escucha position stream de just_audio y
expone currentWordIndex. HighlightedText lo consume para subrayar la
palabra actual.

Closes #T1.4.5
```

```
fix(billing): validar receipt de Play antes de activar premium

Antes se activaba premium optimistamente y se validaba después. Ahora
validamos primero y solo activamos si la llamada a Play Developer API
retorna estado active/grace_period. Previene fraude con receipts falsos.

Closes #T3.1.7
```

```
refactor(auth)!: cambiar AuthRepository.signInWithEmail a async

BREAKING CHANGE: AuthRepository.signInWithEmail ahora retorna
Future<AppUser> en vez de AppUser. Todos los call sites deben await.
```

### 3.6 squash merge

Configuramos GitHub para hacer **squash merge** al mergear PRs. Esto significa
que todos tus commits se comprimen en uno solo con el título del PR. Asegurate
de que el **título del PR** cumpla Conventional Commits, porque ese será el
commit final en `develop`.

---

## 4. Antes de abrir un PR — Checklist de calidad

Tu PR no será revisado si no cumple estos requisitos. CI los verifica
automáticamente, pero te ahorras tiempo si los corrés antes.

### 4.1 Tests

```bash
# Unit + widget tests
flutter test

# Con coverage
flutter test --coverage

# Cloud Functions tests
cd firebase/functions && npm test && cd ../..
```

**Cobertura mínima del PR:**
- Total: **70%** (CI falla si baja)
- Domain layer: 85%
- Data layer: 70%
- Presentation controllers: 75%
- Firestore rules: 90%
- Cloud Functions: 70%

Si tu feature nueva no tiene tests, el PR va a ser rechazado. Para cada bug
fix, agregá un test que reproduzca el bug antes de arreglarlo
(regression test).

### 4.2 Linting

```bash
# Flutter analyze (flutter_lints + reglas custom)
flutter analyze

# Dart Code Metrics (ruleset strict)
dart run dart_code_metrics:metrics lib --ruleset=strict

# TypeScript (Cloud Functions)
cd firebase/functions && npx tsc --noEmit && cd ../..
```

**Cero warnings, cero errores.** Si `flutter analyze` reporta algo, no lo
ignores con `// ignore:` sin justificación documentada en un comentario.

### 4.3 Formato

```bash
# Dart format (viene con Flutter)
dart format lib test integration_test --set-exit-if-changed
```

Si el comando retorna exit code distinto de cero, hay archivos sin formatear.
Corregí con:

```bash
dart format lib test integration_test
```

### 4.4 Build

```bash
# Generar código (freezed, json_serializable, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Build Cloud Functions
cd firebase/functions && npm run build && cd ../..

# Build APK de prueba (dev flavor)
flutter build apk --flavor dev -t lib/main_dev.dart --debug
```

### 4.5 Manual smoke test

Antes de abrir el PR, corré la app y hacé un smoke test de tu feature en un
emulador. Verificá que no rompió otras features.

---

## 5. Abrir el PR

### 5.1 Título

Cumple Conventional Commits (ver sección 3).

### 5.2 Descripción

Usá el [template](../.github/pull_request_template.md). Completá todas las
secciones. Si tu PR no cierra un issue, explicá por qué.

### 5.3 Tamaño

Mantené los PRs **chicos**. Regla general:
- **< 100 líneas:** ideal, fácil de revisar.
- **100-500 líneas:** aceptable, requiere más atención.
- **500-1000 líneas:** dividí en PRs más chicos.
- **> 1000 líneas:** rechazado salvo justificación muy fuerte (ej: scaffold
  inicial generado por código).

Si tu feature es grande, dividí en PRs incrementales:
1. PR 1: modelo de datos + tests
2. PR 2: repositorio + tests
3. PR 3: controller + tests
4. PR 4: UI + widget tests
5. PR 5: integration test

### 5.4 Reviewers

- Asigná al menos 1 reviewer. Si no sabés a quién, asigná al tech lead.
- Para PRs que toquen `firebase/firestore.rules` o `firebase/storage.rules`,
  necesitás **2 approvals** (security review).
- Para PRs que toquen billing (`subscription/` o `billing_validation.ts`),
  necesitás **2 approvals** (compliance review).

---

## 6. Code review

### 6.1 Para el autor

- **Respondé todos los comentarios.** Si aceptás un cambio, hacelo. Si no,
  explicá por qué con respeto.
- **No tomés los comentarios como ataques personales.** El objetivo es mejorar
  el código.
- Si hacés cambios después del review, **re-requesteá el review** del reviewer
  que pidió cambios.
- Si el reviewer marca un comentario como "resolved", no lo reabras.

### 6.2 Para el reviewer

#### Checklist de review

- [ ] **¿El código hace lo que dice el PR?** Leer el diff entero, no solo
  spottear.
- [ ] **¿Hay tests?** ¿Cubren happy path + edge cases + errors?
- [ ] **¿El código es legible?** ¿Los nombres son descriptivos? ¿Hay
  comentarios necesarios?
- [ ] **¿Respeta la arquitectura?** (presentation → domain → data, sin imports
  prohibidos — ver `docs/02-folder-structure.md` sección 3.2).
- [ ] **¿Maneja errores?** ¿No hay `catch (e) {}` vacío?
- [ ] **¿No rompe retrocompatibilidad?** Si la rompe, ¿está marcado con
  `BREAKING CHANGE:` y hay plan de migración?
- [ ] **¿Seguridad?** ¿No hay secretos hardcodeados? ¿Input del usuario se
  valida? ¿Reglas de Firestore no se relajan?
- [ ] **¿Performance?** ¿No hace N+1 queries a Firestore? ¿No bloquea el UI
  thread con cómputo pesado? ¿No re-renderiza widgets innecesariamente?
- [ ] **¿Accesibilidad?** ¿Tiene labels semánticos? ¿Contraste de colores?
  ¿Tap targets >= 44x44pt? (ver `docs/10-accessibility.md`)
- [ ] **¿COPPA/GDPR-K?** ¿Datos de niños se manejan correctamente? ¿No se
  exponen a terceros sin consentimiento parental? (ver
  `docs/11-coppa-gdpr-k.md`)

#### Cómo dar feedback

- **Sé específico.** "Esto está mal" → "Esta validación no cubre emails con
  subdominio (ej: user@mail.co.uk). Podés usar el paquete `email_validator` o
  esta regex: `<regex>`."
- **Distinguí entre blocking y non-blocking.** Usa prefijos:
  - `Blocking:` — debe cambiarse antes del merge.
  - `Nit:` — preferencia personal, no bloqueante.
  - `Question:` — querés entender la decisión, no necesariamente cambiar.
  - `Praise:` — destacá código bueno también! 💚
- **Proponé soluciones, no solo problemas.** Si decís "esto está mal", decí
  también "yo lo haría así: `<código>`".

### 6.3 Tiempos

- **Primer review:** dentro de 24h hábiles de asignado.
- **Re-review después de cambios:** dentro de 24h hábiles.
- Si estás de vacaciones o no podés reviewar, desasignate y reasigná a otra
  persona.

---

## 7. Reglas de linting

Las reglas de linting viven en:

- `analysis_options.yaml` — reglas de `flutter_lints` + custom (Dart).
- `firebase/functions/tsconfig.json` — strict mode TypeScript.
- `dart_code_metrics` — reglas adicionales de arquitectura y calidad.

### 7.1 Reglas destacadas (Dart)

- `avoid_dynamic_calls: error` — no llamar métodos en `dynamic`.
- `strict-casts: true` — requiere casts explícitos.
- `strict-raw-types: true` — requiere tipos genéricos completos.
- `prefer_const_constructors: warning`
- `prefer_final_locals: warning`
- `unawaited_futures: warning` — todo `Future` debe ser await o asignado.
- `directives_ordering: warning` — imports ordenados: dart → package → relative.

### 7.2 Reglas destacadas (TypeScript)

- `strict: true`
- `noImplicitAny: true`
- `noImplicitReturns: true`
- `noFallthroughCasesInSwitch: true`
- `forceConsistentCasingInFileNames: true`

### 7.3 Supresiones

Si necesitás suprimir una regla, usá `// ignore: <rule>` (Dart) o
`// @ts-expect-error <reason>` (TS) con un comentario explicando por qué. Las
supresiones sin justificación se rechazan en review.

---

## 8. Cobertura mínima

| Métrica | Mínimo | Target |
|---------|--------|--------|
| **Total** | 70% | 80% |
| Capa dominio (`features/*/domain/`) | 85% | 95% |
| Capa datos (`features/*/data/`) | 70% | 85% |
| Controllers (`features/*/presentation/controllers/`) | 75% | 85% |
| Firestore rules (`firestore.rules`) | 90% | 95% |
| Cloud Functions (`firebase/functions/src/`) | 70% | 85% |

CI verifica estos umbrales automáticamente (job `unit-tests` en
`.github/workflows/ci.yml`). Si tu PR baja la cobertura, CI falla y no se
mergea.

Para ver el reporte localmente:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # macOS
# xdg-open coverage/html/index.html   # Linux
```

---

## 9. Proceso de release

Los releases son automáticos vía tags:

1. Cuando `develop` está listo para producción, se crea un PR `develop` → `main`.
2. Al mergear a `main`, se tagea con `vX.Y.Z` (semver).
3. El tag dispara `cd_prod.yml`, que deploya a Firebase prod (con approval
   manual) y crea un GitHub Release con notas autogeneradas.

### 9.1 Versionado (semver)

- `MAJOR`: cambios que rompen compatibilidad (raro en app móvil).
- `MINOR`: nuevas features visibles al usuario.
- `PATCH`: bug fixes.

Ejemplos: `v1.0.0`, `v1.1.0`, `v1.1.1`, `v2.0.0-rc.1`.

### 9.2 Hotfixes

Para un bug urgente en producción:

```bash
git checkout main
git pull origin main
git checkout -b hotfix/T4.4.1-crash-on-launch

# Fix, commit, push, PR a main (con tag de hotfix)
# Después, mergear también a develop para que no se pierda el fix
```

---

## 10. Reconocimientos

Cada release incluye créditos a los contribuidores. Si hiciste 5+ PRs
mergeados en un release, te mencionamos en las release notes. 🎉

---

¿Dudas? Abrí un issue con label `docs` o preguntá en el canal `#dev-help` de
Slack.
