# 🎮 Demo Mode — Probar la app SIN Firebase

> **¿Querés ver la app funcionando en 5 minutos sin configurar nada?**
> Usá Demo Mode. No requiere Firebase, ni API keys, ni deploy.
> Solo Flutter instalado.

---

## ⚡ Quick start (5 minutos)

```bash
# 1. Clonar el repo
git clone https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-.git
cd Z.ai-app-bb-english-

# 2. Instalar dependencias
flutter pub get

# 3. Generar código (freezed + json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 4. Correr la app en Demo Mode
flutter run -t lib/main_demo.dart
```

¡Listo! La app abre en el emulador/dispositivo.

---

## 🎯 Qué vas a ver

### Login
- Cualquier email + password funciona (ej: `test@test.com` / `12345678`)
- O tocá "Continuar con Google" / "Continuar con Apple" (simulado, no abre nada real)
- El login demora ~500ms (simulado)

### Onboarding (omitido en demo)
- En demo mode, el signup **auto-verifica parental** (no pide math challenge)
- Y **precrea un hijo** llamado "Sofi" (4 años, 🦊)
- Por eso vas directo al Home

### Home
- "Continuar leyendo": 2 cuentos preconfigurados con progreso
- "Recomendados para vos": 5 cuentos basados en edad (4) e intereses

### Library
- 5 cuentos completos:
  - 👧 Little Red Riding Hood (4-7 años)
  - 🐷 The Three Little Pigs (3-7 años)
  - 🐻 Goldilocks and the Three Bears (3-6 años)
  - 🦆 The Ugly Duckling (5-7 años)
  - 🐢 The Tortoise and the Hare (2-6 años)
- Filtros por categoría y edad funcionan
- Búsqueda funciona

### Story Detail
- Portada + título + edad + duración
- Vocabulario destacado preview (3-4 palabras por cuento)
- Botón "Empezar a leer"

### Reader (lo más importante)
- Texto del cuento en inglés dividido en 3 secciones
- Tap "Play" → el audio "suena" (simulado, sin sonido real)
- La palabra actual se **resalta** sincronizadamente
- Tap en palabra destacada → popup con traducción
- Toggle "Ver traducción" → muestra texto en español al lado
- Controles: play/pause, seek, speed (0.75x/1x/1.25x/1.5x), rewind/forward 10s
- Navegación entre secciones (Anterior/Siguiente)
- Progreso se guarda cada 10s (en memoria)

### Story End
- Animación de celebración con confetti
- Pregunta de comprensión (4 opciones)
- Feedback inmediato (correcto/incorrecto + explicación)

### Progress (tab 3)
- Header con nivel + barra de progreso
- Stats: cuentos leídos (2), minutos (8), racha (1 día), palabras (16)
- Racha más larga: 3 días
- Categorías exploradas: 2
- Grid de 8 logros (1 desbloqueado: "First Steps" 👶)

### Parents (tab 4, PIN: `1234`)
- Teclado numérico de 4 dígitos
- Tras 3 intentos fallidos: bloqueo 30 segundos
- Dashboard: resumen semanal + bar chart + stats detalladas
- Controles parentales: límite diario (slider), bedtime, categorías bloqueadas
- Suscripción: ver plan actual (Free) → "Ver planes" → paywall
- Privacidad: consentimiento, exportar datos, eliminar cuenta

### Paywall (desde Parents → Suscripción)
- 6 beneficios listados
- Selector mensual vs anual (con badge "Ahorrá 33%")
- Toggle "7 días gratis"
- Tap "Empezar 7 días gratis" → simula compra (demora 2s) → premium activado

### Privacy Settings
- Toggles de analytics y personalización
- "Exportar todos mis datos" → genera JSON con datos de ejemplo
- "Eliminar mi cuenta" → doble confirmación (no borra nada de verdad)

---

## ⚠️ Limitaciones del Demo Mode

| Feature | Demo Mode | Firebase Real |
|---------|-----------|---------------|
| Auth email/password | ✅ Cualquiera funciona | ✅ Solo cuentas reales |
| Google/Apple sign-in | ✅ Simulado | ✅ Real |
| Verificación parental | ✅ Auto (skip) | ✅ Math challenge |
| Catálogo de cuentos | ✅ 5 cuentos hardcoded | ✅ Cargados vía script |
| Audio narrado | ⚠️ Simulado (sin sonido) | ✅ MP3 real (Google TTS) |
| Resaltado sincronizado | ✅ Funciona | ✅ Funciona |
| Progreso | ⚠️ En memoria (se pierde) | ✅ Persistente |
| Logros | ✅ 1 pre-desbloqueado | ✅ Se desbloquean con Cloud Function |
| Suscripción | ⚠️ Simulada | ✅ Billing real |
| Offline | ❌ No | ✅ Con descarga |
| Multi-dispositivo | ❌ No | ✅ Sync en la nube |

---

## 🛠️ Cómo funciona técnicamente

Demo Mode usa **Riverpod overrides** para reemplazar las implementaciones reales (Firebase) por implementaciones en memoria:

```dart
// lib/main_demo.dart
runApp(
  ProviderScope(
    overrides: demoOverrides,  // ← reemplaza Firebase por mocks
    child: const StoryEnglishApp(),
  ),
);
```

Los mocks implementan las mismas interfaces que los repos reales:
- `DemoAuthRepository` implementa `AuthRepository`
- `DemoStoryRepository` implementa `StoryRepository`
- `DemoChildProfileRepository` implementa `ChildProfileRepository`
- etc.

La UI no sabe si está hablando con Firebase o con un mock. Es transparente.

---

## 🔄 Cambiar entre Demo Mode y Firebase Real

### Demo Mode (sin Firebase)
```bash
flutter run -t lib/main_demo.dart
```

### Firebase Dev
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Firebase Prod
```bash
flutter run --flavor prod -t lib/main_prod.dart
```

> Para Firebase Dev/Prod necesitás configurar Firebase primero (ver sección siguiente).

---

## 🐛 Troubleshooting del Demo Mode

### "build_runner falla con errores"
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### "No se ven los cuentos"
- Asegurate de estar corriendo `flutter run -t lib/main_demo.dart` (no `main_dev.dart`)
- Si ves pantalla de login, logueate con cualquier email/password

### "El audio no suena"
- Es esperado. En demo mode el audio es **simulado** (sin sonido real)
- Lo que sí funciona: el resaltado de palabra actual mientras "suena"
- Para audio real, configurar Firebase + Google TTS (ver SETUP_FINAL.md)

### "Se reinician los datos al cerrar la app"
- Es esperado. Demo Mode guarda en memoria, no en Firestore
- Para persistencia, configurar Firebase real

### "Google/Apple login no abre nada"
- Es esperado. En demo mode son simulados
- Para login real, configurar Firebase Auth con Google/Apple providers

---

## ✅ Checklist Demo Mode

- [ ] Flutter instalado (`flutter --version` muestra 3.24+)
- [ ] Repo clonado
- [ ] `flutter pub get` corrió sin errores
- [ ] `dart run build_runner build` generó archivos `.freezed.dart` y `.g.dart`
- [ ] `flutter run -t lib/main_demo.dart` abre la app
- [ ] Login funciona con cualquier email/password
- [ ] Home muestra cuentos recomendados
- [ ] Library muestra 5 cuentos
- [ │ Reader reproduce (simulado) y resalta palabras
- [ ] Story End muestra celebración + pregunta
- [ ] Progress muestra stats y badges
- [ ] Parents (PIN 1234) muestra dashboard
- [ ] Paywall se puede "comprar" (simulado)
- [ ] Privacy export genera JSON

¡Listo! Ya probaste la app completa sin tocar Firebase. 🎉

---

## 📞 ¿Problemas?

Abrí un issue: https://github.com/danieldiazmendez92-cpu/Z.ai-app-bb-english-/issues

---

## ➡️ Siguiente paso

Cuando quieras probar con **datos reales** (audio narrado de verdad, persistencia, multi-dispositivo), seguí la guía completa en **[SETUP_FINAL.md](SETUP_FINAL.md)** para configurar Firebase.
