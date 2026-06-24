import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../child_profile/presentation/controllers/child_profile_controller.dart';
import 'controllers/onboarding_controller.dart';

/// Provider del [OnboardingController].
///
/// Depende de [childProfileControllerProvider] para crear el perfil al
/// finalizar el flujo.
final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, OnboardingState>(
        (ref) {
  final childController =
      ref.watch(childProfileControllerProvider.notifier);
  return OnboardingController(childProfileController: childController);
});
