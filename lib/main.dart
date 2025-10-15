import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'presentation/features/auth/blocs/auth_bloc.dart';
import 'presentation/features/profile/blocs/profile_bloc.dart';
import 'presentation/features/dashboard/blocs/dashboard_bloc.dart';
import 'presentation/features/onboarding/blocs/onboarding_bloc.dart';
import 'presentation/features/auth/pages/login_page.dart';
import 'presentation/features/splash/pages/splash_page.dart';
import 'presentation/features/onboarding/pages/onboarding_page.dart';
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

    AppLogger.info('App initialized successfully');

    runApp(const DualifyApp());
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);

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
        title: 'Dualify Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Routes
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/onboarding': (context) => const OnboardingPage(),
          '/dashboard': (context) => const MainNavigationPage(initialIndex: 0),
          '/main': (context) => const MainNavigationPage(),
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
      title: 'Dualify Dashboard - Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Start App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
