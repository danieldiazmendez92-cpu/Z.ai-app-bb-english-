---
name: Bug report
about: Reportá un bug para que lo corrijamos
title: "[BUG] <descripción corta del problema>"
labels: ["bug", "triage"]
assignees: []
---

## Descripción del bug

<!-- Describí claramente qué está roto. Un párrafo alcanza. -->

## Comportamiento esperado

<!-- ¿Qué debería pasar si todo funcionara bien? -->

## Comportamiento actual

<!-- ¿Qué pasa en realidad? -->

## Pasos para reproducirlo

1.
2.
3.
4.

**Reproducibilidad:** <!-- ¿Pasa siempre? A veces? Solo en ciertas condiciones? -->
- [ ] Siempre (100%)
- [ ] A veces (~50%)
- [ ] Raramente (<10%)

## Ambiente

- **App version:** <!-- ej: 1.0.3 dev flavor, build #123 -->
- **Dispositivo:** <!-- ej: iPhone 13, Samsung Galaxy S22, iPad Pro 11" -->
- **OS:** <!-- ej: iOS 17.2, Android 14 -->
- **Conexión:** <!-- Wi-Fi / 4G / offline -->
- **Cuenta:** <!-- free / premium / trial -->
- **Idioma app:** <!-- EN / ES -->

## Logs / stack trace

<!--
Pegá acá cualquier log relevante. Para Flutter:
- `flutter logs` mientras reproducís el bug
- Crashlytics crash ID si lo tenés
Para Cloud Functions:
- Logs de Firebase Console > Functions > Logs

No pegues tokens, API keys ni datos personales de usuarios.
-->

```
<paste logs here>
```

## Screenshots / video

<!-- Si el bug es visual, adjuntá captura o video. -->

## Posible causa (si la conocés)

<!-- Si tenés idea de qué puede estar causando el bug, escribiló acá. Nos
ahorra tiempo de investigación. -->

## Severidad

<!-- Marcá una opción. -->

- [ ] **Crítico** — App crashea / data se pierde / no se puede usar
- [ ] **Alto** — Feature principal no funciona / workaround difícil
- [ ] **Medio** — Feature secundaria no funciona / workaround fácil
- [ ] **Bajo** — Cosmético / typo /UX menor

## ¿Querés arreglarlo vos?

- [ ] Sí, abrí una branch `fix/...` y mando PR
- [ ] No, prefiero que lo arreglen del equipo core
