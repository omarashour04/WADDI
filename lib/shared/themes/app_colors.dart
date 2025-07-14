// App color definitions
import 'package:flutter/material.dart';
 
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF03045E); // Deep blue
  static const Color primaryLight = Color(0xFF0077B6); // Lighter blue
  static const Color primaryDark = Color(0xFF03045E); // Same as primary for now

  // Accent Colors
  static const Color accent = Color(0xFF00B4D8); // Bright blue accent
  static const Color accentLight = Color(0xFF90E0EF); // Light accent
  static const Color accentExtraLight = Color(0xFFCAF0F8); // Extra light accent

  // Text Colors
  static const Color textPrimary = Color(0xFF03045E); // Use primary for main text
  static const Color textSecondary = Color(0xFF0077B6); // Use lighter blue for secondary text
  static const Color textOnPrimary = Colors.white;
  static const Color textOnAccent = Colors.black;

  // Background Colors
  static const Color backgroundLight = Color(0xFFCAF0F8); // Lightest blue
  static const Color backgroundDark = Color(0xFF03045E); // Deep blue for dark mode

  // Surface Colors
  static const Color surfaceLight = Color(0xFF90E0EF); // Light accent for cards, sheets
  static const Color surfaceDark = Color(0xFF0077B6); // Lighter blue for dark surfaces

  // Error Color
  static const Color error = Color(0xFFB00020);

  // Grayscale (using palette tints for consistency)
  static const Color grey100 = Color(0xFFCAF0F8);
  static const Color grey300 = Color(0xFF90E0EF);
  static const Color grey500 = Color(0xFF00B4D8);
  static const Color grey700 = Color(0xFF0077B6);
  static const Color grey900 = Color(0xFF03045E);
} 