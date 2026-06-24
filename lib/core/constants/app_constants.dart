// =============================================================================
// app_constants.dart - Constantes globales de la app
// -----------------------------------------------------------------------------
// Strings hardcodeados, durations, lmites de negocio, claves de Hive, etc.
// NO poner aqui strings localizables (esos van a assets/l10n/*.arb).
// =============================================================================

import 'package:flutter/material.dart';

/// Constantes globales de StoryEnglish Kids.
class AppConstants {
  AppConstants._();

  // ---- Identidad ----
  static const String appName = 'StoryEnglish Kids';
  static const String supportEmail = 'support@storyenglish-kids.app';

  // ---- Edades soportadas (rango objetivo) ----
  static const int minAge = 2;
  static const int maxAge = 7;

  // ---- Limites de negocio ----
  /// Maximo de perfiles de nio por cuenta de padre (configurable via Remote Config).
  static const int maxChildrenPerAccount = 4;

  /// Limite diario por defecto (minutos). 0 = sin limite.
  static const int defaultDailyLimitMinutes = 30;

  /// Velocidad de audio por defecto (1.0 = normal).
  static const double defaultAudioSpeed = 1.0;

  /// Velocidades disponibles en el reproductor.
  static const List<double> audioSpeeds = [0.75, 1.0, 1.25, 1.5];

  // ---- Duraciones (UX) ----
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration defaultDebounceDuration = Duration(milliseconds: 400);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration achievementAnimationDuration = Duration(seconds: 2);

  // ---- Audio player ----
  /// Intervalo de polling de posicion (ms) para resaltado palabra-a-palabra.
  static const Duration audioPositionUpdateInterval = Duration(milliseconds: 100);
  /// Duracion de cache del audio MP3 descargado.
  static const Duration audioCacheTtl = Duration(days: 7);

  // ---- Claves de Hive boxes ----
  static const String hiveBoxCache = 'se_cache';
  static const String hiveBoxAuth = 'se_auth';
  static const String hiveBoxSettings = 'se_settings';
  static const String hiveBoxProgress = 'se_progress';

  // ---- Claves de SharedPreferences / Hive ----
  static const String keyActiveChildId = 'active_child_id';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyParentalVerifiedAt = 'parental_verified_at';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';

  // ---- Auth providers ----
  static const String providerEmail = 'email';
  static const String providerGoogle = 'google';
  static const String providerApple = 'apple';

  // ---- Planes de suscripcion ----
  static const String planMonthly = 'monthly';
  static const String planAnnual = 'annual';

  // ---- Status de suscripcion ----
  static const String statusActive = 'active';
  static const String statusExpired = 'expired';
  static const String statusCanceled = 'canceled';
  static const String statusGracePeriod = 'grace_period';

  // ---- Tipos de criterio de logros ----
  static const String criteriaStoriesCompleted = 'stories_completed';
  static const String criteriaStreakDays = 'streak_days';
  static const String criteriaWordsLearned = 'words_learned';
  static const String criteriaMinutesRead = 'minutes_read';

  // ---- Seguridad / COPPA ----
  /// Gracia antes del borrado definitivo de un perfil de nio (soft delete).
  static const int coppaDeleteGraceDays = 30;

  /// Hash salt prefix para childId hasheado en analytics (no se commitea el salt real).
  static const String analyticsChildIdHashPrefix = 'se_child_';

  // ---- Tamano minimo de tap target (Material guidelines + accesibilidad nios) ----
  static const double minTapTarget = 48.0;

  // ---- Lmites de texto ----
  static const int maxChildNameLength = 20;
  static const int maxStoryTitleLength = 80;
  static const int maxStorySectionLength = 500;

  // ---- TimeOfDay defaults para bedtime ----
  static const TimeOfDay defaultBedtimeStart = TimeOfDay(hour: 20, minute: 0);
  static const TimeOfDay defaultBedtimeEnd = TimeOfDay(hour: 7, minute: 0);
}
