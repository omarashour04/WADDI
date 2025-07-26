// App color definitions
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Teal/Turquoise theme (from screenshots)
  static const Color primary = Color(0xFF00B4D8); // Teal/Turquoise for headers and navigation
  static const Color primaryLight = Color(0xFF90E0EF); // Lighter teal
  static const Color primaryDark = Color(0xFF0077B6); // Darker teal

  // Secondary Colors - Dark Blue/Navy (from "Book Now" button)
  static const Color secondary = Color(0xFF03045E); // Dark Blue/Navy for main buttons
  static const Color secondaryLight = Color(0xFF0077B6); // Lighter blue

  // Tertiary Colors - Orange/Peach (from "Favorites" button)
  static const Color tertiary = Color(0xFFFF6B35); // Orange/Peach for special buttons
  static const Color tertiaryLight = Color(0xFFFF8A65); // Lighter orange

  // Accent Colors
  static const Color accent = Color(0xFF00B4D8); // Bright teal accent
  static const Color accentLight = Color(0xFF90E0EF); // Light accent
  static const Color accentExtraLight = Color(0xFFCAF0F8); // Extra light accent

  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Black for main text (venue names, titles)
  static const Color textSecondary = Color(
    0xFF666666,
  ); // Grey for secondary text (descriptions, placeholders)
  static const Color textOnPrimary = Colors.white; // White text on teal headers
  static const Color textOnSecondary = Colors.white; // White text on dark blue buttons
  static const Color textOnTertiary = Colors.white; // White text on orange buttons

  // Background Colors
  static const Color backgroundLight = Colors.white; // White background for content areas
  static const Color backgroundDark = Color(0xFF03045E); // Dark blue for dark mode

  // Surface Colors
  static const Color surfaceLight = Colors.white; // White for cards, sheets
  static const Color surfaceDark = Color(0xFF0077B6); // Lighter blue for dark surfaces

  // Error Color
  static const Color error = Color(0xFFB00020);

  // Grayscale (using palette tints for consistency)
  static const Color grey100 = Color(0xFFF5F5F5); // Light grey for search bar background
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);
}
