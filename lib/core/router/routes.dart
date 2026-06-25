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

  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingWelcomeName = 'onboarding-welcome';

  static const String onboardingAvatar = '/onboarding/avatar';
  static const String onboardingAvatarName = 'onboarding-avatar';

  static const String onboardingAge = '/onboarding/age';
  static const String onboardingAgeName = 'onboarding-age';

  static const String onboardingInterests = '/onboarding/interests';
  static const String onboardingInterestsName = 'onboarding-interests';

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
  ///
  /// Para crear un hijo nuevo, pasar `'new'`: devuelve `/edit-child/new`.
  static String editChildFor(String childId) => '/edit-child/$childId';

  /// Path al flow de crear hijo nuevo: `/edit-child/new`.
  static String get editChildNew => '/edit-child/new';

  // ---- Rutas legales (placeholders hasta implementar) ----
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // ---- Parental controls ----
  static const String parentalControls = '/parental-controls';
  static const String parentalControlsName = 'parental-controls';

  // ---- Privacy ----
  static const String privacySettings = '/privacy-settings';
  static const String privacySettingsName = 'privacy-settings';

  // ---- Vocabulary review (SRS) ----
  static const String vocabularyReview = '/vocabulary-review';
  static const String vocabularyReviewName = 'vocabulary-review';

  // ---- Read to Me mode (under 4) ----
  static const String readToMe = '/read-to-me/:storyId';
  static const String readToMeName = 'read-to-me';

  /// Construye path a Read to Me: `/read-to-me/{storyId}`.
  static String readToMeFor(String storyId) => '/read-to-me/$storyId';
}

/// Alias para uso más corto en las pantallas: `Routes.login` en lugar de
/// `AppRoutes.login`.
typedef Routes = AppRoutes;
