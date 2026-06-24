// =============================================================================
// theme.dart - Tema lúdico para nios
// -----------------------------------------------------------------------------
// Tema vibrante con fuente Fredoka, bordes redondeados y colores vivos.
// Pensado para nios de 2-7 anios: contraste alto, formas suaves, text grade.
// =============================================================================

import 'package:flutter/material.dart';

/// Paleta de colores de StoryEnglish Kids.
///
/// Vibrante pero no saturada al extremo, para no fatigar la vista del nio.
/// Tres colores primarios + uno de acento + semaforo de estados.
class SEColors {
  SEColors._();

  // ---- Primarios ----
  /// Azul profundo - primario, transmite confianza.
  static const Color primary = Color(0xFF2E5BFF);

  /// Azul claro - fondos y superficies.
  static const Color primaryLight = Color(0xFFE8EFFF);

  /// Azul oscuro - texto y botones presionados.
  static const Color primaryDark = Color(0xFF1A3FCC);

  // ---- Secundarios (companion colors) ----
  /// Naranja cálido - acento, CTA secundarios, diversión.
  static const Color accent = Color(0xFFFF8A3D);

  /// Verde lima - progreso, logros, "completado".
  static const Color success = Color(0xFF2ECC71);

  /// Amarillo sol - highlights, estrellas, badges.
  static const Color warning = Color(0xFFFFC93D);

  /// Rojo coral - errores, bloqueos (suave para no asustar).
  static const Color error = Color(0xFFFF5A5F);

  // ---- Neutros ----
  static const Color background = Color(0xFFFFFBF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFFD1D5DB);

  // ---- Categorias (para iconos) ----
  static const Color categoryAnimals = Color(0xFFFF8A3D);
  static const Color categoryAdventure = Color(0xFF2E5BFF);
  static const Color categoryBedtime = Color(0xFF6C5CE7);
  static const Color categoryFairy = Color(0xFFE84393);
  static const Color categoryEducational = Color(0xFF2ECC71);
}

/// Tema de la app (light y dark).
///
/// El modo oscuro se mantiene como stub - en MVP solo se usa light porque los
/// nios pequeos suelen usar la app en ambientes iluminados.
class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Fredoka';

  /// Tema claro (principal).
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: SEColors.primary,
      primary: SEColors.primary,
      secondary: SEColors.accent,
      surface: SEColors.surface,
      error: SEColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SEColors.background,
      fontFamily: _fontFamily,
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: SEColors.background,
        foregroundColor: SEColors.textPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: SEColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52), // tap target >=48dp (recomendado 52)
          backgroundColor: SEColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // bordes redondeados
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: SEColors.primary,
          side: const BorderSide(color: SEColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SEColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SEColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SEColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SEColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SEColors.error),
        ),
        labelStyle: const TextStyle(color: SEColors.textSecondary),
        hintStyle: const TextStyle(color: SEColors.textHint),
      ),
      cardTheme: CardTheme(
        color: SEColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SEColors.primaryLight,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: SEColors.primary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SEColors.surface,
        selectedItemColor: SEColors.primary,
        unselectedItemColor: SEColors.textHint,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: SEColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Tema oscuro (stub - no se usa en MVP, los nios usan light).
  static ThemeData get dark => light.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      );

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display - titulos grandes de onboarding
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: SEColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: SEColors.textPrimary,
      ),
      // Headline - titulos de pantalla
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: SEColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SEColors.textPrimary,
      ),
      // Title - titulos de card / seccion
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: SEColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: SEColors.textPrimary,
      ),
      // Body - texto del cuento (mas grade para legibilidad infantil)
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        height: 1.5,
        color: SEColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        height: 1.4,
        color: SEColors.textPrimary,
      ),
      // Label - botones, chips
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: SEColors.textPrimary,
      ),
    );
  }

  /// Radio de bordes estandar.
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusXLarge = 32;
}
