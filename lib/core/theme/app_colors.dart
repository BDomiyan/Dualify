import 'package:flutter/material.dart';

/// Comprehensive color system for the Dualify Dashboard
/// Contains all color constants from the HTML design with proper organization
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF004C99);
  static const Color accent = Color(0xFF00CC99);

  // Background Colors
  static const Color dashboardBackground = Color(0xFFF0F4F8);
  static const Color loginBackground = Color(0xFFF5F7F8);
  static const Color comingSoonBackground = Color(0xFFF6F7F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFFAFBFC);

  // Text Colors
  static const Color foreground = Color(0xFF1A202C);
  static const Color foregroundSecondary = Color(0xFF2D3748);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // White Variations
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteTransparent90 = Color(0xE6FFFFFF);
  static const Color whiteTransparent80 = Color(0xCCFFFFFF);
  static const Color whiteTransparent70 = Color(0xB3FFFFFF);
  static const Color whiteTransparent50 = Color(0x80FFFFFF);

  // Status Colors for Daily Logs
  static const Color statusLearning = Color(0xFF87CEEB); // Sky blue
  static const Color statusChallenging = Color(0xFFFFD700); // Gold
  static const Color statusNeutral = Color(0xFFD3D3D3); // Light gray
  static const Color statusGood = Color(0xFF90EE90); // Light green

  // Success and Error Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Interactive State Colors
  static const Color hoverOverlay = Color(0x0A000000); // 4% black overlay
  static const Color pressedOverlay = Color(0x14000000); // 8% black overlay
  static const Color focusOverlay = Color(0x1F000000); // 12% black overlay
  static const Color selectedOverlay = Color(0x14004C99); // 8% primary overlay

  // Shadow and Glow Colors
  static const Color shadowLight = Color(0x0A000000); // Light shadow
  static const Color shadowMedium = Color(0x14000000); // Medium shadow
  static const Color shadowDark = Color(0x1F000000); // Dark shadow
  static const Color glowAccent = Color(
    0x4000CC99,
  ); // Accent glow (25% opacity)
  static const Color glowPrimary = Color(
    0x40004C99,
  ); // Primary glow (25% opacity)

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  static const Color borderAccent = Color(0xFF00CC99);
  static const Color borderPrimary = Color(0xFF004C99);

  // Verification Badge Colors
  static const Color verifiedBadge = Color(0xFF10B981);
  static const Color verifiedBadgeBackground = Color(0xFFD1FAE5);
  static const Color unverifiedBadge = Color(0xFF6B7280);
  static const Color unverifiedBadgeBackground = Color(0xFFF3F4F6);

  // Progress Colors
  static const Color progressBackground = Color(0xFFE5E7EB);
  static const Color progressForeground = accent;
  static const Color progressGlow = glowAccent;

  // Bottom Navigation Colors
  static const Color bottomNavBackground = Color(0xFFFAFBFC);
  static const Color bottomNavBorder = Color(0xFFE5E7EB);
  static const Color bottomNavActive = primary;
  static const Color bottomNavInactive = Color(0xFF6B7280);

  // Login Screen Specific Colors
  static const Color loginTitleShadow = Color(0x40000000); // 25% black shadow
  static const Color loginButtonBackground = primary;
  static const Color loginButtonText = white;
  static const Color loginBodyText = slate600;
  static const Color loginIconsOverlay = Color(
    0x26000000,
  ); // 15% black for background icons

  // Coming Soon Screen Colors
  static const Color comingSoonIcon = slate400;
  static const Color comingSoonTitle = slate800;
  static const Color comingSoonDescription = slate600;

  // Toast and Notification Colors
  static const Color toastBackground = Color(0xFF374151);
  static const Color toastText = white;
  static const Color toastBorder = Color(0xFF4B5563);

  // Skeleton Loading Colors
  static const Color skeletonBase = Color(0xFFE5E7EB);
  static const Color skeletonHighlight = Color(0xFFF3F4F6);

  // Helper Methods

  /// Gets the appropriate text color for a given background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? foreground : white;
  }

  /// Gets the status color for a daily log status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'learning':
        return statusLearning;
      case 'challenging':
        return statusChallenging;
      case 'neutral':
        return statusNeutral;
      case 'good':
        return statusGood;
      default:
        return statusNeutral;
    }
  }

  /// Gets a lighter version of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Gets a darker version of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Gets a color with specified opacity
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1');
    return color.withOpacity(opacity);
  }

  /// Creates a Material color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  /// Color palette for theming
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: accent,
    onSecondary: white,
    tertiary: statusLearning,
    onTertiary: foreground,
    error: error,
    onError: white,
    surface: cardBackground,
    onSurface: foreground,
    outline: borderMedium,
    outlineVariant: borderLight,
    shadow: shadowMedium,
    scrim: Color(0x80000000),
    inverseSurface: slate800,
    onInverseSurface: white,
    inversePrimary: Color(0xFF7BB3FF),
    surfaceTint: primary,
  );

  /// Dark color scheme (for future dark mode support)
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7BB3FF),
    onPrimary: Color(0xFF003366),
    secondary: Color(0xFF66E6CC),
    onSecondary: Color(0xFF003D33),
    tertiary: Color(0xFFB3E0FF),
    onTertiary: Color(0xFF001F33),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF330000),
    surface: Color(0xFF1E293B),
    onSurface: Color(0xFFF1F5F9),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
    shadow: Color(0xFF000000),
    scrim: Color(0x80000000),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF1E293B),
    inversePrimary: primary,
    surfaceTint: Color(0xFF7BB3FF),
  );
}
