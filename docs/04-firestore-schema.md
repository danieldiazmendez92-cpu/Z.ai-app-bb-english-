# 04 — Esquema de Firestore

> Detalle técnico de cada colección: campos, tipos, índices compuestos, y estrategias de denormalización.

---

## 1. Visión general

Firestore es la base de datos NoSQL principal. Es **eventually consistent** entre colecciones y **strongly consistent** dentro de un documento y sus subcolecciones.

La regla de oro para diseñar el esquema es: **modelar los datos según los queries que necesitamos hacer**, no según relaciones "ideales". Esto se llama "NoSQL data modeling" y requiere desnormalizar en algunos casos.

### Colecciones del sistema

| Colección | Tipo | Volumen estimado | TTL |
|-----------|------|------------------|-----|
| `users` | Raíz | 1 por usuario | Sin TTL |
| `children_profiles` | Raíz | 1-4 por usuario | Soft delete + 30 días |
| `parental_settings` | Raíz | 1 por usuario | Sin TTL |
| `subscriptions` | Raíz | 1 por suscripción activa | Sin TTL (histórico) |
| `stories` | Raíz | ~100-500 (catálogo) | Sin TTL |
| `categories` | Raíz | ~20 | Sin TTL |
| `achievements` | Raíz | ~30 | Sin TTL |
| `user_progress` | Raíz | 1 por niño×cuento leído | Sin TTL |
| `user_achievements` | Raíz | 1 por niño×logro | Sin TTL |
| `reading_sessions` | Raíz | Muchas (alta escritura) | 90 días → archive a BigQuery |
| `analytics_events` | Raíz | Muchas | 90 días (Firestore TTL) |
| `stories/{id}/story_sections` | Subcolección | 5-15 por cuento | Sin TTL |
| `stories/{id}/vocabulary` | Subcolección | 5-20 por cuento | Sin TTL |
| `stories/{id}/comprehension_questions` | Subcolección | 3-5 por cuento | Sin TTL |

---

## 2. Colección `users`

```typescript
// Document: users/{uid}
{
  uid: string,                    // Firebase Auth UID (igual al doc ID)
  email: string,                  // Lowercase
  display_name: string | null,
  auth_provider: 'email' | 'google' | 'apple',
  parental_verified_at: Timestamp | null,
  is_premium: boolean,            // Sincronizado desde subscriptions
  premium_expires_at: Timestamp | null,
  created_at: Timestamp,
  updated_at: Timestamp,
}
```

**Reglas de validación (en Cloud Functions)**:
- `email` lowercase obligatorio.
- Si `is_premium = true`, debe existir documento en `subscriptions` con `status = 'active'` para este `uid`.
- `parental_verified_at` solo se puede setear una vez (no se puede "des-verificar").

**Índices**: ninguno compuesto necesario. Búsquedas por `uid` (PK) cubren todos los casos.

---

## 3. Colección `children_profiles`

```typescript
// Document: children_profiles/{childId}
{
  child_id: string,               // = doc ID
  user_uid: string,               // FK a users.uid
  name: string,                   // Solo primer nombre o apodo (COPPA)
  age: number,                    // 2-7
  avatar_url: string,             // Storage URL o asset path
  interests: string[],            // ['animals', 'adventure', ...]
  created_at: Timestamp,
  last_active_at: Timestamp | null,
  deleted_at: Timestamp | null,   // Soft delete
}
```

**Índices compuestos**:
- `user_uid` ASC + `deleted_at` ASC + `last_active_at` DESC
  - Query: "dame los perfiles activos de este padre ordenados por uso reciente"

**Validaciones**:
- Máximo 4 perfiles por `user_uid` (enforced por Cloud Function).
- `age` entre 2 y 7.
- `name` longitud 1-20, sin caracteres especiales.

---

## 4. Colección `parental_settings`

```typescript
// Document: parental_settings/{userUid}
{
  user_uid: string,               // = doc ID
  daily_limit_minutes: number,    // 0 = sin límite
  blocked_categories: string[],
  allow_offline_download: boolean,
  allow_analytics: boolean,       // Default false (COPPA opt-in)
  allow_personalized_ads: boolean, // Siempre false (COPPA)
  bedtime_start: string | null,   // '20:00' (formato HH:mm)
  bedtime_end: string | null,     // '07:00'
}
```

**Validaciones**:
- `daily_limit_minutes` entre 0 y 480 (8 horas max).
- `bedtime_start` y `bedtime_end` formato `HH:mm`.

---

## 5. Colección `subscriptions`

```typescript
// Document: subscriptions/{subscriptionId}
// subscriptionId = '{userUid}_{platform}'
{
  subscription_id: string,        // = doc ID
  user_uid: string,
  plan: 'monthly' | 'annual',
  platform: 'android' | 'ios',
  store_product_id: string,       // SKU en la store
  started_at: Timestamp,
  expires_at: Timestamp,
  auto_renew: boolean,
  status: 'active' | 'expired' | 'canceled' | 'grace_period',
  last_receipt_id: string | null,
  canceled_at: Timestamp | null,
}
```

**Índices compuestos**:
- `user_uid` ASC + `status` ASC + `expires_at` DESC
  - Query: "suscripción activa más reciente de este usuario"

**Webhooks**:
- Google Play Real-time Developer Notifications → Cloud Function `playWebhook`
- App Store Server Notifications V2 → Cloud Function `appStoreWebhook`

Ambos actualizan este documento y disparan sincronización de `users.is_premium`.

---

## 6. Colección `stories`

```typescript
// Document: stories/{storyId}
{
  story_id: string,               // = doc ID (slug: 'little-red-riding-hood')
  title: string,                  // 'Little Red Riding Hood'
  category_id: string,            // FK a categories
  min_age: number,                // 2
  max_age: number,                // 4
  duration_minutes: number,       // Estimado para audio TTS
  audio_url_en: string,           // Storage URL
  audio_url_es: string | null,
  timestamps_json_url: string | null,
  cover_image_url: string,
  source_attribution: string,     // 'Brothers Grimm, public domain'
  source_url: string,             // Project Gutenberg URL
  published: boolean,             // false hasta aprobación admin
  tags: string[],
  created_at: Timestamp,
  published_at: Timestamp | null,
  view_count: number,             // Denormalizado para sort popular
  avg_rating: number | null,      // Padres pueden calificar (futuro)
}
```

**Índices compuestos**:
- `published` ASC + `min_age` ASC + `category_id` ASC + `view_count` DESC
  - Query: "cuentos publicados para edad 4 en categoría animals, más vistos primero"
- `published` ASC + `tags` ASC + `created_at` DESC
  - Query: "cuentos nuevos con tag 'bedtime'"

---

## 7. Subcolección `stories/{storyId}/story_sections`

```typescript
// Document: stories/{storyId}/story_sections/{sectionId}
{
  section_id: string,
  story_id: string,               // = parent doc ID
  order: number,                  // 1, 2, 3...
  text_en: string,
  text_es: string,
  illustration_url: string | null,
}
```

**Índices compuestos**: ninguno (subcolección, no se querya por separado; siempre se trae todo el cuento).

**Estrategia**: cuando el niño abre un cuento, leemos todo el documento `stories/{storyId}` + todas sus secciones de una sola query `collection(stories/{id}/story_sections).orderBy('order')`. Una sola query, ~10 reads.

---

## 8. Subcolección `stories/{storyId}/vocabulary`

```typescript
// Document: stories/{storyId}/vocabulary/{wordId}
{
  word_id: string,
  story_id: string,
  word_en: string,
  word_es: string,
  phonetic: string | null,        // IPA: '/wʊlf/'
  example_sentence: string | null,
  example_translation: string | null,
  image_url: string | null,
  is_highlighted: boolean,        // Si true, se resalta en el texto
}
```

---

## 9. Subcolección `stories/{storyId}/comprehension_questions`

```typescript
// Document: stories/{storyId}/comprehension_questions/{questionId}
{
  question_id: string,
  story_id: string,
  question_text: string,
  options: string[],              // 4 opciones
  correct_index: number,          // 0-3
  explanation: string,
}
```

---

## 10. Colección `categories`

```typescript
// Document: categories/{categoryId}
{
  category_id: string,            // = doc ID (slug: 'animals')
  name: string,                   // 'Animals'
  name_es: string,                // 'Animales'
  icon_asset: string,             // 'assets/icons/animals.svg'
  description: string | null,
  order: number,                  // Para orden de display
}
```

---

## 11. Colección `achievements`

```typescript
// Document: achievements/{achievementId}
{
  achievement_id: string,         // = doc ID
  name: string,
  description: string,
  icon_url: string,               // Asset o Storage
  criteria_type: 'stories_completed' | 'streak_days' | 'words_learned' | 'categories_explored' | '...',
  criteria_threshold: number,
  is_hidden: boolean,             // Sorpresa hasta desbloquear
  xp_reward: number,              // Para leaderboard futuro
}
```

---

## 12. Colección `user_progress`

```typescript
// Document: user_progress/{childId}_{storyId}
{
  progress_id: string,            // = doc ID
  child_id: string,
  story_id: string,
  story_title: string,            // Denormalizado
  story_cover_url: string,        // Denormalizado
  completion_pct: number,         // 0-100
  time_spent_seconds: number,
  last_section_order: number,     // Reanudar aquí
  completed: boolean,
  completed_at: Timestamp | null,
  last_read_at: Timestamp,
  created_at: Timestamp,
}
```

**Índices compuestos**:
- `child_id` ASC + `last_read_at` DESC
  - Query: "continuar leyendo" (cuentos en progreso)
- `child_id` ASC + `completed` ASC + `completed_at` DESC
  - Query: "cuentos leídos" (completados)
- `child_id` ASC + `story_id` ASC (único, evita duplicados)

**Estrategia de actualización**:
- Cada 10 segundos durante la lectura, el cliente actualiza `completion_pct` y `time_spent_seconds`.
- Para no quemar writes, se hace batched write + debounce de 10s.
- Al terminar, `completed = true` y se dispara trigger de logros.

---

## 13. Colección `user_achievements`

```typescript
// Document: user_achievements/{childId}_{achievementId}
{
  user_achievement_id: string,    // = doc ID
  child_id: string,
  achievement_id: string,
  unlocked_at: Timestamp,
}
```

**Índices compuestos**:
- `child_id` ASC + `unlocked_at` DESC

---

## 14. Colección `reading_sessions`

```typescript
// Document: reading_sessions/{sessionId}
{
  session_id: string,             // = doc ID
  child_id: string,
  story_id: string,
  started_at: Timestamp,
  ended_at: Timestamp | null,
  duration_seconds: number,
  sections_read: number,
  completed: boolean,
}
```

**Índices compuestos**:
- `child_id` ASC + `started_at` DESC
- `started_at` ASC (agregaciones diarias)

**TTL**: 90 días. Después se mueve a BigQuery para analítica histórica (Cloud Function `archive_reading_sessions` corre diariamente).

---

## 15. Colección `analytics_events`

```typescript
// Document: analytics_events/{eventId}
{
  event_id: string,
  user_uid: string,
  child_id_hash: string | null,   // Hash del childId, no el real
  event_name: string,
  params: Map<string, any>,
  occurred_at: Timestamp,
}
```

**TTL**: 90 días (configurado en Firestore TTL policies).

**Eventos clave**:
- `app_open`
- `story_started` (params: `story_id`, `child_age`)
- `story_completed` (params: `story_id`, `duration_seconds`)
- `story_abandoned` (params: `story_id`, `last_section`)
- `vocabulary_lookup` (params: `word_id`)
- `achievement_unlocked` (params: `achievement_id`)
- `paywall_shown` (params: `trigger`)
- `subscription_started` (params: `plan`, `platform`)

---

## 16. Estrategia de denormalización

### 16.1 Cuándo denormalizar

**Regla**: si para renderizar una pantalla común necesito leer 2+ colecciones, denormalizo campos críticos.

**Ejemplo**: pantalla "Continuar leyendo" muestra una lista de `user_progress` con el título y portada del cuento. Sin denormalización: 1 read por `user_progress` + 1 read por `story` = N+1 reads. Con denormalización (`story_title`, `story_cover_url` en `user_progress`): 1 read.

### 16.2 Cuándo NO denormalizar

**Regla**: si el campo cambia frecuentemente, no lo denormalizo. Mantengo FK y hago el read.

**Ejemplo**: `view_count` de un cuento cambia mucho. No lo denormalizo en `user_progress`. Solo se lee cuando el usuario abre `story_detail_screen`, que es donde se necesita.

### 16.3 Mantenimiento de consistencia

Cuando se denormaliza, hay que mantener las copias sincronizadas. Lo hacemos con **Cloud Functions triggers**:

```typescript
// Cuando un cuento se actualiza, propagar a user_progress
functions.firestore
  .document('stories/{storyId}')
  .onUpdate(async (change, ctx) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.title !== after.title || before.cover_image_url !== after.cover_image_url) {
      const batch = db.batch();
      const progressSnap = await db.collection('user_progress')
        .where('story_id', '==', ctx.params.storyId)
        .get();
      progressSnap.forEach(doc => {
        batch.update(doc.ref, {
          story_title: after.title,
          story_cover_url: after.cover_image_url,
        });
      });
      await batch.commit();
    }
  });
```

---

## 17. Reglas de seguridad (resumen)

Las reglas completas están en `05-security-and-privacy.md`. Aquí el resumen por colección:

| Colección | Read | Write |
|-----------|------|-------|
| `users/{uid}` | Solo el propio uid | El propio uid puede crear/editar (no `is_premium`) |
| `children_profiles/{childId}` | Solo el padre dueño | Solo el padre dueño (soft delete mediante) |
| `parental_settings/{uid}` | Solo el propio uid | Solo el propio uid |
| `subscriptions/{subId}` | Solo el propio uid | Solo Cloud Functions (server-side) |
| `stories/{storyId}` | Público si `published = true` | Solo admin (custom claim) |
| `categories`, `achievements` | Público | Solo admin |
| `user_progress/{id}` | Solo el padre del niño | Solo el padre del niño |
| `user_achievements/{id}` | Solo el padre del niño | Solo Cloud Functions |
| `reading_sessions/{id}` | Solo el padre del niño | Solo el padre del niño |
| `analytics_events/{id}` | Solo admin | Cualquiera autenticado (con rate limiting) |

---

## 18. Costos estimados

Ver `07-costs.md` para el detalle. Resumen rápido:

- **1K usuarios activos**: ~$50-80/mes en Firestore
- **10K usuarios activos**: ~$300-500/mes
- **100K usuarios activos**: ~$2K-4K/mes

Los reads son el 80% del costo. Optimizar reads con denormalización + caching agresivo es la palanca principal de ahorro.
