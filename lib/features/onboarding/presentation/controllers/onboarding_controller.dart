import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import 'package:storyenglish_kids/features/child_profile/presentation/controllers/child_profile_controller.dart';

/// Estado del flujo de onboarding (4 pantallas).
class OnboardingState {
  const OnboardingState({
    this.step = 0,
    this.avatarUrl,
    this.age,
    this.interests = const [],
    this.isCreating = false,
    this.failure,
  });

  /// Step actual: 0=welcome, 1=avatar, 2=age, 3=interests
  final int step;

  /// Avatar elegido (emoji o asset path).
  final String? avatarUrl;

  /// Edad elegida (2-7).
  final int? age;

  /// Intereses seleccionados.
  final List<String> interests;

  /// True mientras se crea el perfil en Firestore.
  final bool isCreating;

  /// Error de la última operación.
  final Failure? failure;

  OnboardingState copyWith({
    int? step,
    String? avatarUrl,
    int? age,
    List<String>? interests,
    bool? isCreating,
    Failure? failure,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      isCreating: isCreating ?? this.isCreating,
      failure: failure,
    );
  }

  /// True si el estado actual permite avanzar al siguiente step.
  bool get canProceed {
    switch (step) {
      case 1:
        return avatarUrl != null;
      case 2:
        return age != null;
      case 3:
        return interests.isNotEmpty;
      default:
        return true;
    }
  }
}

/// Controller que orquesta el flujo de onboarding de 4 pantallas.
///
/// Flujo:
/// 1. Welcome → botón "Empezar"
/// 2. PickAvatar → elige un avatar
/// 3. PickAge → elige la edad
/// 4. PickInterests → elige intereses (mín 1)
/// 5. `finish()` → llama a `childProfileController.createChild()`
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController({required this.childProfileController})
      : super(const OnboardingState());

  final ChildProfileController childProfileController;

  /// Inicia el flujo de onboarding (desde WelcomeScreen).
  void startOnboarding() {
    state = state.copyWith(step: 1);
  }

  /// Avanza al siguiente step.
  void nextStep() {
    if (state.canProceed) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  /// Vuelve al step anterior.
  void prevStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  /// Setea el avatar elegido.
  void setAvatar(String avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
  }

  /// Setea la edad elegida.
  void setAge(int age) {
    state = state.copyWith(age: age);
  }

  /// Toggle de un interés. Si ya está seleccionado, lo quita.
  void toggleInterest(String interestId) {
    final interests = List<String>.from(state.interests);
    if (interests.contains(interestId)) {
      interests.remove(interestId);
    } else {
      interests.add(interestId);
    }
    state = state.copyWith(interests: interests);
  }

  /// Finaliza el onboarding y crea el perfil del niño.
  ///
  /// Devuelve `true` si se creó exitosamente, `false` si falló.
  Future<bool> finish() async {
    if (state.avatarUrl == null ||
        state.age == null ||
        state.interests.isEmpty) {
      state = state.copyWith(
        failure: const ValidationFailure(
            'Faltan datos: avatar, edad o intereses'),
      );
      return false;
    }

    state = state.copyWith(isCreating: true, failure: null);

    try {
      await childProfileController.createChild(
        name: _generateDefaultName(),
        age: state.age!,
        avatarUrl: state.avatarUrl!,
        interests: state.interests,
      );

      state = state.copyWith(isCreating: false);
      return true;
    } on Failure catch (e) {
      state = state.copyWith(isCreating: false, failure: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        failure: UnknownFailure(e.toString()),
      );
      return false;
    }
  }

  /// Genera un nombre default para el niño. El padre puede cambiarlo después.
  /// Por ahora usamos "Niño" como placeholder. En el futuro, podríamos
  /// pedirle el nombre en una pantalla adicional.
  String _generateDefaultName() {
    return 'Niño';
  }

  /// Resetea el controller (para reintentar).
  void reset() {
    state = const OnboardingState();
  }
}

// ============================================================
// Provider
// ============================================================

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(
    childProfileController:
        ref.watch(childProfileControllerProvider.notifier),
  );
});
