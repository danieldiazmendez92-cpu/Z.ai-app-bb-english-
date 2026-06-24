// =============================================================================
// asset_paths.dart - Rutas a assets estaticos
// -----------------------------------------------------------------------------
// Centraliza todas las rutas a assets para evitar strings esparcidos y typos.
// =============================================================================

/// Rutas a assets (imagenes, iconos, fuentes, animaciones).
class AssetPaths {
  AssetPaths._();

  // ---- Logos ----
  static const String logoFull = 'assets/images/logos/logo_full.png';
  static const String logoMark = 'assets/images/logos/logo_mark.png';
  static const String logoSplash = 'assets/images/logos/logo_splash.png';

  // ---- Avatares predefinidos para nios ----
  static const String _avatarsBase = 'assets/images/avatars';
  static const String avatarFox = '$_avatarsBase/avatar_fox.png';
  static const String avatarPanda = '$_avatarsBase/avatar_panda.png';
  static const String avatarLion = '$_avatarsBase/avatar_lion.png';
  static const String avatarRabbit = '$_avatarsBase/avatar_rabbit.png';
  static const String avatarOwl = '$_avatarsBase/avatar_owl.png';
  static const String avatarElephant = '$_avatarsBase/avatar_elephant.png';
  static const String avatarCat = '$_avatarsBase/avatar_cat.png';
  static const String avatarDog = '$_avatarsBase/avatar_dog.png';

  /// Lista de avatares predefinidos (para el picker de onboarding).
  static const List<String> predefinedAvatars = [
    avatarFox,
    avatarPanda,
    avatarLion,
    avatarRabbit,
    avatarOwl,
    avatarElephant,
    avatarCat,
    avatarDog,
  ];

  // ---- Iconos de logros / insignias ----
  static const String _achievementsBase = 'assets/images/achievements';
  static const String achievementFirstStory =
      '$_achievementsBase/first_story.png';
  static const String achievementStreak7 = '$_achievementsBase/streak_7.png';
  static const String achievementStreak30 = '$_achievementsBase/streak_30.png';
  static const String achievementWords100 =
      '$_achievementsBase/words_100.png';
  static const String achievementExplorer = '$_achievementsBase/explorer.png';

  // ---- Ilustraciones de onboarding ----
  static const String _onboardingBase = 'assets/images/onboarding';
  static const String onboardingWelcome =
      '$_onboardingBase/welcome.png';
  static const String onboardingPickAvatar =
      '$_onboardingBase/pick_avatar.png';
  static const String onboardingPickAge =
      '$_onboardingBase/pick_age.png';
  static const String onboardingPickInterests =
      '$_onboardingBase/pick_interests.png';
  static const String onboardingParentalVerify =
      '$_onboardingBase/parental_verify.png';

  // ---- Iconos SVG (categorias) ----
  static const String _iconsBase = 'assets/icons';
  static const String iconAnimals = '$_iconsBase/animals.svg';
  static const String iconAdventure = '$_iconsBase/adventure.svg';
  static const String iconBedtime = '$_iconsBase/bedtime.svg';
  static const String iconFairy = '$_iconsBase/fairy.svg';
  static const String iconEducational = '$_iconsBase/educational.svg';

  // ---- Animaciones Lottie (celebraciones, etc.) ----
  static const String _animationsBase = 'assets/animations';
  static const String animCelebration = '$_animationsBase/celebration.json';
  static const String animAchievementUnlock =
      '$_animationsBase/achievement_unlock.json';
  static const String animConfetti = '$_animationsBase/confetti.json';
  static const String animLoading = '$_animationsBase/loading.json';
  static const String animStoryComplete =
      '$_animationsBase/story_complete.json';

  // ---- Fuentes ----
  static const String fontFredoka = 'Fredoka';
  static const String fontOpenDyslexic = 'OpenDyslexic';

  // ---- Placeholder ----
  /// Imagen placeholder cuando una portada aun no carga.
  static const String placeholderCover =
      'assets/images/logos/logo_mark.png';
}
