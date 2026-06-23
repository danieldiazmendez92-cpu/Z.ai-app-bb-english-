# 07 — Estimación de costos

> Cuánto cuesta mantener StoryEnglish Kids en producción según escala de usuarios. Todos los precios en USD, basados en pricing público a junio 2026.

---

## 1. Resumen ejecutivo

| Usuarios activos/mes | Costo Firebase + APIs | Costo por usuario | Ingreso estimado (10% paid) | Margen |
|----------------------|----------------------|-------------------|------------------------------|--------|
| 1.000 | ~$80 | $0.08 | $300 | $220 |
| 10.000 | ~$450 | $0.045 | $3.000 | $2.550 |
| 100.000 | ~$3.200 | $0.032 | $30.000 | $26.800 |
| 1.000.000 | ~$28.000 | $0.028 | $300.000 | $272.000 |

> Asumimos 10% de usuarios free convierten a paid, ARPU $3/mes (mix mensual+anual). Ver `08-monetization.md` para el detalle del modelo.

**Conclusión**: el negocio es unitariamente rentable desde 1K usuarios. El costo principal es Firestore reads, que se optimiza con caching agresivo y denormalización.

---

## 2. Firebase Firestore

Pricing Blaze plan (pay-as-you-go).

| Operación | Costo |
|-----------|-------|
| Read | $0.036 / 100K = $0.00000036 por read |
| Write | $0.108 / 100K |
| Delete | $0.012 / 100K |
| Storage | $0.108 / GB / mes |

### Estimación de reads por usuario activo / mes

| Actividad | Reads estimados |
|-----------|-----------------|
| Abrir app (carga home + library cache) | 50 |
| Abrir Library (con cache) | 30 |
| Abrir Story Detail | 15 |
| Leer cuento completo (sections + vocab + progress updates) | 40 |
| Pantalla Progress (cuentos leídos + logros) | 20 |
| Pantalla Parent Dashboard | 25 |
| **Total por usuario activo / mes** (asumimos 8 sesiones/mes, 2 cuentos leídos/sesión) | ~700 reads |

### Costos por escala

| Usuarios | Reads/mes | Costo reads | Writes/mes | Costo writes | Storage | **Subtotal** |
|----------|-----------|-------------|-------------|--------------|---------|--------------|
| 1.000 | 700K | $0.25 | 100K | $0.11 | 100 MB | **~$1** |
| 10.000 | 7M | $2.52 | 1M | $1.08 | 500 MB | **~$5** |
| 100.000 | 70M | $25.20 | 10M | $10.80 | 2 GB | **~$40** |
| 1.000.000 | 700M | $252 | 100M | $108 | 10 GB | **~$365** |

> Firestore es muy barato. El verdadero costo está en Cloud Storage (audio MP3) y Cloud Functions.

---

## 3. Firebase Cloud Storage

Pricing:
- Storage: $0.026 / GB / mes
- Bandwidth (download): $0.12 / GB

### Estimación de uso

- Tamaño promedio de audio MP3 por cuento: 5 MB (cuento de 5 min @ 128kbps)
- Tamaño promedio de imágenes por cuento: 2 MB (portada + 5 ilustraciones)
- Total por cuento: ~7 MB

| Usuarios activos | Cuentos leídos/mes | Download GB | Costo download | Storage total | Costo storage | **Subtotal** |
|------------------|---------------------|-------------|----------------|---------------|---------------|--------------|
| 1.000 | 4.000 | 28 GB | $3.36 | 1 GB (170 cuentos) | $0.03 | **~$4** |
| 10.000 | 40.000 | 280 GB | $33.60 | 1 GB | $0.03 | **~$34** |
| 100.000 | 400.000 | 2.8 TB | $336 | 2 GB | $0.05 | **~$336** |
| 1.000.000 | 4.000.000 | 28 TB | $3.360 | 5 GB | $0.13 | **~$3.360** |

> Cloudflare CDN o Firebase Cloud Storage CDN puede reducir costos de bandwidth en ~50% para 100K+ usuarios. Recomendado a partir de Fase 4.

---

## 4. Firebase Cloud Functions

Pricing:
- Invocaciones: $0.40 / millón
- Compute time: $0.0025 / GHz-segundo
- Memoria: varía según configuración

### Funciones y frecuencia estimada

| Función | Frecuencia | GHz-s por invocación |
|---------|------------|----------------------|
| `onUserCreate` | 1 por signup | 0.1 |
| `verifyParental` | 1.1 por signup | 0.05 |
| `onChildCreate` | 1.2 por signup | 0.1 |
| `updateProgress` (trigger) | 8 por usuario/mes | 0.05 |
| `onStoryCompleted` | 2 por usuario/mes | 0.2 |
| `achievementEngine` | 2 por usuario/mes | 0.3 |
| `validatePlayReceipt` / `validateAppStoreReceipt` | 0.1 por paid user/mes | 0.5 |
| `playWebhook` / `appStoreWebhook` | 0.1 por paid user/mes | 0.2 |
| `recordAnalyticsEvent` (batched) | 100 por usuario/mes | 0.01 |
| `coppaCleanup` (cron) | diario | 1 |

### Costos por escala

| Usuarios | Invocaciones/mes | Costo invocaciones | Compute GHz-s/mes | Costo compute | **Subtotal** |
|----------|-------------------|--------------------|--------------------|---------------|--------------|
| 1.000 | 120K | $0.05 | 50K | $0.13 | **~$0.20** |
| 10.000 | 1.2M | $0.48 | 500K | $1.25 | **~$2** |
| 100.000 | 12M | $4.80 | 5M | $12.50 | **~$17** |
| 1.000.000 | 120M | $48 | 50M | $125 | **~$175** |

> Costo bajo. Las Cloud Functions no son el bottleneck.

---

## 5. Firebase Auth

**Gratis** hasta 50K MAU (Monthly Active Users) en authenticaciones. Después:

| MAU excedente | Costo |
|---------------|-------|
| 50K-1M | $0.01 / MAU |
| 1M-10M | $0.005 / MAU |

| Usuarios activos | Costo Auth/mes |
|------------------|----------------|
| 1.000 | $0 (free tier) |
| 10.000 | $0 |
| 100.000 | $0.50 |
| 1.000.000 | $9.50 |

---

## 6. Google Gemini API

Pricing Gemini 1.5 Flash (modelo recomendado para tareas de glosario y traducción):

| Tipo | Costo |
|------|-------|
| Input | $0.075 / 1M tokens |
| Output | $0.30 / 1M tokens |

### Uso

Gemini **solo se usa en ingesta de cuentos** (no en runtime). Por cuento ingestado:
- Input: ~3K tokens (texto del cuento + prompt)
- Output: ~2K tokens (glosario + traducción + 3 preguntas)

**Costo por cuento**: ($0.075 × 3 + $0.30 × 2) / 1000 = **~$0.0008 por cuento**

Para 200 cuentos en catálogo: **~$0.16** (one-time).

**No es un costo recurrente significativo.** Si en el futuro se usa Gemini en runtime (ej: respuestas a preguntas libres del niño), recalcular.

---

## 7. Google Text-to-Speech API

Pricing (voces Neural2):

| Caracter | Costo |
|----------|-------|
| Por 1M caracteres procesados | $16 |

### Uso por cuento

Cuento promedio: 500 palabras × 5 caracteres = 2.500 caracteres.

**Costo por cuento**: $16 × 2500 / 1M = **$0.04 por cuento**

Para 200 cuentos: **~$8 one-time**.

Si se usa runtime (no recomendado en MVP), multiplicar por número de lecturas.

---

## 8. Otros costos Firebase

| Servicio | Costo estimado |
|----------|----------------|
| Firebase Analytics | **Gratis** |
| Crashlytics | **Gratis** |
| Remote Config | **Gratis** |
| App Check | **Gratis** |
| Cloud Messaging (FCM) | **Gratis** |
| Performance Monitoring | **Gratis** |
| Test Lab | 10 dispositivos físicos/día gratis, después $5/hora |

---

## 9. Resumen por escala

| Componente | 1K users | 10K | 100K | 1M |
|------------|----------|-----|------|-----|
| Firestore | $1 | $5 | $40 | $365 |
| Storage (bandwidth) | $4 | $34 | $336 | $3.360 |
| Cloud Functions | $0.20 | $2 | $17 | $175 |
| Firebase Auth | $0 | $0 | $0.50 | $9.50 |
| Gemini (amortizado) | $0.05 | $0.05 | $0.05 | $0.05 |
| TTS (amortizado) | $2 | $2 | $2 | $2 |
| Otros | $1 | $5 | $20 | $100 |
| **TOTAL / mes** | **~$8** | **~$48** | **~$416** | **~$4.012** |

> Actualizado con mejoras de optimización (caching CDN, denormalización) en Fase 4:

| Componente | 1K (optimizado) | 10K | 100K | 1M |
|------------|------------------|-----|------|-----|
| Firestore | $1 | $5 | $30 | $250 |
| Storage (con CDN) | $4 | $25 | $200 | $2.000 |
| Cloud Functions | $0.20 | $2 | $15 | $150 |
| Auth | $0 | $0 | $0.50 | $9.50 |
| Otros | $1 | $5 | $15 | $80 |
| **TOTAL optimizado** | **~$6** | **~$37** | **~$260** | **~$2.490** |

---

## 10. Recomendaciones de optimización

### 10.1 Firestore (el mayor ahorro está aquí)

1. **Caching agresivo en cliente** con Hive (catálogo de cuentos, logros, categorías). TTL 7 días.
2. **Denormalización controlada** de `story_title` y `cover_url` en `user_progress` (ver `04-firestore-schema.md`).
3. **Queries con índices compuestos** para evitar full scans.
4. **Paginación** en lists largas (cuentos leídos, sesiones de lectura).
5. **Batch writes** para progress updates (no escribir cada 1s, escribir cada 10s).
6. **TTL policies** en `analytics_events` (90 días) y `reading_sessions` (90 días → BigQuery).

### 10.2 Cloud Storage

1. **Habilitar CDN** a partir de 10K usuarios (reduce bandwidth ~50%).
2. **Compresión WebP** para imágenes (ahorra 30-50% tamaño).
3. **HTTP cache headers** agresivos en binarios (cuentos casi nunca cambian).
4. **Lazy loading** de imágenes en grid.
5. **No descargar audio hasta que el usuario abra el cuento** (no precargar).

### 10.3 Cloud Functions

1. **Min instances = 1** solo para funciones críticas (billing validation).
2. **Max instances** para evitar picos de costo en funciones que reciben webhooks.
3. **Idempotency** en todas las funciones triggered por webhooks.
4. **Evitar cold starts** con funciones pequeñas y rápidas.

### 10.4 Monitoring de costos

1. **Budget alerts** en Google Cloud Console (alerta a $50, $200, $1K, $5K).
2. **Dashboard de costo por servicio** actualizado semanalmente.
3. **Audit de reads/writes** con logs: si un usuario hace >10K reads/día, investigar (bug o abuso).

---

## 11. Costos no-Firebase

| Item | Costo |
|------|-------|
| Google Play Console (one-time) | $25 |
| Apple Developer Program (anual) | $99/año |
| Dominio web (storyenglishkids.com) | $15/año |
| Email transactional (SendGrid/Postmark) | $20/mes (10K emails) |
| Monitoring externo (Sentry opcional) | $26/mes |
| Mascota / ilustraciones custom (one-time) | $500-$2K |

---

## 12. Break-even analysis

Con modelo freemium (10% conversión a paid, ARPU $3/mes):

| Usuarios activos | Ingresos | Costos | Resultado |
|------------------|----------|--------|-----------|
| 1.000 | $300 | $8 | +$292 |
| 10.000 | $3.000 | $48 | +$2.952 |
| 100.000 | $30.000 | $260 | +$29.740 |
| 1.000.000 | $300.000 | $2.490 | +$297.510 |

> A 10% de conversión, el break-even es ~250 usuarios. A 5% conversión, ~500 usuarios. A 2% conversión, ~1.250 usuarios.

**Conclusión**: el modelo es saludable. El verdadero riesgo no es costo, sino **adquisición de usuarios** (CAC).
