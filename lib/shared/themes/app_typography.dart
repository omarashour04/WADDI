// App typography
import 'package:flutter/material.dart';
import 'package:waddi_platform/shared/themes/app_colors.dart';

class AppTypography {
  // Display styles: For large, prominent text (e.g., headlines).
  static const TextStyle displayLarge = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 57,
    color: AppColors.textPrimary,
  );

  // Headline styles: For important headings.
  static const TextStyle headlineMedium = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 28,
    color: AppColors.textPrimary,
  );

  // Title styles: For titles of sections or pages.
  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    color: AppColors.textPrimary,
  );

  // Body styles: For main content text.
  static const TextStyle bodyLarge = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  // Label styles: For small labels or captions.
  static const TextStyle labelSmall = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors.textSecondary,
  );
} 