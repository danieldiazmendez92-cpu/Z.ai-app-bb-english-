# 10 — Accesibilidad

> Consideraciones de accesibilidad para que StoryEnglish Kids sea usable por niños con diferentes capacidades y contextos.

---

## 1. Por qué importa la accesibilidad

- **Ética**: una app educativa para niños debe ser inclusiva. Hay niños con discapacidades visuales, auditivas, motoras o cognitivas que merecen usarla.
- **Legal**: en muchos países, las apps educativas tienen requisitos de accesibilidad (ADA en EE.UU., EN 301 549 en UE).
- **Negocio**: amplía el mercado. Familias con niños con discapacidades son un segmento leal.
- **Calidad**: las prácticas de accesibilidad mejoran la UX para todos (ej: subtítulos de audio son útiles para niños aprendiendo a leer).

---

## 2. Estándares objetivo

- **WCAG 2.1 nivel AA** (Web Content Accessibility Guidelines). Es el estándar internacional.
- **Material Design accessibility guidelines** (Android).
- **Apple Human Interface Guidelines - Accessibility** (iOS).
- **COPPA + GDPR-K**: ya cubierto en `05-security-and-privacy.md`.

---

## 3. Tipos de discapacidad y cómo los atendemos

### 3.1 Discapacidad visual

| Necesidad | Implementación |
|-----------|----------------|
| **Lectores de pantalla (TalkBack/VoiceOver)** | Todos los widgets interactivos tienen `Semantics(label: ...)` descriptivo |
| **Alto contraste** | Tema con alto contraste alternativo (toggle en settings) |
| **Tamaño de texto grande** | `MediaQuery.textScaleFactor` soportado hasta 2.0 sin romper layout |
| **Bajo visión / daltonismo** | No usar solo color para transmitir información (siempre icono + texto + color) |
| **Tipografía legible** | Fuente principal Fredoka (lúdica pero legible). Opción OpenDyslexic para dislexia |

### 3.2 Discapacidad auditiva

| Necesidad | Implementación |
|-----------|----------------|
| **Subtítulos del audio narrado** | Texto en inglés + español sincronizado con audio (usamos el JSON de timestamps que ya tenemos) |
| **Alternativa visual al audio** | Animación de "ondas de sonido" cuando el audio está activo |
| **Vibración al inicio/fin de cuento** | `HapticFeedback` |
| **Transcripción completa** | Botón "ver transcripción" en Reader |

### 3.3 Discapacidad motriz

| Necesidad | Implementación |
|-----------|----------------|
| **Tap targets grandes** | Mínimo 48x48dp (recomendado 60x60dp para niños) |
| **Espaciado entre botones** | Mínimo 8dp entre botones adyacentes |
| **No swipe-only actions** | Toda acción accesible por tap (no requiere swipe fino) |
| **Soporte para switch control** | Semantics labels completos |
| **Dwell time** (opcional) | Para niños que no pueden tap rápido |

### 3.4 Discapacidad cognitiva

| Necesidad | Implementación |
|-----------|----------------|
| **Lenguaje simple** | Textos de UI en frases cortas, vocabulario básico |
| **Modo simplificado** | Opción "menos estímulos" en settings (desactiva animaciones complejas) |
| **Indicaciones claras** | Iconos + texto + color en todos los CTAs |
| **Predictibilidad** | Misma ubicación de botones en todas las pantallas |
| **Sin time pressure** | No hay timers en cuento regular. Solo en mini-juegos (futuro) |

---

## 4. Implementación técnica

### 4.1 Semantics

Todos los widgets interactivos deben tener `Semantics`:

```dart
Semantics(
  label: 'Botón de reproducir cuento',
  hint: 'Toca para empezar a escuchar el cuento',
  button: true,
  child: IconButton(
    icon: Icon(Icons.play_arrow),
    onPressed: onPlay,
  ),
)
```

Para imágenes:

```dart
Semantics(
  label: 'Ilustración de Caperucita Roja caminando por el bosque',
  image: true,
  child: Image.network(storySection.illustrationUrl),
)
```

### 4.2 Contraste de colores

Verificado con [WCAG Contrast Checker](https://webaim.org/resources/contrastchecker/).

**Paleta principal (debe cumplir AA)**:

| Elemento | Color fondo | Color texto | Ratio | ¿Cumple AA? |
|----------|-------------|-------------|-------|-------------|
| Botón primario | `#4A90E2` (azul) | `#FFFFFF` (blanco) | 4.5:1 | ✅ |
| Texto body | `#FFFFFF` (blanco) | `#333333` (gris oscuro) | 12.6:1 | ✅ |
| Texto secundario | `#FFFFFF` | `#666666` | 5.7:1 | ✅ |
| Link | `#FFFFFF` | `#1976D2` | 5.4:1 | ✅ |
| Botón danger | `#D32F2F` (rojo) | `#FFFFFF` | 5.9:1 | ✅ |

**Tema alto contraste** (opcional):
- Fondo: `#000000`
- Texto: `#FFFFFF`
- Acento: `#FFFF00` (amarillo)

### 4.3 Tamaño de texto escalable

Usar `flutter_screenutil` o pasar `MediaQuery.textScaler`:

```dart
Text(
  story.title,
  style: TextStyle(fontSize: 24.sp),
  // 24.sp se escala automáticamente con textScaleFactor
)
```

Validar que con `textScaleFactor = 2.0` no rompe layout (golden tests con ambas escalas).

### 4.4 Tap targets

```dart
// Helper widget
class SEIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 48, minHeight: 48),
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: IconButton(
          icon: Icon(icon, size: 32),  // Icono grande para niños
          onPressed: onPressed,
          padding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}
```

### 4.5 Subtítulos de audio

Aprovechamos el JSON de timestamps que ya generamos para sincronización. En el Reader:

```dart
class CaptionWidget extends StatelessWidget {
  final AudioTimestamp currentTimestamp;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          currentTimestamp.word,  // Palabra actual
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

Padre puede activar/desactivar subtítulos en settings.

### 4.6 Modo simplificado

```dart
final settings = ref.watch(accessibilitySettingsProvider);

AnimatedSwitcher(
  duration: settings.reducedMotion
    ? Duration.zero
    : Duration(milliseconds: 300),
  child: ...,
)
```

### 4.7 Soporte para OpenDyslexic

```dart
if (settings.useDyslexiaFont) {
  return TextStyle(fontFamily: 'OpenDyslexic');
} else {
  return TextStyle(fontFamily: 'Fredoka');
}
```

Fuente incluida en `assets/fonts/OpenDyslexic/`.

---

## 5. Auditoría de accesibilidad

### 5.1 Automated checks (en CI)

```dart
// test/accessibility_test.dart
testWidgets('all screens meet accessibility guidelines', (tester) async {
  final screens = [
    LoginScreen(),
    HomeScreen(),
    LibraryScreen(),
    ReaderScreen(),
    ParentDashboardScreen(),
    // ... todas las pantallas
  ];

  for (final screen in screens) {
    await tester.pumpWidget(MaterialApp(home: screen));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }
});
```

### 5.2 Manual checks (pre-release)

- [ ] Probar con TalkBack (Android) - navegar todo sin tocar pantalla visualmente
- [ ] Probar con VoiceOver (iOS) - idem
- [ ] Probar con texto escalado al 200%
- [ ] Probar con tema alto contraste
- [ ] Probar con subtítulos activados
- [ ] Probar con OpenDyslexic font
- [ ] Probar con switch control (iOS)
- [ ] Probar con Voice Access (Android)
- [ ] Probar en tablet con landscape
- [ ] Probar con audífonos (audio claro)

### 5.3 Auditoría externa

Antes del launch público, contratar una auditoría externa de accesibilidad (organización como [Level Access](https://levelaccess.com/) o similar). Costo: ~$3K-5K para una app de este tamaño.

---

## 6. Settings de accesibilidad

Pantalla dedicada en `Settings → Accesibilidad`:

```
Accesibilidad
├── Tamaño de texto          [A- ▮▮▮▮ A+]   (3 niveles)
├── Fuente dislexia-friendly  [☐]
├── Alto contraste            [☐]
├── Movimiento reducido       [☐]
├── Subtítulos de audio       [☑]  (default on para niños)
├── Vibración al feedback     [☑]
├── Volumen audio dedicado    [---▮---]  (independiente del sistema)
└── Modo simplificado         [☐]
```

Estos settings se guardan en `parental_settings.accessibility` (Map).

---

## 7. Casos especiales para niños

### 7.1 Sobre-estimulación

Algunos niños (ej: en espectro autista) son sensibles a estímulos. El **modo simplificado**:
- Desactiva animaciones complejas (mantén transiciones de 0ms o fades suaves)
- Reduce paleta de colores (menos saturación)
- Desactiva sonidos de feedback
- Desactiva celebraciones Lottie ruidosas (reemplaza por animación simple)

### 7.2 Tiempo de procesamiento

- Velocidad de narración ajustable (0.75x, 1x, 1.25x)
- Pausa automática entre secciones (configurable)
- Botón "repetir sección" siempre accesible

### 7.3 Errores sin fricción

- Si el niño responde mal una pregunta de comprensión, no se le dice "incorrecto". Se le dice "¡Sigamos intentando!" y se le da otra oportunidad.
- No hay timers en el flujo principal de lectura.

---

## 8. Recursos externos

- [WCAG 2.1 guidelines](https://www.w3.org/TR/WCAG21/)
- [Flutter accessibility documentation](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)
- [Apple HIG - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Material Design - Accessibility](https://m3.material.io/foundations/accessible-design/overview)
- [OpenDyslexic font](https://opendyslexic.org/)
- [Inclusive Design Toolkit (Microsoft)](https://www.microsoft.com/design/inclusive/)
