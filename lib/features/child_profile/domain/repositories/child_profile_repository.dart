import '../entities/child_profile.dart';
import '../entities/parental_settings.dart';

/// Contrato del repositorio de perfiles de niños.
///
/// Maneja:
/// - CRUD de perfiles de niños (colección `children_profiles`)
/// - Lectura/escritura de configuración parental (colección `parental_settings`)
///
/// La implementación vive en `data/child_profile_repository_impl.dart`.
abstract class ChildProfileRepository {
  // ============================================================
  // Perfiles de niños
  // ============================================================

  /// Crea un nuevo perfil de niño para el usuario actual.
  ///
  /// Valida en cliente que el usuario tenga menos de 4 perfiles activos.
  /// Cloud Function `onChildCreate` también valida server-side.
  Future<ChildProfile> createChild({
    required String name,
    required int age,
    required String avatarUrl,
    List<String> interests = const [],
  });

  /// Actualiza un perfil existente.
  Future<ChildProfile> updateChild({
    required String childId,
    String? name,
    int? age,
    String? avatarUrl,
    List<String>? interests,
  });

  /// Marca un perfil como eliminado (soft delete).
  /// Cloud Function `coppaCleanup` lo borra físicamente tras 30 días.
  Future<void> softDeleteChild(String childId);

  /// Obtiene todos los perfiles activos (no eliminados) del usuario.
  Future<List<ChildProfile>> getChildrenForUser(String userUid);

  /// Stream reactivo de perfiles del usuario.
  /// Se actualiza automáticamente cuando se crea/edita/elimina un perfil.
  Stream<List<ChildProfile>> watchChildrenForUser(String userUid);

  /// Obtiene un perfil específico por ID.
  Future<ChildProfile> getChild(String childId);

  /// Actualiza el campo `last_active_at` del niño activo.
  /// Se llama cuando el niño abre la app o completa una acción.
  Future<void> updateLastActive(String childId);

  // ============================================================
  // Configuración parental
  // ============================================================

  /// Lee la configuración parental del usuario.
  /// Si no existe, retorna defaults.
  Future<ParentalSettings> getParentalSettings(String userUid);

  /// Actualiza la configuración parental.
  Future<void> updateParentalSettings(ParentalSettings settings);
}
