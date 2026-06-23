# 11 — Matriz de riesgos

> Identificación, evaluación y mitigación de los principales riesgos técnicos, de producto, regulatorios y de contenido para StoryEnglish Kids.

---

## 1. Metodología

Cada riesgo se evalúa con:
- **Probabilidad** (1-5): qué tan probable es que ocurra
- **Impacto** (1-5): qué tan grave sería si ocurre
- **Score** = Probabilidad × Impacto (1-25)
- **Mitigación**: qué hacemos para reducir probabilidad
- **Contingencia**: qué hacemos si ocurre (plan B)

**Priorización**:
- Score ≥15: crítico, mitigación obligatoria pre-launch
- Score 9-14: alto, mitigación antes de Fase 4
- Score ≤8: medio/bajo, monitorear

---

## 2. Matriz de riesgos

| # | Riesgo | Cat | P | I | Score | Mitigación | Contingencia |
|---|--------|-----|---|---|-------|------------|--------------|
| R1 | Rechazo de App Store por "Kids Category" | Reg | 4 | 5 | **20** | Seguir HIG de Apple al pie de la letra. Iterar verificación parental. | Cambiar a上架 con limitación de edad 9+ (sacrifica target 2-4 años) |
| R2 | Costo de Firestore explota por queries ineficientes | Tec | 4 | 4 | **16** | Denormalización + caching agresivo. Audit semanal de reads. | Cambiar a backend SQL (Supabase) - costo alto de migración |
| R3 | Google TTS genera audio malo para cuentos con diálogos | Tec | 3 | 4 | **12** | QA manual de cada cuento. SSML tuning para voces de personajes. | Contratar narrador humano para cuentos clave (costo +$) |
| R4 | Latencia de carga de cuento >3s | Tec | 3 | 4 | **12** | Precarga audio en background al abrir Story Detail. CDN. | Reducir calidad de audio (96kbps en lugar de 128kbps) |
| R5 | Apple cambia políticas de suscripción infantil | Reg | 3 | 5 | **15** | Monitorear Apple Developer news mensualmente. | Pivot a modelo de compra única (no subscription) |
| R6 | Gemini genera traducciones/contenido inapropiado | Cont | 3 | 5 | **15** | Review humano de cada cuento antes de publicar. Prompt engineering estricto. | No usar Gemini, contratar traductores humanos |
| R7 | Padres reportan que el niño se aburre rápido | Prod | 4 | 4 | **16** | Beta privada extensa (Sprint 1.5-2.4). Tests con niños reales. | Pivot a más gamificación, mini-juegos, recompensas |
| R8 | Free users no convierten a paid (<3%) | Prod | 4 | 5 | **20** | A/B testing de paywall desde Fase 4. Onboarding muestra valor premium. | Reducir free tier a 2 cuentos/mes. Aumentar precio. |
| R9 | Bug crítico en producción que afecta a niños | Tec | 3 | 5 | **15** | CI estricto. Beta privada. Feature flags. | Hotfix en <24h. Comunicación a padres. |
| R10 | Brecha de datos PII de niños | Reg | 2 | 5 | **10** | Reglas Firestore estrictas. App Check. Audit de seguridad. | Notificación 72h (GDPR). Investigación forense. Compensación a afectados. |
| R11 | Copyright de cuentos (no son realmente dominio público) | Cont | 3 | 4 | **12** | Source verification con Project Gutenberg / Wikimedia. Attribution completa. | Remover cuento. Comunicar a stores. |
| R12 | TTS API caída / rate limit | Tec | 2 | 3 | **6** | Pre-generar audio en ingesta (no runtime). Cache en Storage. | Queue de ingesta. Mantener catálogo con audio existente. |
| R13 | Cloud Functions cold start >3s | Tec | 3 | 3 | **9** | Min instances en funciones críticas. | Mover lógica crítica al cliente. |
| R14 | Quejas de padres por "demasiado tiempo en pantalla" | Prod | 3 | 3 | **9** | Feature de límite diario + bedtime. Comunicación positiva sobre uso educativo. | Campaña de comunicación "uso responsable". |
| R15 | Competencia (Duolingo Kids, Lingokids) lanza feature similar | Prod | 4 | 3 | **12** | Velocidad de iteración. Enfoque en narrativa (cuentos vs lecciones). | Pivot a nicho: cuentos en EN para hispanohablantes Latam. |
| R16 | Problemas de auth con Apple en iOS | Tec | 2 | 4 | **8** | Implementar Sign in with Apple según docs oficiales. Test en sandbox. | Email/password fallback siempre disponible. |
| R17 | Firebase cambia pricing o limita free tier | Reg | 2 | 4 | **8** | Monitorear Firebase release notes. | Migrar a Supabase o backend propio. |
| R18 | Problemas de billing con cambios en stores | Tec | 3 | 3 | **9** | Mantenerse al día con updates de billing SDKs. Tests con sandbox. | Hotfix rápido. Soporte directo a usuarios afectados. |
| R19 | App rechazada por "Designed for Families" en Google Play | Reg | 3 | 4 | **12** | Seguir Google Play Families policy al pie de la letra. | Apelar con documentación. Si persiste, lanzar sin Families (sin <13 users). |
| R20 | Traducciones automáticas de Gemini con errores | Cont | 3 | 3 | **9** | Review humano de traducción. Bilingual reviewer. | Contratar traductor profesional. |

---

## 3. Riesgos críticos (score ≥15) — detalle y plan de acción

### R1 — Rechazo de App Store por "Kids Category"

**Contexto**: Apple tiene regulaciones estrictas para apps en "Kids Category". Requiere:
- No analytics sin consentimiento parental explícito
- No ads (incluido contextuales)
- No IAP que no sean validados por Apple
- Content filtered por edad
- No enlaces externos sin parental gate

**Plan de mitigación**:
1. Antes de submit, revisar contra [Apple App Store Review Guidelines 1.3 (Kids Category)](https://developer.apple.com/app-store/kids-app-category/).
2. Implementar "parental gate" antes de cualquier acción sensible (cambiar settings, ir a web externa).
3. En Sprint 3.3, dedicar 2 días completos a verificar compliance Kids Category.
4. Tener a un consultor iOS con experiencia en Kids Category para review pre-submit.

**Plan de contingencia**:
- Si Apple rechaza por Kids Category, lanzar como app 9+ (sacrifica target 2-4 años pero mantiene 5-7).
- Esto afecta el TAM pero permite lanzar.

### R8 — Free users no convierten a paid (<3%)

**Contexto**: si la conversión es muy baja, el modelo freemium no financia el negocio.

**Plan de mitigación**:
1. En beta privada (Sprint 2.4), medir intención de compra con encuestas a padres.
2. Si <10% dicen "sí compraría", rediseñar propuesta de valor antes de lanzar.
3. A/B test de paywall desde Sprint 3.2 con 4 variantes.
4. Reducir free tier agresivamente si la conversión no sube: de 3 cuentos/mes a 1 cuento/mes.
5. Probar precio más bajo en Latam (PPP ajustado).

**Plan de contingencia**:
- Si después de 3 meses de lanzado la conversión es <2%, considerar pivot a modelo "compra única" (pay $9.99 una vez, lifetime access).
- O pivot a B2B (licencias a escuelas) que tiene mejor unit economics.

### R5 — Apple cambia políticas de suscripción infantil

**Contexto**: Apple podría prohibir suscripciones auto-renovables en Kids Category, o exigir validación parental adicional.

**Plan de mitigación**:
1. Suscribirse a Apple Developer news y revisar mensualmente.
2. Mantener relación con DTS (Developer Technical Support) de Apple.
3. Diversificar revenue stream (no depender 100% de suscripción móvil).

**Plan de contingencia**:
- Migrar a compra única (one-time purchase).
- Migrar a modelo web con Stripe (pero requiere que el usuario salga de la app para pagar, lo cual Apple no prohíbe para contenido físico, pero sí para digital).

### R7 — Padres reportan que el niño se aburre rápido

**Contexto**: las apps infantiles tienen alta churn. Si después de 2 semanas el niño no quiere abrir la app, el padre cancela.

**Plan de mitigación**:
1. Beta privada con 20 familias, encuesta semanal a padres.
2. Tests de usabilidad con niños (observar interacción).
3. Iterar contenido y UX basado en feedback.
4. Asegurar que el día 1 tenga suficiente "wow" (3 cuentos completos gratis, primer logro rápido).

**Plan de contingencia**:
- Agregar mini-juegos por cuento (memory, spelling).
- Sistema de "puntos" canjeables por personalización de avatar.
- Modo "cuento del día" para crear hábito.

### R6 — Gemini genera contenido inapropiado

**Contexto**: aunque le pidamos a Gemini solo glosarios y traducciones, podría generar texto inapropiado para niños.

**Plan de mitigación**:
1. Prompt engineering estricto con system prompt: "You are generating content for children aged 2-7. Refuse any inappropriate request."
2. Filtro de palabras prohibidas post-generación.
3. **Review humano obligatorio** antes de publicar cualquier cuento.
4. Solo usar Gemini en ingesta (no en runtime), por lo que el contenido generado pasa por QA.

**Plan de contingencia**:
- Si Gemini falla consistentemente, migrar a GPT-4 o Claude con mejores safety filters.
- Última opción: contratar traductores y educadores humanos.

### R9 — Bug crítico en producción que afecta a niños

**Contexto**: apps infantiles son particularmente sensibles. Un bug que muestre contenido inapropiado o falle en medio de un cuento puede generar mala prensa rápida.

**Plan de mitigación**:
1. CI estricto con cobertura mínima.
2. Feature flags para hacer rollback remoto sin update de app.
3. Crashlytics con alertas en tiempo real.
4. Equipo on-call para responder a incidentes en <4h.

**Plan de contingencia**:
- Hotfix en <24h.
- Si el bug afecta contenido (inapropiado),_REMOTE_CONFIG para desactivar el cuento afectado inmediatamente.
- Comunicación proactiva a padres por email.

---

## 4. Riesgos regulatorios a monitorear continuamente

| Regulación | Ámbito | Impacto en StoryEnglish |
|-------------|--------|-------------------------|
| COPPA | EE.UU. | Crítico - ya cubierto |
| GDPR-K | UE | Crítico - ya cubierto |
| Ley 25.326 | Argentina | Aplica - adaptar consentimiento |
| LGPD | Brasil | Aplica - simil GDPR |
| California Age-Appropriate Design Code | California, EE.UU. | Aplica - simil GDPR-K |
| UK Age Appropriate Design Code | Reino Unido | Aplica - simil GDPR-K |
| PIPL | China | No aplica (no lanzamos en China inicialmente) |

**Monitoreo**: suscribirse a boletines de [Future of Privacy Forum](https://fpf.org/) y [IAPP](https://iapp.org/). Revisión trimestral de compliance.

---

## 5. Riesgos de contenido

### 5.1 Copyright

Todos los cuentos deben ser de dominio público comprobable. Sources:
- [Project Gutenberg](https://www.gutenberg.org/) - verificado, con disclaimer claro
- [Wikisource](https://wikisource.org/) - verificado
- Aesop's Fables - dominio público (más de 2000 años)
- Mother Goose nursery rhymes - dominio público
- Brothers Grimm - dominio público (más de 100 años)

**No usar**:
- Cuentos modernos (Dr. Seuss, Disney, etc.) - copyright activo
- Adaptaciones modernas de cuentos clásicos que tengan copyright sobre la adaptación
- Cuentos de autores contemporáneos sin licencia explícita

### 5.2 Calidad de traducciones

Gemini puede traducir, pero:
- Traducciones literales pierden ritmo y rima.
- Modismos en inglés no siempre tienen equivalente en español.

**Mitigación**:
1. Review humano bilingüe.
2. Para cuentos con rima, considerar reescribir en español (no traducir literal).
3. Documentar decisiones de traducción en el doc del cuento.

### 5.3 Contenido sensible en cuentos clásicos

Muchos cuentos clásicos tienen elementos problemáticos para estándares modernos:
- Caperucita Roja: el lobo se come a la abuela
- Hansel y Gretel: abandono infantil, brujas
- Blancanieves: envenenamiento

**Mitigación**:
1. **Suavizar** elementos violentos en la adaptación (no eliminar, pero reducir intensidad).
2. Etiquetar cuentos con "contiene elementos que pueden asustar a niños pequeños".
3. Padre puede bloquear cuentos por categoría (incluida "cuentos con conflictos").
4. Para los más pequeños (2-4), priorizar nursery rhymes y cuentos simples sin conflictos fuertes.

---

## 6. Riesgos operacionales

### 6.1 Pérdida de cuenta de Firebase/Google Cloud

- **Probabilidad**: baja (2)
- **Impacto**: alto (5) - app completa fuera
- **Mitigación**: 2da cuenta de Google con permisos admin. Backups diarios.
- **Contingencia**: Migrar a cuenta backup. Comunicar a usuarios.

### 6.2 Pérdida de cuenta de Google Play o App Store

- **Probabilidad**: baja (1)
- **Impacto**: crítico (5) - sin canal de distribución
- **Mitigación**: cumplir policies estrictamente. Tener relación con developer relations de ambas stores.
- **Contingencia**: Migrar a web app (Flutter Web) con distribución directa.

### 6.3 Pérdida de acceso a Gemini API

- **Probabilidad**: baja (2)
- **Impacto**: medio (3) - no se puede cargar contenido nuevo
- **Mitigación**: mantener backup de prompts. No depender de features experimentales.
- **Contingencia**: migrar a OpenAI o Anthropic.

---

## 7. Riesgos de equipo

### 7.1依赖 de un único desarrollador

Si el dev principal se va, el conocimiento se va con él.

**Mitigación**:
- Documentación exhaustiva (este doc).
- Pair programming en funciones críticas.
- Code reviews en todos los PRs (aunque sea self-review detallado).
- Grabar Loom de decisiones arquitecturales.

### 7.2 Turnover de diseñador

Diseño es crítico para una app infantil. Si el designer se va, continuidad visual se pierde.

**Mitigación**:
- Design system documentado (colores, tipografías, componentes).
- Componentes reutilizables en Figma.
- Decisiones de diseño documentadas.

---

## 8. Revisión y actualización

Esta matriz se revisa:
- **Mensualmente** durante Fases 0-3 (desarrollo).
- **Trimestralmente** post-launch.
- **Inmediatamente** ante cualquier incidente o cambio regulatorio relevante.

Responsable: PM + Tech Lead.

---

## 9. Top 5 riesgos a vigilar en el día a día

1. **R1**: Apple Kids Category - mantenerse en compliance continuo.
2. **R8**: Conversión free → paid - monitorear semanalmente post-launch.
3. **R2**: Costos Firestore - dashboard semanal.
4. **R7**: Engagement de niños - encuestas mensuales a padres.
5. **R6**: Calidad de contenido generado por Gemini - QA de cada cuento.
