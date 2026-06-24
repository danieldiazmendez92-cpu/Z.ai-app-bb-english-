// =============================================================================
// main_dev.dart - Entry point flavor DEV
// -----------------------------------------------------------------------------
// Ejecutar con:
//   flutter run --flavor dev -t lib/main_dev.dart
// =============================================================================

import 'package:flutter/widgets.dart';

import 'main.dart';

/// Entry point para el flavor `dev`.
///
/// Usa el Firebase project de desarrollo (config en FirebaseConfig.optionsFor('dev')).
Future<void> main() async {
  await initializeApp(flavor: 'dev');
  runApp(const StoryEnglishApp());
}
