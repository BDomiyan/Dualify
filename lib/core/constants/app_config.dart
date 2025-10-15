/// Application configuration constants
/// Contains app-level settings, routes, and configuration values
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // ============================================================================
  // APP INFORMATION
  // ============================================================================
  static const String appName = 'Dualify Dashboard';
  static const String appTitle = 'Dualify Dashboard';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Track your apprenticeship journey';

  // ============================================================================
  // APP SETTINGS
  // ============================================================================
  static const bool debugShowCheckedModeBanner = false;

  // ============================================================================
  // ROUTES
  // ============================================================================
  static const String routeRoot = '/';
  static const String routeLogin = '/login';
  static const String routeOnboarding = '/onboarding';
  static const String routeDashboard = '/dashboard';
  static const String routeMain = '/main';

  // ============================================================================
  // ERROR PAGE
  // ============================================================================
  static const String errorPageTitle = 'Dualify Dashboard - Error';
  static const String errorPageHeading = 'Failed to Start App';
  static const String errorRetryButtonText = 'Retry';

  // ============================================================================
  // THEME MODE
  // ============================================================================
  static const String themeModeSystem = 'system';
  static const String themeModeLight = 'light';
  static const String themeModeDark = 'dark';

  // ============================================================================
  // NAVIGATION
  // ============================================================================
  static const int mainNavigationInitialIndex = 0;

  // ============================================================================
  // LOGGING
  // ============================================================================
  static const String logAppInitSuccess = 'App initialized successfully';
  static const String logAppInitFailed = 'Failed to initialize app';
}
