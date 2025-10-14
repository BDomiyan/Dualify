import 'package:flutter/material.dart';

/// Comprehensive dimension system for the Dualify Dashboard
/// Contains all size constants for components and layouts
class AppDimensions {
  // Private constructor to prevent instantiation
  AppDimensions._();

  // Border radius constants
  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusRound = 999.0; // For fully rounded elements

  // Component sizes
  static const double progressCircleSize = 120.0;
  static const double progressStrokeWidth = 8.0;
  static const double dayCardSize = 48.0;
  static const double dayCardHeight = 72.0;
  static const double iconButtonSize = 40.0;
  static const double fabSize = 56.0;
  static const double avatarSize = 40.0;
  static const double avatarSizeLarge = 64.0;

  // Interactive area dimensions
  static const double minTouchTarget = 44.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;

  // Navigation dimensions
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;

  // Layout constraints
  static const double maxContentWidth = 400.0;
  static const double maxCardWidth = 320.0;
  static const double minScreenWidth = 320.0;

  // Form dimensions
  static const double inputHeight = 48.0;
  static const double inputHeightSmall = 36.0;
  static const double inputHeightLarge = 56.0;
  static const double dropdownMaxHeight = 200.0;

  // Modal dimensions
  static const double modalMaxWidth = 400.0;
  static const double modalMaxHeight = 600.0;
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen height

  // Card dimensions
  static const double cardMinHeight = 80.0;
  static const double profileCardHeight = 120.0;
  static const double qotdCardMinHeight = 100.0;

  // Icon sizes
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // Badge dimensions
  static const double badgeSize = 20.0;
  static const double badgeSizeSmall = 16.0;
  static const double badgeSizeLarge = 24.0;

  // Divider dimensions
  static const double dividerThickness = 1.0;
  static const double dividerThicknessBold = 2.0;

  // Shadow dimensions
  static const double shadowBlurRadius = 8.0;
  static const double shadowBlurRadiusLarge = 16.0;
  static const Offset shadowOffset = Offset(0, 2);
  static const Offset shadowOffsetLarge = Offset(0, 4);

  // Animation dimensions
  static const double hoverScale = 1.02;
  static const double pressedScale = 0.98;
  static const double popScale = 1.1;
  static const double translateYHover = -2.0;
  static const double translateYPressed = 1.0;

  // Utility methods

  /// Creates BorderRadius with all corners equal
  static BorderRadius circular(double radius) => BorderRadius.circular(radius);

  /// Creates BorderRadius with only specific corners
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );

  /// Predefined border radius values
  static BorderRadius get radiusXSBorder => circular(radiusXS);
  static BorderRadius get radiusSMBorder => circular(radiusSM);
  static BorderRadius get radiusMDBorder => circular(radiusMD);
  static BorderRadius get radiusLGBorder => circular(radiusLG);
  static BorderRadius get radiusXLBorder => circular(radiusXL);
  static BorderRadius get radiusXXLBorder => circular(radiusXXL);
  static BorderRadius get radiusRoundBorder => circular(radiusRound);

  /// Creates Size with equal width and height
  static Size square(double size) => Size(size, size);

  /// Predefined sizes
  static Size get iconSizeXS => square(iconXS);
  static Size get iconSizeSM => square(iconSM);
  static Size get iconSizeMD => square(iconMD);
  static Size get iconSizeLG => square(iconLG);
  static Size get iconSizeXL => square(iconXL);
  static Size get iconSizeXXL => square(iconXXL);

  /// Creates BoxConstraints with minimum dimensions
  static BoxConstraints minSize({double width = 0, double height = 0}) =>
      BoxConstraints(minWidth: width, minHeight: height);

  /// Creates BoxConstraints with maximum dimensions
  static BoxConstraints maxSize({
    double width = double.infinity,
    double height = double.infinity,
  }) => BoxConstraints(maxWidth: width, maxHeight: height);

  /// Creates BoxConstraints with fixed dimensions
  static BoxConstraints fixedSize({
    required double width,
    required double height,
  }) => BoxConstraints.tightFor(width: width, height: height);

  /// Responsive breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  /// Checks if screen width is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Checks if screen width is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Checks if screen width is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Gets responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}
