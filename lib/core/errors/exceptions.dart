// =============================================================================
// exceptions.dart - Excepciones de la capa de datos
// -----------------------------------------------------------------------------
// Excepciones concretas lanzadas por datasources (Firebase, Storage, etc.).
// Los repository impl las atrapan y las traducen a `Failure` de dominio.
// =============================================================================

import 'package:flutter/foundation.dart';

/// Contrato base para excepciones de la capa de datos.
@immutable
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.originalError, this.stackTrace});

  /// Mensaje tecnico (no para el usuario - el usuario ve Failure.message).
  final String message;

  /// Codigo estable de la plataforma (ej: 'email-already-in-use').
  final String? code;

  /// Excepcion original (FirebaseAuthException, DioException, etc.).
  final Object? originalError;

  /// Stack trace del error original.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final codeStr = code != null ? ' [$code]' : '';
    return '$runtimeType$codeStr: $message';
  }
}

/// Excepcion de Firebase Auth (credenciales, sesion, etc.).
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de Firestore (documento no existe, reglas de seguridad, etc.).
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de Firebase Storage (descarga/subida fallo, permiso, etc.).
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de red (sin conexion, timeout, DNS).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de Cloud Functions (timeout, error interno, payload invalido).
class FunctionsException extends AppException {
  const FunctionsException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de cache local (Hive corrupto, escritura fallo, etc.).
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de billing (compra cancelada, receipt invalido, store error).
class BillingException extends AppException {
  const BillingException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion de validacion en capa datos (formato, parseo JSON, schema).
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    this.fieldErrors = const [],
    super.originalError,
    super.stackTrace,
  });

  /// Lista de errores por campo (ej: ['email: invalid format']).
  final List<String> fieldErrors;
}

/// Excepcion de parseo (no se pudo mapear JSON a modelo freezed).
class ParseException extends AppException {
  const ParseException(super.message, {super.code, super.originalError, super.stackTrace});
}

/// Excepcion generica / desconocida.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.originalError, super.stackTrace});
}
