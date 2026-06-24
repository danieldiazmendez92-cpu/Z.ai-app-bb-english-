// =============================================================================
// failures.dart - Errores de dominio (capa domain)
// -----------------------------------------------------------------------------
// Representan fallos entendibles por la capa de presentacion. La capa de datos
// traduce excepciones concretas (FirebaseAuthException, SocketException, ...)
// a uno de estos `Failure`.
//
// Sealed class: permite `switch` exhaustivo sobre los tipos de fallo.
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Contrato base para todos los fallos de dominio.
///
/// Cada `Failure` lleva:
///  - `message`: mensaje corto visible al usuario (ya localizado por la UI).
///  - `code`: codigo estable para analytics y tests (ej: 'auth/invalid-email').
///  - `details`: contexto extra opcional (stack trace, payload, etc.).
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Error de autenticacion (credenciales invalidas, sesion expirada, etc.).
  const factory Failure.auth({
    @Default('auth') String code,
    required String message,
    String? details,
  }) = AuthFailure;

  /// Error de permisos / reglas de seguridad Firestore.
  const factory Failure.permission({
    @Default('permission') String code,
    required String message,
    String? details,
  }) = PermissionFailure;

  /// Error de red (sin conexion, timeout, DNS).
  const factory Failure.network({
    @Default('network') String code,
    required String message,
    String? details,
  }) = NetworkFailure;

  /// Error de servidor / backend (Cloud Function fallo, Firestore down).
  const factory Failure.server({
    @Default('server') String code,
    required String message,
    String? details,
  }) = ServerFailure;

  /// Recurso no encontrado (ej: cuento publicado=false, child_id inexistente).
  const factory Failure.notFound({
    @Default('not_found') String code,
    required String message,
    String? details,
  }) = NotFoundFailure;

  /// Error de validacion (formato email, edad fuera de rango, etc.).
  const factory Failure.validation({
    @Default('validation') String code,
    required String message,
    @Default(<String>[]) List<String> fieldErrors,
    String? details,
  }) = ValidationFailure;

  /// Error de billing (compra fallida, receipt invalido, etc.).
  const factory Failure.billing({
    @Default('billing') String code,
    required String message,
    String? details,
  }) = BillingFailure;

  /// Cuenta limitada por plan gratis (cuota alcanzada).
  const factory Failure.quotaExceeded({
    @Default('quota_exceeded') String code,
    required String message,
    String? details,
  }) = QuotaExceededFailure;

  /// Error generico / desconocido (catch-all).
  const factory Failure.unknown({
    @Default('unknown') String code,
    required String message,
    Object? details,
  }) = UnknownFailure;

  /// Mensaje ya localizado para mostrar al usuario.
  String get userMessage => message;

  /// `true` si el fallo puede reintentarse (red, servidor).
  bool get isRetryable =>
      this is NetworkFailure ||
      this is ServerFailure ||
      this is UnknownFailure;
}
