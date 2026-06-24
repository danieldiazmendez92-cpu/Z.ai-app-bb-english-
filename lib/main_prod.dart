// =============================================================================
// main_prod.dart - Entry point flavor PROD
// -----------------------------------------------------------------------------
// Ejecutar con:
//   flutter run --flavor prod -t lib/main_prod.dart
//   flutter build appbundle --flavor prod -t lib/main_prod.dart
//   flutter build ipa --flavor prod -t lib/main_prod.dart
// =============================================================================

import 'package:flutter/widgets.dart';

import 'main.dart';

/// Entry point para el flavor `prod`.
///
/// Usa el Firebase project de produccion (config en FirebaseConfig.optionsFor('prod')).
Future<void> main() async {
  await initializeApp(flavor: 'prod');
  runApp(const StoryEnglishApp());
}
