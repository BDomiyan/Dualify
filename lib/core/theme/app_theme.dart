import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';
import 'app_dimensions.dart';

/// Main app theme configuration that combines all theme elements
/// Provides both light and dark theme configurations
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Use Material Design 3
      useMaterial3: true,

      // Color scheme
      colorScheme: AppColors.lightColorScheme,

      // Primary swatch
      primarySwatch: AppColors.createMaterialColor(AppColors.primary),

      // Background color
      scaffoldBackgroundColor: AppColors.dashboardBackground,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowLight,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headingMedium,
        toolbarTextStyle: AppTextStyles.bodyMedium,
        iconTheme: IconThemeData(
          color: AppColors.foreground,
          size: AppDimensions.iconLG,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.foreground,
          size: AppDimensions.iconLG,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shadowColor: AppColors.shadowLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLGBorder,
        ),
        margin: AppSpacing.all(AppSpacing.cardMargin),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.slate300,
          disabledForegroundColor: AppColors.slate500,
          elevation: 2,
          shadowColor: AppColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLGBorder,
          ),
          padding: AppSpacing.button,
          minimumSize: Size(0, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.slate400,
          side: const BorderSide(color: AppColors.borderPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLGBorder,
          ),
          padding: AppSpacing.button,
          minimumSize: Size(0, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.slate400,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLGBorder,
          ),
          padding: AppSpacing.button,
          minimumSize: Size(0, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.foreground,
          disabledForegroundColor: AppColors.slate400,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusMDBorder,
          ),
          padding: AppSpacing.all(AppSpacing.iconButtonPadding),
          minimumSize: Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        disabledElevation: 0,
        shape: CircleBorder(),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.radiusLGBorder,
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        contentPadding: AppSpacing.formField,
        labelStyle: AppTextStyles.inputLabel,
        hintStyle: AppTextStyles.inputHint,
        errorStyle: AppTextStyles.inputError,
        helperStyle: AppTextStyles.labelMedium,
        prefixIconColor: AppColors.slate500,
        suffixIconColor: AppColors.slate500,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.bottomNavActive,
        unselectedItemColor: AppColors.bottomNavInactive,
        selectedLabelStyle: AppTextStyles.navActive,
        unselectedLabelStyle: AppTextStyles.navInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.slate500,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borderLight,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slate100,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.slate200,
        deleteIconColor: AppColors.slate600,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelSmall,
        brightness: Brightness.light,
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusXLBorder,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusXLBorder,
        ),
        titleTextStyle: AppTextStyles.headingMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadowMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.slate300,
        dragHandleSize: Size(40, 4),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.toastBackground,
        contentTextStyle: AppTextStyles.toastText,
        actionTextColor: AppColors.accent,
        disabledActionTextColor: AppColors.slate400,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLGBorder,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.progressBackground,
        circularTrackColor: AppColors.progressBackground,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.slate400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.slate300;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.borderMedium),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusSMBorder,
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.slate400;
        }),
      ),

      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.progressBackground,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.selectedOverlay,
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: AppDimensions.dividerThickness,
        space: AppSpacing.lg,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.labelMedium,
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium,
        iconColor: AppColors.slate600,
        textColor: AppColors.foreground,
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.selectedOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radiusLGBorder,
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.headingLarge,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.headingMedium,
        titleMedium: AppTextStyles.headingSmall,
        titleSmall: AppTextStyles.bodyLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Primary text theme (for text on primary color)
      primaryTextTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.headingLarge,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.headingMedium,
        titleMedium: AppTextStyles.headingSmall,
        titleSmall: AppTextStyles.bodyLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ).apply(bodyColor: AppColors.white, displayColor: AppColors.white),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
        size: AppDimensions.iconLG,
      ),

      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.white,
        size: AppDimensions.iconLG,
      ),

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash factory
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Dark theme configuration (for future dark mode support)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      primarySwatch: AppColors.createMaterialColor(AppColors.primary),
      scaffoldBackgroundColor: AppColors.darkColorScheme.surface,

      // Copy light theme and modify colors for dark mode
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: AppColors.darkColorScheme.surface,
        foregroundColor: AppColors.darkColorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: lightTheme.cardTheme.copyWith(
        color: AppColors.darkColorScheme.surface,
      ),

      // Apply dark theme modifications to other components as needed
      textTheme: lightTheme.textTheme.apply(
        bodyColor: AppColors.darkColorScheme.onSurface,
        displayColor: AppColors.darkColorScheme.onSurface,
      ),

      iconTheme: IconThemeData(
        color: AppColors.darkColorScheme.onSurface,
        size: AppDimensions.iconLG,
      ),

      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: lightTheme.pageTransitionsTheme,
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Gets the appropriate theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// System UI overlay styles
  static const SystemUiOverlayStyle lightSystemUiOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bottomNavBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkSystemUiOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF1E293B),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Gets the appropriate system UI overlay style
  static SystemUiOverlayStyle getSystemUiOverlayStyle(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkSystemUiOverlay
        : lightSystemUiOverlay;
  }
}
