import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_state.freezed.dart';

/// Estado de consentimiento del usuario (GDPR/COPPA).
///
/// El consentimiento "necessary" siempre es true (no se puede desactivar).
/// Los demás son opt-in.
@freezed
class ConsentState with _$ConsentState {
  const factory ConsentState({
    /// Consentimiento para analytics. Default: false.
    /// COPPA/GDPR-K: debe ser opt-in explícito.
    @Default(false) bool analytics,

    /// Consentimiento para personalización (recomendaciones basadas en
    /// comportamiento del niño). Default: false.
    @Default(false) bool personalization,
  }) = _ConsentState;

  const ConsentState._();

  /// Consentimiento necesario siempre es true.
  bool get necessary => true;
}
