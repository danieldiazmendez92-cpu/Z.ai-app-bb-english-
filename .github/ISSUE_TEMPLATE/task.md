---
name: Technical task
about: Tarea técnica (refactor, deps, tooling, infra, research) que no es ni bug ni feature
title: "[TASK] <descripción corta de la tarea>"
labels: ["task", "triage"]
assignees: []
---

## Resumen

<!-- Una frase describiendo la tarea. -->

## Contexto

<!-- ¿Por qué hay que hacer esta tarea? ¿De qué issue/PR/discusión viene?
¿Qué problema previene o qué habilita? -->

## Scope

### Incluido en esta tarea

- [ ]
- [ ]
- [ ]

### Fuera de scope (no se hace acá)

- [ ]
- [ ]

## Criterios de aceptación

<!-- ¿Cómo sabemos que la tarea está terminada? Listá items verificables. -->

- [ ]
- [ ]
- [ ]

## Plan técnico (opcional)

<!-- Si la tarea no es trivial, describí los pasos a seguir. Si hay varias
alternativas, comparalas y justificá la elección. -->

### Pasos

1.
2.
3.

### Archivos que se van a tocar

- `path/to/file.dart` — qué cambia
- `path/to/file.ts` — qué cambia

### Dependencias nuevas / version bumps

- `package_name: ^x.y.z` — para qué

## Esfuerzo estimado

- [ ] XS (< 1h)
- [ ] S (1-4h)
- [ ] M (1-2 días)
- [ ] L (3-5 días)
- [ ] XL (> 1 semana, probablemente dividir)

## Riesgos

<!-- ¿Qué puede salir mal? ¿Cómo lo mitigamos? -->

- [ ] **Performance:** <!-- ej: refactor puede romper frame rate -->
- [ ] **Compatibilidad:** <!-- ej: bump de versión mayor de dependencia -->
- [ ] **Datos:** <!-- ej: migración que puede perder datos -->
- [ ] **Seguridad:** <!-- ej: cambio en reglas de Firestore -->
- [ ] **Sin riesgos conocidos**

## Testing

- [ ] Tests unitarios existentes siguen pasando
- [ ] Agregar tests nuevos para los cambios
- [ ] Smoke test manual
- [ ] No aplica (task no funcional)

## Tipo de task

- [ ] **Refactor** — sin cambio de comportamiento
- [ ] **Build / deps** — actualización de dependencias, build system
- [ ] **CI/CD** — workflows, scripts de deploy
- [ ] **Docs** — documentación interna
- [ ] **Research / spike** — investigación sin necessarily code (timebox)
- [ ] **Infra** — Firebase config, índices, reglas
- [ ] **Testing** — mejorar cobertura, agregar integration tests
- [ ] **Compliance** — COPPA, GDPR-K, accesibilidad

## Bloqueadores / dependencias

<!-- ¿Hay algo que deba pasar antes de que se pueda empezar esta task? -->

- Bloqueado por: #
- Bloquea a: #

## Notas

<!-- Cualquier cosa extra que el asignado deba saber. -->
