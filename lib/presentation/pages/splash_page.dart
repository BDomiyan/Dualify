import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';
import '../../core/storage/shared_preferences_service.dart';
import '../blocs/profile/profile_bloc.dart';

/// Splash screen that handles initial app routing
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _startAnimations();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppAnimations.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: AppAnimations.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.easeOut),
    );
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: AppConstants.splashAnimationDelay), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  void _checkAuthStatus() {
    // Wait for animations to complete before checking navigation
    Future.delayed(const Duration(milliseconds: AppConstants.splashInitialDelay), () {
      if (mounted) {
        _determineInitialRoute();
      }
    });
  }

  void _determineInitialRoute() {
    // Import SharedPreferencesService
    final hasProfile =
        context.read<ProfileBloc>().state is ProfileLoaded ||
        SharedPreferencesService.hasProfile;

    if (hasProfile) {
      // Profile exists, go directly to dashboard
      _navigateToDashboard();
    } else {
      // No profile, go to login
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const Spacer(flex: 2),

          // Logo and title
          AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Transform.rotate(
                  angle: _logoRotationAnimation.value,
                  child: Column(
                    children: [
                      // App icon/logo
                      Container(
                        width: AppConstants.splashLogoSize,
                        height: AppConstants.splashLogoSize,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppDimensions.radiusXXLBorder,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(AppConstants.opacity20),
                              blurRadius: AppConstants.splashShadowBlurRadius,
                              spreadRadius: AppConstants.splashShadowSpread,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          size: AppConstants.splashLogoIconSize,
                          color: AppColors.primary,
                        ),
                      ),

                      AppSpacing.verticalSpaceXL,

                      // App title
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(AppConstants.splashShadowOffsetX, AppConstants.splashShadowOffsetY),
                              blurRadius: AppConstants.splashShadowBlur,
                              color: Colors.black.withOpacity(AppConstants.opacity30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Spacer(),

          // Loading indicator and subtitle
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Loading indicator
                SizedBox(
                  width: AppConstants.splashLoadingIndicatorSize,
                  height: AppConstants.splashLoadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppConstants.splashLoadingStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),

                AppSpacing.verticalSpaceLG,

                // Subtitle
                Text(
                  AppStrings.settingUpJourney,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(AppConstants.opacity90),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Version info
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: AppSpacing.screen,
              child: Text(
                AppStrings.appVersion,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white.withOpacity(AppConstants.opacity70),
                ),
              ),
            ),
          ),

          AppSpacing.verticalSpaceLG,
        ],
      ),
    );
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateToDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }
}

/// Alternative minimal splash screen
class MinimalSplashPage extends StatefulWidget {
  const MinimalSplashPage({super.key});

  @override
  State<MinimalSplashPage> createState() => _MinimalSplashPageState();
}

class _MinimalSplashPageState extends State<MinimalSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _controller.forward();

    // Navigate after delay
    Future.delayed(const Duration(milliseconds: AppConstants.navigationDelay), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: AppConstants.iconSize64 + AppConstants.iconSize20, color: AppColors.white),

              AppSpacing.verticalSpaceLG,

              Text(
                AppStrings.appName,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
