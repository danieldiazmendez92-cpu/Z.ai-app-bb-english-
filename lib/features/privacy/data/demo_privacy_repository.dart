import 'dart:convert';

import '../../domain/entities/consent_state.dart';
import '../../domain/repositories/privacy_repository.dart';

/// Repositorio de privacidad DEMO.
class DemoPrivacyRepository implements PrivacyRepository {
  ConsentState _consent = const ConsentState();

  @override
  Future<void> grantConsent(ConsentState consent) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _consent = consent;
  }

  @override
  Future<ConsentState> getConsent() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _consent;
  }

  @override
  Future<String> exportUserData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final data = {
      '_metadata': {
        'exported_at': DateTime.now().toIso8601String(),
        'app': 'StoryEnglish Kids (DEMO)',
        'version': '1.0',
      },
      'user': {
        'uid': 'demo-user-001',
        'email': 'demo@storyenglish.kids',
        'display_name': 'Demo Parent',
        'auth_provider': 'email',
        'parental_verified_at': DateTime.now().toIso8601String(),
        'is_premium': false,
      },
      'parental_settings': {
        'daily_limit_minutes': 30,
        'blocked_categories': [],
        'allow_offline_download': true,
        'allow_analytics': _consent.analytics,
        'allow_personalized_ads': false,
      },
      'user_consents': {
        'necessary': true,
        'analytics': _consent.analytics,
        'personalization': _consent.personalization,
      },
      'children_profiles': [
        {
          'child_id': 'demo-child-001',
          'name': 'Sofi',
          'age': 4,
          'avatar_url': '🦊',
          'interests': ['animals', 'adventure', 'bedtime'],
        }
      ],
      'user_progress': [
        {
          'story_id': 'three-little-pigs',
          'story_title': 'The Three Little Pigs',
          'completion_pct': 100,
          'completed': true,
        },
        {
          'story_id': 'goldilocks',
          'story_title': 'Goldilocks and the Three Bears',
          'completion_pct': 100,
          'completed': true,
        },
      ],
      'user_achievements': [
        {
          'achievement_id': 'first_story',
          'unlocked_at': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        }
      ],
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    // En demo, no borra nada de verdad. Solo simula.
  }
}
