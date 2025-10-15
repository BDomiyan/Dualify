/// Application-wide numeric and configuration constants
/// Centralized location for all non-UI constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============================================================================
  // WIDGET DIMENSIONS (Commonly used sizes)
  // ============================================================================
  static const double iconSize40 = 40.0;
  static const double iconSize48 = 48.0;
  static const double iconSize64 = 64.0;
  static const double iconSize28 = 28.0;
  static const double iconSize24 = 24.0;
  static const double iconSize20 = 20.0;
  static const double iconSize12 = 12.0;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================
  static const double borderWidth1 = 1.0;
  static const double borderWidth2 = 2.0;
  static const double borderWidth3 = 3.0;

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================
  static const double opacity05 = 0.05;
  static const double opacity10 = 0.1;
  static const double opacity15 = 0.15;
  static const double opacity20 = 0.2;
  static const double opacity30 = 0.3;
  static const double opacity50 = 0.5;
  static const double opacity70 = 0.7;
  static const double opacity80 = 0.8;
  static const double opacity85 = 0.85;
  static const double opacity90 = 0.9;
  static const double opacity95 = 0.95;

  // ============================================================================
  // ELEVATION VALUES
  // ============================================================================
  static const double elevation0 = 0.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation16 = 16.0;

  // ============================================================================
  // DAILY LOG CARD
  // ============================================================================
  static const double dailyLogCardWidth = 112.0;
  static const double dailyLogCardHeight = 160.0;
  static const double dailyLogCardSpacing = 12.0;
  static const double dailyLogDotSize = 6.0;

  // ============================================================================
  // PROGRESS RING
  // ============================================================================
  static const double progressRingSize = 208.0;
  static const double progressStrokeWidth = 20.0;
  static const double progressStrokePadding = 16.0;

  // ============================================================================
  // VERIFICATION CARD
  // ============================================================================
  static const double verificationIconContainerSize = 64.0;
  static const double verificationIconSize = 36.0;
  static const double verificationBadgeSize = 40.0;

  // ============================================================================
  // HEADER SECTION
  // ============================================================================
  static const double headerNotificationButtonSize = 48.0;
  static const double headerNotificationIconSize = 28.0;
  static const double headerNotificationBadgeSize = 12.0;
  static const double headerNotificationBadgePosition = 10.0;

  // ============================================================================
  // QUESTION CARD
  // ============================================================================
  static const double questionCardRefreshButtonSize = 40.0;
  static const double questionCardRefreshIconSize = 20.0;

  // ============================================================================
  // BACKGROUND DECORATIONS
  // ============================================================================
  static const int backgroundIconCount = 12;
  static const int backgroundRandomSeed = 42;
  static const double backgroundMinIconSize = 20.0;
  static const double backgroundMaxIconSizeRange = 40.0;
  static const int backgroundMaxAnimationDelay = 2000;
  static const int backgroundBaseAnimationDuration = 8000;
  static const int backgroundAnimationDurationRange = 4000;
  static const double backgroundMinScale = 0.8;
  static const double backgroundMaxScale = 1.2;
  static const double backgroundGridSpacing = 60.0;
  static const double backgroundGridStrokeWidth = 1.0;
  static const double backgroundDiagonalStrokeWidth = 0.5;
  static const double backgroundDiagonalSpacingMultiplier = 2.0;
  static const double backgroundFloatRangeStart = -10.0;
  static const double backgroundFloatRangeEnd = 10.0;

  // ============================================================================
  // ANIMATION DURATIONS (milliseconds)
  // ============================================================================
  static const int animationDuration150 = 150;
  static const int animationDuration200 = 200;
  static const int animationDuration300 = 300;
  static const int animationDuration500 = 500;
  static const int animationDuration800 = 800;
  static const int animationDuration1200 = 1200;
  static const int animationDuration1500 = 1500;
  static const int animationDuration2000 = 2000;
  static const int animationDuration6000 = 6000;

  // ============================================================================
  // SCALE VALUES
  // ============================================================================
  static const double scaleMin = 0.5;
  static const double scalePeak = 1.1;
  static const double scaleNormal = 1.0;
  static const int scaleUpWeight = 80;
  static const int scaleDownWeight = 20;

  // ============================================================================
  // SCROLL BEHAVIOR
  // ============================================================================
  static const double scrollDivisor = 2.0;

  // ============================================================================
  // VALIDATION LIMITS
  // ============================================================================
  static const int minApprenticeDurationMonths = 6;
  static const int maxApprenticeDurationMonths = 96; // 8 years
  static const int minPasswordLength = 6;
  static const int maxYearsInPast = 5;
  static const int maxYearsInFuture = 10;

  // ============================================================================
  // SNACKBAR DURATIONS
  // ============================================================================
  static const int snackbarDurationShort = 2; // seconds
  static const int snackbarDurationMedium = 4; // seconds
  static const int snackbarDurationLong = 6; // seconds

  // ============================================================================
  // LOADING INDICATOR
  // ============================================================================
  static const double loadingIndicatorSize = 20.0;
  static const double loadingStrokeWidth = 2.0;

  // ============================================================================
  // CHAT PREVIEW
  // ============================================================================
  static const double chatPreviewIconSize = 32.0;
  static const double chatPreviewIconContainerSize = 32.0;

  // ============================================================================
  // FEATURE LIST
  // ============================================================================
  static const double featureBulletSize = 6.0;

  // ============================================================================
  // COMING SOON ICON CONTAINER
  // ============================================================================
  static const double comingSoonIconContainerSize = 120.0;
  static const double comingSoonIconSize = 64.0;

  // ============================================================================
  // STATUS SELECTION SHEET
  // ============================================================================
  static const double statusOptionEmojiSize = 32.0;

  // ============================================================================
  // REGEX PATTERNS
  // ============================================================================
  static const String emailRegexPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // ============================================================================
  // ANIMATION VALUES
  // ============================================================================
  static const double animationSlideOffset = 0.3;
  static const double animationScaleStart = 0.8;
  static const double animationScaleEnd = 1.0;
  static const double animationRotationStart = 0.0;
  static const double animationRotationEnd = 0.1;

  // ============================================================================
  // DELAYS (milliseconds)
  // ============================================================================
  static const int splashInitialDelay = 1500;
  static const int splashAnimationDelay = 300;
  static const int navigationDelay = 2000;

  // ============================================================================
  // DATE PICKER RANGES
  // ============================================================================
  static const int datePickerYearsPast = 5;
  static const int datePickerYearsFuture = 10;
  static const int daysInYear = 365;

  // ============================================================================
  // SPLASH SCREEN
  // ============================================================================
  static const double splashLogoSize = 120.0;
  static const double splashLogoIconSize = 64.0;
  static const double splashLoadingIndicatorSize = 32.0;
  static const double splashLoadingStrokeWidth = 3.0;
  static const double splashShadowBlurRadius = 20.0;
  static const double splashShadowSpread = 2.0;
  static const double splashShadowOffsetX = 2.0;
  static const double splashShadowOffsetY = 2.0;
  static const double splashShadowBlur = 4.0;
  static const int splashLogoFlexRatio = 3;
  static const int splashLoadingFlexRatio = 2;
  static const int splashDisplayDurationSeconds = 3;

  // ============================================================================
  // MAIN NAVIGATION
  // ============================================================================
  static const int mainNavigationAnimationDuration = 300;

  // ============================================================================
  // DEFAULT VALUES
  // ============================================================================
  static const String defaultUserName = 'User';
  static const String defaultLastName = 'Apprentice';
  static const int defaultDaysToGenerate = 7;
  static const int defaultDaysOffset = 6;
}
