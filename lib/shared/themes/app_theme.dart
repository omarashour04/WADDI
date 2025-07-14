// App theme
import 'package:flutter/material.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/shared/themes/app_typography.dart';

class AppTheme {
  // Light Theme Definition
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.accentExtraLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.accentLight,
      background: AppColors.accentExtraLight,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnAccent,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textOnPrimary),
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineMedium: AppTypography.headlineMedium,
      titleLarge: AppTypography.titleLarge,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: AppTypography.bodyLarge,
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.accentLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.accentLight,
      titleTextStyle: AppTypography.titleLarge,
      contentTextStyle: AppTypography.bodyLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    dividerColor: AppColors.grey300,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // Dark Theme Definition
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: AppColors.primaryLight,
      background: AppColors.primary,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnAccent,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textOnPrimary),
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: Colors.white),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: Colors.white),
      titleLarge: AppTypography.titleLarge.copyWith(color: Colors.white),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white70),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.white70),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.grey500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textOnPrimary),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey300),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey700),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.primaryLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.primaryLight,
      titleTextStyle: AppTypography.titleLarge,
      contentTextStyle: AppTypography.bodyLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryLight),
    dividerColor: AppColors.grey700,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primaryLight,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
} 