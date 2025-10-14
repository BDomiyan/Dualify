import 'package:flutter/material.dart';

/// Comprehensive spacing system for the Dualify Dashboard
/// Uses a 4px base unit system for consistent spacing throughout the app
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base unit (4px)
  static const double _baseUnit = 4.0;

  // Spacing Scale (based on 4px units)
  static const double xs = _baseUnit; // 4px
  static const double sm = _baseUnit * 2; // 8px
  static const double md = _baseUnit * 3; // 12px
  static const double lg = _baseUnit * 4; // 16px
  static const double xl = _baseUnit * 5; // 20px
  static const double xxl = _baseUnit * 6; // 24px
  static const double xxxl = _baseUnit * 8; // 32px

  // Component-specific spacing
  static const double cardPadding = lg; // 16px
  static const double cardMargin = md; // 12px
  static const double sectionSpacing = xxl; // 24px
  static const double elementSpacing = md; // 12px
  static const double listItemSpacing = sm; // 8px

  // Layout spacing
  static const double screenPadding = lg; // 16px
  static const double screenMargin = xl; // 20px
  static const double contentSpacing = xxl; // 24px
  static const double headerSpacing = xl; // 20px

  // Form spacing
  static const double formFieldSpacing = lg; // 16px
  static const double formSectionSpacing = xxl; // 24px
  static const double inputPadding = md; // 12px
  static const double labelSpacing = sm; // 8px

  // Button spacing
  static const double buttonPadding = md; // 12px
  static const double buttonSpacing = lg; // 16px
  static const double iconButtonPadding = sm; // 8px

  // Navigation spacing
  static const double bottomNavPadding = sm; // 8px
  static const double tabSpacing = lg; // 16px

  // Daily log spacing
  static const double dayCardSpacing = sm; // 8px
  static const double dayCardPadding = md; // 12px
  static const double calendarSpacing = xs; // 4px

  // Progress circle spacing
  static const double progressSpacing = lg; // 16px
  static const double progressLabelSpacing = sm; // 8px

  // Profile card spacing
  static const double profileCardSpacing = md; // 12px
  static const double profileCardPadding = lg; // 16px
  static const double badgeSpacing = xs; // 4px

  // Toast spacing
  static const double toastPadding = md; // 12px
  static const double toastMargin = lg; // 16px

  // Modal spacing
  static const double modalPadding = xl; // 20px
  static const double modalSpacing = lg; // 16px

  // Utility methods

  /// Creates EdgeInsets with all sides equal
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Creates EdgeInsets with symmetric horizontal and vertical spacing
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Creates EdgeInsets with only specific sides
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  /// Creates EdgeInsets for screen padding
  static EdgeInsets get screen => all(screenPadding);

  /// Creates EdgeInsets for card padding
  static EdgeInsets get card => all(cardPadding);

  /// Creates EdgeInsets for form fields
  static EdgeInsets get formField =>
      symmetric(horizontal: inputPadding, vertical: inputPadding);

  /// Creates EdgeInsets for buttons
  static EdgeInsets get button =>
      symmetric(horizontal: buttonPadding * 2, vertical: buttonPadding);

  /// Creates EdgeInsets for large buttons
  static EdgeInsets get buttonLarge =>
      symmetric(horizontal: lg * 2, vertical: lg);

  /// Creates EdgeInsets for small buttons
  static EdgeInsets get buttonSmall =>
      symmetric(horizontal: sm * 2, vertical: sm);

  /// Creates SizedBox with vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Creates SizedBox with horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// Predefined vertical spacers
  static Widget get verticalSpaceXS => verticalSpace(xs);
  static Widget get verticalSpaceSM => verticalSpace(sm);
  static Widget get verticalSpaceMD => verticalSpace(md);
  static Widget get verticalSpaceLG => verticalSpace(lg);
  static Widget get verticalSpaceXL => verticalSpace(xl);
  static Widget get verticalSpaceXXL => verticalSpace(xxl);
  static Widget get verticalSpaceXXXL => verticalSpace(xxxl);

  /// Predefined horizontal spacers
  static Widget get horizontalSpaceXS => horizontalSpace(xs);
  static Widget get horizontalSpaceSM => horizontalSpace(sm);
  static Widget get horizontalSpaceMD => horizontalSpace(md);
  static Widget get horizontalSpaceLG => horizontalSpace(lg);
  static Widget get horizontalSpaceXL => horizontalSpace(xl);
  static Widget get horizontalSpaceXXL => horizontalSpace(xxl);
  static Widget get horizontalSpaceXXXL => horizontalSpace(xxxl);
}
