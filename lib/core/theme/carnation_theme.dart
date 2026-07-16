import 'package:flutter/material.dart';

abstract final class CarNationColors {
  static const background = Color(0xFF0B1120);
  static const surface = Color(0xFF111827);
  static const surfaceRaised = Color(0xFF172033);
  static const border = Color(0xFF29364D);
  static const accent = Color(0xFF2563EB);
  static const accentSoft = Color(0xFF93C5FD);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFCBD5E1);
  static const textMuted = Color(0xFF94A3B8);
  static const danger = Color(0xFFEF4444);
  static const warningSurface = Color(0xFF292315);
  static const warning = Color(0xFFFBBF24);
}

abstract final class CarNationRadii {
  static const page = 22.0;
  static const card = 18.0;
  static const control = 14.0;
}

abstract final class CarNationTheme {
  static final dark = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: CarNationColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: CarNationColors.accent,
      surface: CarNationColors.surface,
      error: CarNationColors.danger,
    );

    final base = ThemeData.from(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: CarNationColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: CarNationColors.background,
        foregroundColor: CarNationColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: CarNationColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: CarNationColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarNationRadii.card),
          side: const BorderSide(color: CarNationColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CarNationColors.surface,
        hintStyle: const TextStyle(color: CarNationColors.textMuted),
        labelStyle: const TextStyle(color: CarNationColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CarNationRadii.control),
          borderSide: const BorderSide(color: CarNationColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CarNationRadii.control),
          borderSide: const BorderSide(color: CarNationColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CarNationRadii.control),
          borderSide: const BorderSide(
            color: CarNationColors.accent,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CarNationColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CarNationRadii.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CarNationColors.textPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: CarNationColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CarNationRadii.control),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: CarNationColors.textSecondary,
          minimumSize: const Size(48, 48),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: CarNationColors.surfaceRaised,
        contentTextStyle: TextStyle(color: CarNationColors.textPrimary),
        actionTextColor: CarNationColors.accentSoft,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: CarNationColors.border),
    );
  }
}
