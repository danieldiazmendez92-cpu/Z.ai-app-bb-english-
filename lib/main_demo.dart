// =============================================================================
// main_demo.dart - Entry point para Demo Mode
// -----------------------------------------------------------------------------
// Corre la app SIN Firebase, usando implementaciones en memoria.
//
// Cómo correr:
//   flutter run -t lib/main_demo.dart
//
// Características del demo:
//   - Auth: cualquier email/password funciona
//   - Signup auto-verifica parental (sin math challenge)
//   - 1 hijo precreado: "Sofi" (4 años, 🦊, interests: animals/adventure/bedtime)
//   - 5 cuentos de Gutenberg con secciones, vocabulario, preguntas
//   - Audio simulado con Timer (resaltado funciona, sin MP3 real)
//   - Stats preconfiguradas: 2 cuentos leídos, 1 logro desbloqueado
//   - Billing: simula compra (no cobra de verdad)
//   - Privacy: export devuelve JSON de ejemplo
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart' show StoryEnglishApp;
import 'shared/providers/demo_overrides.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: demoOverrides,
      child: const StoryEnglishApp(),
    ),
  );
}
