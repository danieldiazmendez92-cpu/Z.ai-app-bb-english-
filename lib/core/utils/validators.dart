// =============================================================================
// validators.dart - Validadores de input
// -----------------------------------------------------------------------------
// Funciones puras que validan formatos y devuelven null si OK o un mensaje
// de error si invalido (compatible con `FormField.validator`).
//
// Tambien exponen helpers `bool` para usar fuera de forms.
// =============================================================================

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../extensions/string_extensions.dart';

/// Validadores de formularios.
class Validators {
  Validators._();

  // ---- Email ----

  /// `FormFieldValidator<String>` para email. Devuelve null si OK, mensaje si error.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es obligatorio';
    if (!value.isValidEmail) return 'Email invalido';
    return null;
  }

  /// `bool` helper para email.
  static bool isValidEmail(String? value) => value != null && value.isValidEmail;

  // ---- Password ----

  /// `FormFieldValidator<String>` para contrasena (registro).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contrasena es obligatoria';
    if (value.length < 8) return 'Minimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe incluir una mayuscula';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Debe incluir una minuscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe incluir un numero';
    return null;
  }

  /// `bool` helper para password fuerte.
  static bool isStrongPassword(String? value) =>
      value != null && value.isStrongPassword;

  // ---- Confirmacion de password ----

  /// Devuelve un validator que compara contra [original].
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Confirma la contrasena';
      if (value != original) return 'Las contrasenas no coinciden';
      return null;
    };
  }

  // ---- Edad (nios) ----

  /// `FormFieldValidator<int>` para edad del nio (2-7).
  static String? age(int? value) {
    if (value == null) return 'Selecciona la edad';
    if (value < AppConstants.minAge) {
      return 'Edad minima: ${AppConstants.minAge} anios';
    }
    if (value > AppConstants.maxAge) {
      return 'Edad maxima: ${AppConstants.maxAge} anios';
    }
    return null;
  }

  /// `bool` helper para edad valida.
  static bool isValidAge(int age) =>
      age >= AppConstants.minAge && age <= AppConstants.maxAge;

  // ---- Nombre del nio ----

  /// `FormFieldValidator<String>` para nombre del nio.
  /// Solo primer nombre o apodo, max 20 chars, sin PII.
  static String? childName(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es obligatorio';
    if (value.length > AppConstants.maxChildNameLength) {
      return 'Maximo ${AppConstants.maxChildNameLength} caracteres';
    }
    // Solo letras (con tildes), espacios y guiones. No numeros ni simbolos.
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s-]+$').hasMatch(value)) {
      return 'Solo letras y espacios';
    }
    return null;
  }

  // ---- Texto requerido generico ----

  /// `FormFieldValidator<String>` para campo requerido.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  // ---- Limite de tiempo parental ----

  /// `FormFieldValidator<int>` para limite diario en minutos.
  /// 0 = sin limite. Max 240 (4 horas).
  static String? dailyLimitMinutes(int? value) {
    if (value == null) return 'Selecciona un limite';
    if (value < 0) return 'No puede ser negativo';
    if (value > 240) return 'Maximo 240 minutos (4 horas)';
    return null;
  }

  // ---- PIN parental ----

  /// `FormFieldValidator<String>` para PIN de 4 digitos (verificacion parental).
  static String? parentalPin(String? value) {
    if (value == null || value.isEmpty) return 'PIN obligatorio';
    if (value.length != 4) return 'PIN debe tener 4 digitos';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'Solo numeros';
    return null;
  }

  // ---- Matematica parental (verificacion por suma) ----

  /// `FormFieldValidator<String>` que compara el input con [expectedAnswer].
  static String? Function(String?) parentalMathAnswer(int expectedAnswer) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Responde la suma';
      final parsed = int.tryParse(value);
      if (parsed == null) return 'Solo numeros';
      if (parsed != expectedAnswer) return 'Respuesta incorrecta';
      return null;
    };
  }
}
