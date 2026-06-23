# Índice de documentación — StoryEnglish Kids

Esta carpeta contiene la documentación técnica completa del proyecto. Cada archivo cubre un aspecto específico.

## Mapa de documentos

| # | Documento | Qué cubre | Para quién |
|---|-----------|-----------|------------|
| 00 | `00-index.md` | Este índice | Todos |
| 01 | `01-architecture.md` | Arquitectura del sistema, stack, diagramas de arquitectura, componentes Flutter y flujos de usuario | Todos |
| 02 | `02-folder-structure.md` | Estructura de carpetas del proyecto Flutter | Devs |
| 03 | `03-data-models.md` | Modelos de datos en Dart + diagrama ER | Devs |
| 04 | `04-firestore-schema.md` | Diseño de colecciones Firestore, campos, índices | Devs |
| 05 | `05-security-and-privacy.md` | Reglas de seguridad, RBAC, COPPA/GDPR-K | Devs + Legal |
| 06 | `06-roadmap.md` | 5 fases de desarrollo con sprints y tareas accionables | PM + Devs |
| 07 | `07-costs.md` | Estimación de costos Firebase/Gemini/TTS por escala | Negocio |
| 08 | `08-monetization.md` | Modelo freemium, precios, integración billing | Negocio |
| 09 | `09-testing.md` | Estrategia de testing y CI/CD | Devs |
| 10 | `10-accessibility.md` | Accesibilidad (TalkBack, VoiceOver, dislexia) | Devs + UX |
| 11 | `11-risks.md` | Matriz de riesgos técnicos, producto, regulatorios | Todos |

## Orden de lectura sugerido

### Si no sos programador

1. **01-architecture.md** → entendé qué se está construyendo
2. **06-roadmap.md** → cuándo se construye cada cosa
3. **08-monetization.md** → cómo se gana plata
4. **07-costs.md** → cuánto cuesta mantener
5. **11-risks.md** → qué puede salir mal
6. **10-accessibility.md** → por qué importa la accesibilidad
7. El resto podés saltarlo o leerlo con ayuda

### Si sos dev

Leé en orden 01 → 11. Es lo recomendado.

### Si sos PM/Product

01 → 06 → 08 → 11 → 07.

## Convenciones

- Los diagramas están escritos en **Mermaid**, que GitHub renderiza automáticamente.
- Los modelos de datos en Dart usan notación `camelCase` para campos y `PascalCase` para clases.
- Los nombres de colecciones Firestore usan `snake_case` (ej: `user_progress`).
- Las tareas del roadmap tienen IDs tipo `T1.2.3` (Fase 1, Sprint 2, Tarea 3) para poder referenciarlas desde issues de GitHub.
