// =============================================================================
// routes.dart - Constantes de rutas (paths y nombres)
// -----------------------------------------------------------------------------
// Centraliza los paths de GoRouter para evitar strings esparcidos y typos.
// =============================================================================

/// Nombres y paths de rutas para GoRouter.
class AppRoutes {
  AppRoutes._();

  // ---- Auth flow ----
  static const String login = '/login';
  static const String loginName = 'login';

  static const String signup = '/signup';
  static const String signupName = 'signup';

  static const String parentalVerification = '/parental-verification';
  static const String parentalVerificationName = 'parental-verification';

  static const String passwordReset = '/password-reset';
  static const String passwordResetName = 'password-reset';

  // ---- Onboarding ----
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // ---- Main app (BottomNav) ----
  static const String home = '/';
  static const String homeName = 'home';

  static const String library = '/library';
  static const String libraryName = 'library';

  static const String progress = '/progress';
  static const String progressName = 'progress';

  static const String parent = '/parent';
  static const String parentName = 'parent';

  // ---- Story flow ----
  /// Path con parametro: `/story/:storyId`.
  static const String storyDetail = '/story/:storyId';
  static const String storyDetailName = 'story-detail';

  /// Path con parametro: `/reader/:storyId`.
  static const String reader = '/reader/:storyId';
  static const String readerName = 'reader';

  /// Path con parametro: `/story-end/:storyId`.
  static const String storyEnd = '/story-end/:storyId';
  static const String storyEndName = 'story-end';

  // ---- Settings / Subscription ----
  static const String subscription = '/subscription';
  static const String subscriptionName = 'subscription';

  static const String paywall = '/paywall';
  static const String paywallName = 'paywall';

  static const String childPicker = '/child-picker';
  static const String childPickerName = 'child-picker';

  static const String editChild = '/edit-child/:childId';
  static const String editChildName = 'edit-child';

  // ---- Helper para construir paths con parametros ----

  /// Construye path a story detail: `/story/{storyId}`.
  static String storyDetailFor(String storyId) => '/story/$storyId';

  /// Construye path a reader: `/reader/{storyId}`.
  static String readerFor(String storyId) => '/reader/$storyId';

  /// Construye path a story end: `/story-end/{storyId}`.
  static String storyEndFor(String storyId) => '/story-end/$storyId';

  /// Construye path a edit child: `/edit-child/{childId}`.
  static String editChildFor(String childId) => '/edit-child/$childId';

  // ---- Rutas legales (placeholders hasta implementar) ----
  static const String terms = '/terms';
  static const String privacy = '/privacy';
}

/// Alias para uso más corto en las pantallas: `Routes.login` en lugar de
/// `AppRoutes.login`.
typedef Routes = AppRoutes;
