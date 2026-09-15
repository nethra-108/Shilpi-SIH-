import 'package:flutter/material.dart';
import 'colors.dart';

class ShilpiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ShilpiColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ShilpiColors.primary,
        primary: ShilpiColors.primary,
        secondary: ShilpiColors.secondary,
        surface: ShilpiColors.surface,
        background: ShilpiColors.background,
        error: ShilpiColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ShilpiColors.background,
        foregroundColor: ShilpiColors.primaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ShilpiColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: ShilpiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ShilpiColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ShilpiColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShilpiColors.primaryDark,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: ShilpiColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShilpiColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShilpiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShilpiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShilpiColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: ShilpiColors.textMuted, fontSize: 15),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ShilpiColors.surface,
        selectedItemColor: ShilpiColors.primary,
        unselectedItemColor: ShilpiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: ShilpiColors.divider,
        thickness: 1,
        space: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ShilpiColors.surfaceMuted,
        labelStyle: const TextStyle(color: ShilpiColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
