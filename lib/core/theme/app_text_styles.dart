import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Comprehensive typography system for the Dualify Dashboard
/// Contains all text styles with proper font families, weights, and spacing
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Font Families
  static const String _manropeFont = 'Manrope';
  static const String _fredokaOneFont = 'Fredoka One';
  static const String _lexendFont = 'Lexend';

  // Display Styles (Large headings and titles)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
    color: AppColors.foreground,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
    color: AppColors.foreground,
  );

  // Heading Styles (Section headings and page titles)
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.01,
    color: AppColors.foreground,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.foreground,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.foreground,
  );

  // Body Text Styles (Main content text)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.foreground,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.foreground,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.foreground,
  );

  // Label Styles (Form labels, captions, small text)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.01,
    color: AppColors.slate700,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.01,
    color: AppColors.slate600,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.02,
    color: AppColors.slate500,
  );

  // Special Styles

  /// Login screen title with Fredoka One font and text shadow
  static const TextStyle loginTitle = TextStyle(
    fontFamily: _fredokaOneFont,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.primary,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 4,
        color: AppColors.loginTitleShadow,
      ),
    ],
  );

  /// Login screen body text with Lexend font
  static const TextStyle loginBody = TextStyle(
    fontFamily: _lexendFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.loginBodyText,
  );

  /// Login screen subtitle with Lexend font
  static const TextStyle loginSubtitle = TextStyle(
    fontFamily: _lexendFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.slate500,
  );

  /// Progress percentage display
  static const TextStyle progressPercentage = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.0,
    letterSpacing: -0.01,
    color: AppColors.primary,
  );

  /// Progress label text
  static const TextStyle progressLabel = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.01,
    color: AppColors.slate600,
  );

  /// Day numbers in calendar
  static const TextStyle dayNumber = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.foreground,
  );

  /// Day labels (Mon, Tue, etc.)
  static const TextStyle dayLabel = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.02,
    color: AppColors.slate500,
  );

  /// Today badge text
  static const TextStyle todayBadge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.05,
    color: AppColors.white,
  );

  /// Emoji status display
  static const TextStyle emojiStatus = TextStyle(fontSize: 24, height: 1.0);

  /// Card title text
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.foreground,
  );

  /// Card subtitle text
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.slate600,
  );

  /// Card body text
  static const TextStyle cardBody = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.slate700,
  );

  /// Button text styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.01,
    color: AppColors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.01,
    color: AppColors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.02,
    color: AppColors.white,
  );

  /// Navigation text styles
  static const TextStyle navActive = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.01,
    color: AppColors.bottomNavActive,
  );

  static const TextStyle navInactive = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.01,
    color: AppColors.bottomNavInactive,
  );

  /// Form input styles
  static const TextStyle inputText = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.foreground,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.slate700,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.slate400,
  );

  static const TextStyle inputError = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.error,
  );

  /// Toast and notification styles
  static const TextStyle toastText = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.toastText,
  );

  /// Coming soon styles
  static const TextStyle comingSoonTitle = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.comingSoonTitle,
  );

  static const TextStyle comingSoonDescription = TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.comingSoonDescription,
  );

  // Utility Methods

  /// Creates a text style with a specific color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Creates a text style with a specific font weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Creates a text style with a specific font size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Creates a text style with opacity
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  /// Gets the appropriate text style for a heading level
  static TextStyle getHeadingStyle(int level) {
    switch (level) {
      case 1:
        return displayLarge;
      case 2:
        return displayMedium;
      case 3:
        return headingLarge;
      case 4:
        return headingMedium;
      case 5:
        return headingSmall;
      case 6:
        return bodyLarge;
      default:
        return bodyMedium;
    }
  }

  /// Gets the appropriate body text style for a size
  static TextStyle getBodyStyle(String size) {
    switch (size.toLowerCase()) {
      case 'large':
        return bodyLarge;
      case 'medium':
        return bodyMedium;
      case 'small':
        return bodySmall;
      default:
        return bodyMedium;
    }
  }

  /// Gets the appropriate label style for a size
  static TextStyle getLabelStyle(String size) {
    switch (size.toLowerCase()) {
      case 'large':
        return labelLarge;
      case 'medium':
        return labelMedium;
      case 'small':
        return labelSmall;
      default:
        return labelMedium;
    }
  }

  /// Gets the appropriate button style for a size
  static TextStyle getButtonStyle(String size) {
    switch (size.toLowerCase()) {
      case 'large':
        return buttonLarge;
      case 'medium':
        return buttonMedium;
      case 'small':
        return buttonSmall;
      default:
        return buttonMedium;
    }
  }
}
