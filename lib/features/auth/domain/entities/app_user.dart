import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Representa al padre/madre que crea la cuenta en la app.
/// Los niños NO tienen cuenta propia, son perfiles dentro de la cuenta del padre.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    /// Firebase Auth UID
    required String uid,

    /// Email en lowercase
    required String email,

    /// Nombre para mostrar (opcional)
    String? displayName,

    /// Proveedor de auth: 'email' | 'google' | 'apple'
    required String authProvider,

    /// Fecha de verificación parental. Null hasta que verifica ser adulto.
    DateTime? parentalVerifiedAt,

    /// True si tiene suscripción Premium activa.
    /// Se sincroniza desde la colección `subscriptions` vía Cloud Function.
    @Default(false) bool isPremium,

    /// Fecha de expiración del premium (si aplica)
    DateTime? premiumExpiresAt,

    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Constructor vacío para casos donde todavía no hay usuario.
  const AppUser._();

  /// True si el usuario completó la verificación parental.
  bool get isParentalVerified => parentalVerifiedAt != null;
}
