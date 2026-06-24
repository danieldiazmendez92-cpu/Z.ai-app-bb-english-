<!--
Gracias por contribuir a StoryEnglish Kids! 🎉

Antes de abrir el PR, leé docs/CONTRIBUTING.md y asegurate de cumplir todos
los items del checklist de abajo. Si algo no aplica, marcá el item con N/A y
explicá por qué.
-->

## Descripción

<!-- Describí claramente qué hace este PR y por qué. Si es un fix, describí el
bug. Si es una feature, describí el comportamiento nuevo. -->

...

## Issue relacionado

<!-- Reemplazá #XXX con el número del issue que cierra este PR.
Si el PR no cierra un issue existente, explicá por qué. -->

Closes #XXX

## Tipo de cambio

<!-- Marcá con una `x` la opción que aplique. -->

- [ ] **feat** — Nueva funcionalidad visible al usuario
- [ ] **fix** — Bug fix
- [ ] **docs** — Solo documentación
- [ ] **refactor** — Refactor sin cambio de comportamiento
- [ ] **perf** — Mejora de performance
- [ ] **test** — Agregar o mejorar tests
- [ ] **build** / **ci** / **chore** — Tooling, deps, infra
- [ ] **Breaking change** — Rompe compatibilidad (marcalo y explicá el plan de migración abajo)

## Screenshots / videos

<!-- Si tu PR cambia UI, adjuntá screenshots o videos del "antes" y "después".
Para videos, subilos a un servicio externo (Loom, YouTube unlisted) y linkeá.
No es necesario para PRs que no tocan UI. -->

-

## Cómo probarlo

<!-- Pasos para que el reviewer pueda reproducir el comportamiento.
Si tu feature requiere datos de prueba, describí cómo cargarlos. -->

1.
2.
3.

## Checklist de calidad

<!-- Marcá cada item después de verificarlo. CI va a fallar si alguno no
pasa, así que mejor revisarlos antes. -->

- [ ] **Tests pasan localmente** (`flutter test` y `cd firebase/functions && npm test`)
- [ ] **Coverage no baja del 70%** (verificar con `flutter test --coverage`)
- [ ] **Tests nuevos** agregados para la feature/fix (o justificación de por qué no aplican)
- [ ] **`flutter analyze` sin warnings ni errores**
- [ ] **`dart run dart_code_metrics:metrics lib --ruleset=strict` sin errores**
- [ ] **`dart format` ejecutado** (`dart format lib test integration_test`)
- [ ] **`dart run build_runner build --delete-conflicting-outputs` ejecutado** (si修改aste modelos)
- [ ] **Cloud Functions typecheckean** (`cd firebase/functions && npx tsc --noEmit`) — solo si tocaste `firebase/`
- [ ] **Smoke test manual** en emulador/dispositivo (si修改aste UI o flujos)
- [ ] **Documentación actualizada** (CHANGELOG, docs/ si aplica, comentarios de API)
- [ ] **No hay secretos/credenciales hardcodeados**
- [ ] **Conventional Commits** en el título del PR y en cada commit
- [ ] **Tamaño razonable** (< 500 líneas idealmente; si es más grande, explicá por qué)
- [ ] **Accesibilidad verificada** (labels semánticos, contraste, tap targets ≥ 44x44pt) — solo si tocaste UI

## Notas para el reviewer

<!-- Algo que el reviewer deba saber? Decisiones de diseño no obvias? Trade-offs? -->

-

## Post-merge

<!-- Si hay acciones que hacer después de merge (deploy manual, comunicación
al equipo, etc.), listalas acá. -->

-
