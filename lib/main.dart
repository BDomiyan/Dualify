import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_config.dart';
import 'core/constants/ui_icons.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'presentation/features/auth/blocs/auth_bloc.dart';
import 'presentation/features/auth/pages/login_page.dart';
import 'presentation/features/dashboard/blocs/dashboard_bloc.dart';
import 'presentation/features/onboarding/blocs/onboarding_bloc.dart';
import 'presentation/features/onboarding/pages/onboarding_page.dart';
import 'presentation/features/profile/blocs/profile_bloc.dart';
import 'presentation/features/splash/pages/splash_page.dart';
import 'presentation/navigation/main_navigation_page.dart';

/// Main entry point of the Dualify Dashboard application
/// Initializes dependencies and starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependency injection
    await di.initializeDependencies();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(AppTheme.lightSystemUiOverlay);

    AppLogger.info(AppConfig.logAppInitSuccess);

    runApp(const DualifyApp());
  } catch (e, stackTrace) {
    AppLogger.error(AppConfig.logAppInitFailed, e, stackTrace);

    // Run a minimal error app
    runApp(ErrorApp(error: e.toString()));
  }
}

/// Main application widget
class DualifyApp extends StatelessWidget {
  const DualifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di.sl<AuthBloc>()),
        BlocProvider<ProfileBloc>(create: (context) => di.sl<ProfileBloc>()),
        BlocProvider<DashboardBloc>(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider<OnboardingBloc>(
          create: (context) => di.sl<OnboardingBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appTitle,
        debugShowCheckedModeBanner: AppConfig.debugShowCheckedModeBanner,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Routes
        initialRoute: AppConfig.routeRoot,
        routes: {
          AppConfig.routeRoot: (context) => const SplashPage(),
          AppConfig.routeLogin: (context) => const LoginPage(),
          AppConfig.routeOnboarding: (context) => const OnboardingPage(),
          AppConfig.routeDashboard:
              (context) => const MainNavigationPage(
                initialIndex: AppConfig.mainNavigationInitialIndex,
              ),
          AppConfig.routeMain: (context) => const MainNavigationPage(),
        },

        // Error handling
        builder: (context, child) {
          // Handle system UI overlay style changes
          final brightness = Theme.of(context).brightness;
          SystemChrome.setSystemUIOverlayStyle(
            AppTheme.getSystemUiOverlayStyle(brightness),
          );

          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Error app shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.errorPageTitle,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  UIIcons.errorIconOutline,
                  size: UIIcons.errorIconSize,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppConfig.errorPageHeading,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: Text(AppConfig.errorRetryButtonText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
