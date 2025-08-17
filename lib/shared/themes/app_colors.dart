// App color definitions
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Using the exact palette provided
  static const Color primary = Color(0xFF03045E); // Dark Blue
  static const Color primaryLight = Color(0xFF0077B6); // Medium Blue
  static const Color primaryDark = Color(0xFF00B4D8); // Light Blue
  static const Color primaryExtraLight = Color(0xFF90E0EF); // Very Light Blue
  static const Color primaryUltraLight = Color(0xFFCAF0F8); // Ultra Light Blue

  // Secondary Colors - Complementary to primary
  static const Color secondary = Color(0xFF0077B6); // Medium Blue
  static const Color secondaryLight = Color(0xFF00B4D8); // Light Blue

  // Accent Colors
  static const Color accent = Color(0xFF00B4D8); // Light Blue
  static const Color accentLight = Color(0xFF90E0EF); // Very Light Blue
  static const Color accentExtraLight = Color(0xFFCAF0F8); // Ultra Light Blue

  // Text Colors
  static const Color textPrimary = Color(0xFF03045E); // Dark Blue for main text
  static const Color textSecondary = Color(0xFF0077B6); // Medium Blue for secondary text
  static const Color textOnPrimary = Colors.white; // White text on dark backgrounds
  static const Color textOnSecondary = Colors.white; // White text on medium backgrounds
  static const Color textOnAccent = Color(0xFF03045E); // Dark text on light backgrounds

  // Background Colors
  static const Color backgroundLight = Color(0xFFCAF0F8); // Ultra Light Blue background
  static const Color backgroundDark = Color(0xFF03045E); // Dark Blue for dark mode
  static const Color backgroundMedium = Color(0xFF90E0EF); // Medium Light Blue

  // Surface Colors
  static const Color surfaceLight = Colors.white; // White for cards, sheets
  static const Color surfaceDark = Color(0xFF0077B6); // Medium Blue for dark surfaces
  static const Color surfaceMedium = Color(0xFF90E0EF); // Light Blue for medium surfaces

  // Dark mode specific
  static const Color secondaryDark = Color(0xFF0077B6); // Medium Blue for dark mode secondary

  // Error Color
  static const Color error = Color(0xFFB00020);

  // Success Color
  static const Color success = Color(0xFF4CAF50);

  // Warning Color
  static const Color warning = Color(0xFFFF9800);

  // Info Color
  static const Color info = Color(0xFF00B4D8);

  // Grayscale (using palette tints for consistency)
  static const Color grey100 = Color(0xFFF5F5F5); // Light grey for search bar background
  static const Color grey200 = Color(0xFFE0E0E0);
  static const Color grey300 = Color(0xFFCCCCCC);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF03045E),
    Color(0xFF0077B6),
    Color(0xFF00B4D8),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF00B4D8),
    Color(0xFF90E0EF),
    Color(0xFFCAF0F8),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFCAF0F8),
    Color(0xFF90E0EF),
    Color(0xFF00B4D8),
  ];
}
