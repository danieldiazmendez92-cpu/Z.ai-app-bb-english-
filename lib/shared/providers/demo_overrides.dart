// =============================================================================
// demo_overrides.dart - Overrides de providers para Demo Mode
// -----------------------------------------------------------------------------
// Reemplaza las implementaciones reales (Firebase) por DEMO (en memoria).
// Se usa en [main_demo.dart] con [ProviderScope(overrides: demoOverrides)].
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:storyenglish_kids/core/services/audio_player_service.dart';
import 'package:storyenglish_kids/core/services/demo_audio_player_service.dart';
import 'package:storyenglish_kids/features/auth/data/demo_auth_repository.dart';
import 'package:storyenglish_kids/features/auth/domain/repositories/auth_repository.dart';
import 'package:storyenglish_kids/features/child_profile/data/demo_child_profile_repository.dart';
import 'package:storyenglish_kids/features/child_profile/domain/repositories/child_profile_repository.dart';
import 'package:storyenglish_kids/features/progress/data/demo_achievement_repository.dart';
import 'package:storyenglish_kids/features/progress/presentation/controllers/progress_controller.dart';
import 'package:storyenglish_kids/features/story/data/demo_story_repository.dart';
import 'package:storyenglish_kids/features/story/domain/repositories/story_repository.dart';
import 'package:storyenglish_kids/features/story/presentation/controllers/reader_controller.dart';
import 'package:storyenglish_kids/features/subscription/data/demo_billing_repository.dart';
import 'package:storyenglish_kids/features/subscription/domain/repositories/billing_repository.dart';
import 'package:storyenglish_kids/features/privacy/data/demo_privacy_repository.dart';
import 'package:storyenglish_kids/features/privacy/domain/repositories/privacy_repository.dart';
import 'package:storyenglish_kids/features/vocabulary/data/demo_learned_words_repository.dart';
import 'package:storyenglish_kids/features/vocabulary/presentation/controllers/vocabulary_review_controller.dart';
import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';

/// Instancia singleton del DemoAuthRepository.
final _demoAuthRepository = DemoAuthRepository();

/// Instancia singleton del DemoAchievementRepository.
/// Exportada para que se pueda llamar `unlockDemoAchievement` desde tests.
final demoAchievementRepository = DemoAchievementRepository();

/// Instancia singleton del DemoLearnedWordsRepository.
/// Pre-poblada con 10 palabras para que el repaso SRS tenga contenido.
final demoLearnedWordsRepository = DemoLearnedWordsRepository()..prepopulateDemo('demo-child-001');

/// Lista de overrides que reemplazan Firebase por implementaciones DEMO.
///
/// En demo mode:
/// - Auth: cualquier email/password funciona. Signup auto-verifica parental.
/// - Child Profile: precrea 1 hijo "Sofi" (4 años, intereses: animals/adventure/bedtime)
/// - Story: 5 cuentos de Gutenberg con secciones, vocab, preguntas
/// - Audio: simula reproducción con Timer (sin MP3 real)
/// - Billing: en memoria, no se puede comprar de verdad
/// - Privacy: en memoria, export devuelve JSON de ejemplo
List<Override> get demoOverrides => [
      // Auth
      authRepositoryProvider.overrideWithValue(_demoAuthRepository),

      // Child Profile (precrea 1 hijo "Sofi")
      childProfileRepositoryProvider.overrideWithValue(
        DemoChildProfileRepository(userUid: 'demo-user-001'),
      ),

      // Story
      storyRepositoryProvider.overrideWithValue(DemoStoryRepository()),

      // Audio Player (demo: simula reproducción con timer)
      audioPlayerServiceProvider
          .overrideWithValue(DemoAudioPlayerService()),

      // Achievements
      achievementRepositoryProvider
          .overrideWithValue(demoAchievementRepository),

      // Billing
      billingRepositoryProvider.overrideWithValue(DemoBillingRepository()),

      // Privacy
      privacyRepositoryProvider.overrideWithValue(DemoPrivacyRepository()),

      // Vocabulary (SRS) - pre-poblado con 10 palabras
      learnedWordsRepositoryProvider.overrideWithValue(demoLearnedWordsRepository),
    ];
