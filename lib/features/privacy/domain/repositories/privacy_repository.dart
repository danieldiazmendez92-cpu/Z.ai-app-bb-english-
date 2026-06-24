import '../entities/consent_state.dart';

/// Contrato del repositorio de privacidad.
///
/// Maneja:
/// - Consentimiento granular (analytics, personalization)
/// - Exportación de datos del usuario (GDPR Art. 20 - Portabilidad)
/// - Eliminación de cuenta + datos del niño (GDPR Art. 17 - Derecho al olvido)
abstract class PrivacyRepository {
  /// Guarda el estado de consentimiento del usuario.
  Future<void> grantConsent(ConsentState consent);

  /// Lee el estado de consentimiento actual.
  Future<ConsentState> getConsent();

  /// Exporta todos los datos del usuario + sus hijos en formato JSON.
  ///
  /// Devuelve un string JSON descargable.
  /// GDPR Art. 20: derecho a la portabilidad de los datos.
  Future<String> exportUserData();

  /// Elimina la cuenta del usuario + todos los datos asociados.
  ///
  /// GDPR Art. 17: derecho al olvido.
  /// COPPA: borrado físico de datos del niño tras 30 días (grace period).
  ///
  /// Pasos:
  /// 1. Marca perfiles de niños con deleted_at (COPPA cleanup los borra en 30 días)
  /// 2. Borra datos no sensibles inmediatamente (user_progress, user_achievements)
  /// 3. Borra parental_settings y user_consents
  /// 4. Borra doc del usuario en Firestore
  /// 5. Borra cuenta de Firebase Auth
  Future<void> deleteAccount();
}
