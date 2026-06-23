# StoryEnglish Kids

> Una aplicación móvil para que niños de 2 a 7 años aprendan inglés escuchando y leyendo cuentos infantiles de dominio público.

[![Status](https://img.shields.io/badge/status-arquitectura-blue)](docs/00-index.md)
[![Stack](https://img.shields.io/badge/Flutter-Firebase-Gemini-TTS-orange)](docs/01-architecture.md)
[![License](https://img.shields.io/badge/license-TBD-lightgrey)]()

---

## ¿Qué es?

**StoryEnglish Kids** es una app móvil (Android + iOS) que combina cuentos clásicos en inglés (de dominio público: Madre Ganso, Aesop, Beatrix Potter, etc.) con audio narrado por Google TTS, traducción al español, vocabulario destacado y seguimiento de progreso, para que niños hispanohablantes de 2 a 7 años aprendan inglés de forma natural y divertida.

El proyecto está pensado como un producto freemium con suscripción mensual/anual, panel de control para padres, sistema de logros e insignias, y modo de lectura guiada con resaltado sincronizado de palabras durante la reproducción del audio.

## Stack tecnológico

| Capa | Tecnología | Por qué |
|------|------------|---------|
| App móvil | **Flutter** | Un solo codebase para Android y iOS. Buena performance con animaciones y audio. |
| Backend | **Firebase** | Auth + Firestore + Storage + Functions listos para usar, sin servidor que mantener. |
| IA | **Google Gemini API** | Genera glosarios, traducciones contextuales, y preguntas de comprensión por cuento. |
| Audio | **Google Text-to-Speech** | Narración natural en inglés. Sync palabra-a-palabra para lectura guiada. |
| Pagos | **Google Play Billing** + **App Store Billing** | Suscripciones nativas en cada store. |

## Features principales

- **Autenticación** con email, Google y Apple (con verificación parental obligatoria)
- **Biblioteca de cuentos** organizada por edad (2-4, 4-6, 6-7) y categorías temáticas
- **Modo lectura guiada** con resaltado de palabras sincronizado al audio narrado
- **Vocabulario destacado** por cuento, con traducción y pronunciación
- **Seguimiento de progreso** por niño (cuentos leídos, minutos, palabras aprendidas)
- **Sistema de logros e insignias** gamificado
- **Panel para padres** con reportes, controles parentales y gestión de suscripción
- **Suscripción mensual y anual** con modelo freemium
- **Diseño colorido y lúdico**, optimizado para uso infantil

## Estado actual

El proyecto está en fase de **definición de arquitectura**. La documentación técnica completa está en la carpeta [`docs/`](docs/00-index.md) e incluye:

- Arquitectura del sistema con diagramas
- Estructura de carpetas del proyecto Flutter
- Modelos de datos y esquema de Firestore
- Reglas de seguridad y cumplimiento COPPA/GDPR-K
- Roadmap de desarrollo en 5 fases con sprints y tareas
- Estimación de costos por escala de usuarios
- Modelo de monetización
- Estrategia de testing y accesibilidad
- Matriz de riesgos

## Cómo leer la documentación

Si no sos programador, te recomendamos leer en este orden:

1. [`docs/00-index.md`](docs/00-index.md) — Índice general
2. [`docs/01-architecture.md`](docs/01-architecture.md) — Cómo funciona el sistema en grande
3. [`docs/06-roadmap.md`](docs/06-roadmap.md) — Qué se va a construir y en qué orden
4. [`docs/08-monetization.md`](docs/08-monetization.md) — Cómo se gana plata
5. [`docs/07-costs.md`](docs/07-costs.md) — Cuánto cuesta mantenerlo
6. [`docs/11-risks.md`](docs/11-risks.md) — Qué puede salir mal

Si vas a programar o contratar devs, leé todo en orden.

## Licencia

Por definir. Los cuentos incluidos son de dominio público; el código de la app será propietario.
