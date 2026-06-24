import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_profile.freezed.dart';
part 'child_profile.g.dart';

/// Perfil de un niño dentro de la cuenta del padre.
///
/// Un padre puede tener hasta 4 perfiles de niños (límite enforced por
/// Cloud Function `onChildCreate`).
///
/// Cumplimiento COPPA: el nombre es solo primer nombre o apodo elegido por
/// el padre. Nunca apellido, nunca fecha de nacimiento exacta, nunca
/// información de contacto del niño.
@freezed
class ChildProfile with _$ChildProfile {
  const factory ChildProfile({
    /// UUID v4 generado por el cliente al crear el perfil.
    required String childId,

    /// UID del padre dueño de este perfil (FK a AppUser.uid).
    required String userUid,

    /// Solo primer nombre o apodo (COPPA: 1-20 caracteres, sin símbolos).
    required String name,

    /// Edad del niño (rango válido: 2-7).
    required int age,

    /// URL del avatar: puede ser asset path (predefinido) o Storage URL
    /// (si el padre subió una imagen custom).
    required String avatarUrl,

    /// Intereses temáticos elegidos por el niño/padre.
    /// Se usan para recomendaciones de cuentos.
    /// Ej: ['animals', 'adventure', 'bedtime']
    @Default(<String>[]) List<String> interests,

    required DateTime createdAt,

    /// Última vez que el niño usó la app con este perfil.
    DateTime? lastActiveAt,

    /// Fecha de soft delete. Si no es null, el perfil está marcado para
    /// borrado físico por `coppaCleanup` Cloud Function tras 30 días.
    DateTime? deletedAt,
  }) = _ChildProfile;

  factory ChildProfile.fromJson(Map<String, dynamic> json) =>
      _$ChildProfileFromJson(json);

  const ChildProfile._();

  /// True si el perfil está marcado como eliminado (soft delete).
  bool get isDeleted => deletedAt != null;
}
