import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/privacy_repository_impl.dart';
import '../../domain/entities/consent_state.dart';
import '../../domain/repositories/privacy_repository.dart';
import 'package:storyenglish_kids/shared/providers/auth_provider.dart';

/// Estado de privacidad.
class PrivacyState {
  const PrivacyState({
    this.consent = const ConsentState(),
    this.isExporting = false,
    this.isDeleting = false,
    this.exportedJson,
    this.failure,
    this.accountDeleted = false,
  });

  final ConsentState consent;
  final bool isExporting;
  final bool isDeleting;
  final String? exportedJson;
  final Failure? failure;
  final bool accountDeleted;

  PrivacyState copyWith({
    ConsentState? consent,
    bool? isExporting,
    bool? isDeleting,
    String? exportedJson,
    Failure? failure,
    bool? accountDeleted,
  }) {
    return PrivacyState(
      consent: consent ?? this.consent,
      isExporting: isExporting ?? this.isExporting,
      isDeleting: isDeleting ?? this.isDeleting,
      exportedJson: exportedJson ?? this.exportedJson,
      failure: failure,
      accountDeleted: accountDeleted ?? this.accountDeleted,
    );
  }
}

class PrivacyController extends StateNotifier<PrivacyState> {
  PrivacyController({required PrivacyRepository repository})
      : _repository = repository,
        super(const PrivacyState()) {
    _init();
  }

  final PrivacyRepository _repository;

  Future<void> _init() async {
    try {
      final consent = await _repository.getConsent();
      state = state.copyWith(consent: consent);
    } catch (_) {
      // Ignorar si no hay consent previo
    }
  }

  Future<void> setAnalyticsConsent(bool allow) async {
    final updated = state.consent.copyWith(analytics: allow);
    state = state.copyWith(consent: updated);
    try {
      await _repository.grantConsent(updated);
    } catch (e) {
      state = state.copyWith(
          failure: UnknownFailure('Error al guardar consentimiento: $e'));
    }
  }

  Future<void> setPersonalizationConsent(bool allow) async {
    final updated = state.consent.copyWith(personalization: allow);
    state = state.copyWith(consent: updated);
    try {
      await _repository.grantConsent(updated);
    } catch (e) {
      state = state.copyWith(
          failure: UnknownFailure('Error al guardar consentimiento: $e'));
    }
  }

  Future<void> exportData() async {
    state = state.copyWith(isExporting: true, failure: null);
    try {
      final json = await _repository.exportUserData();
      state = state.copyWith(isExporting: false, exportedJson: json);
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        failure: UnknownFailure('Error al exportar: $e'),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isDeleting: true, failure: null);
    try {
      await _repository.deleteAccount();
      state = state.copyWith(isDeleting: false, accountDeleted: true);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        failure: UnknownFailure('Error al eliminar cuenta: $e'),
      );
    }
  }

  void clearExported() {
    state = state.copyWith(exportedJson: null);
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }
}

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  return PrivacyRepositoryImpl();
});

final privacyControllerProvider =
    StateNotifierProvider<PrivacyController, PrivacyState>((ref) {
  return PrivacyController(
    repository: ref.watch(privacyRepositoryProvider),
  );
});
