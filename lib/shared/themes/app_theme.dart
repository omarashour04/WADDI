// App theme
import 'package:flutter/material.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';
import 'package:waddi_platform/shared/themes/app_typography.dart';

class AppTheme {
  // Light Theme Definition
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnSecondary,
      onTertiary: AppColors.textOnAccent,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
      surfaceVariant: AppColors.surfaceMedium,
      onSurfaceVariant: AppColors.textSecondary,
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
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: AppTypography.bodyLarge,
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.textOnPrimary,
      unselectedItemColor: AppColors.textOnPrimary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.grey400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.grey300;
      }),
    ),
  );

  // Dark Theme Definition
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnSecondary,
      onTertiary: AppColors.textOnPrimary,
      onSurface: AppColors.textOnPrimary,
      onBackground: AppColors.textOnPrimary,
      onError: Colors.white,
      surfaceVariant: AppColors.surfaceMedium,
      onSurfaceVariant: AppColors.textOnPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
      titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.textOnPrimary),
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textOnPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textOnPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textOnPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textOnPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.grey300),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textOnSecondary),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey300),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: AppTypography.titleLarge,
      contentTextStyle: AppTypography.bodyLarge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryDark),
    dividerColor: AppColors.grey700,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textOnPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryDark,
      selectedItemColor: AppColors.textOnPrimary,
      unselectedItemColor: AppColors.textOnPrimary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryDark;
        }
        return AppColors.grey600;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryDark.withValues(alpha: 0.5);
        }
        return AppColors.grey700;
      }),
    ),
  );
}
