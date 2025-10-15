import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/storage/shared_preferences_service.dart';
import '../blocs/auth_bloc.dart';

/// Login page with Google sign-in and decorative background
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Check if profile exists
            final hasProfile = SharedPreferencesService.hasProfile;

            if (hasProfile) {
              // Profile exists, go to dashboard
              Navigator.of(context).pushReplacementNamed('/dashboard');
            } else {
              // No profile, go to onboarding
              Navigator.of(context).pushReplacementNamed('/onboarding');
            }
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding: AppSpacing.screen,
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo and title section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // App title
                        Text(
                          AppStrings.appName,
                          style: AppTextStyles.loginTitle.copyWith(
                            color: AppColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        AppSpacing.verticalSpaceXL,

                        // Subtitle
                        Text(
                          AppStrings.loginTitle,
                          style: AppTextStyles.loginBody.copyWith(
                            color: AppColors.white.withValues(
                              alpha: AppConstants.opacity95,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        AppSpacing.verticalSpaceSM,

                        Text(
                          AppStrings.loginSubtitle,
                          style: AppTextStyles.loginSubtitle.copyWith(
                            color: AppColors.white.withValues(
                              alpha: AppConstants.opacity85,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Sign-in section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Google Sign-in button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              icon:
                                  isLoading
                                      ? SizedBox(
                                        width: AppConstants.iconSize20,
                                        height: AppConstants.iconSize20,
                                        child: CircularProgressIndicator(
                                          strokeWidth:
                                              AppConstants.loadingStrokeWidth,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      )
                                      : Image.asset(
                                        'assets/icons/google_logo.png',
                                        width: AppConstants.iconSize20,
                                        height: AppConstants.iconSize20,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.g_mobiledata,
                                            size: AppConstants.iconSize28,
                                            color: AppColors.primary,
                                          );
                                        },
                                      ),
                              label: Text(
                                isLoading
                                    ? AppStrings.signingIn
                                    : AppStrings.continueWithGoogle,
                                style: AppTextStyles.buttonLarge.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.primary,
                                padding: AppSpacing.buttonLarge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppDimensions.radiusLGBorder,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      AppSpacing.verticalSpaceLG,

                      // Disclaimer text
                      Text(
                        AppStrings.mockLoginDisclaimer,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white.withValues(
                            alpha: AppConstants.opacity80,
                          ),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Terms and privacy
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: AppSpacing.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      AppStrings.termsAndPrivacy,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white.withValues(
                          alpha: AppConstants.opacity70,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                AppSpacing.verticalSpaceLG,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Alternative login page with email/password form (for future use)
class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.verticalSpaceXXL,

                // Title
                Text(AppStrings.welcomeBack, style: AppTextStyles.headingLarge),

                AppSpacing.verticalSpaceSM,

                Text(
                  AppStrings.signInToAccount,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.slate600,
                  ),
                ),

                AppSpacing.verticalSpaceXXXL,

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    hintText: AppStrings.emailPlaceholder,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!RegExp(
                      AppConstants.emailRegexPattern,
                    ).hasMatch(value)) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),

                AppSpacing.verticalSpaceLG,

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    hintText: AppStrings.passwordPlaceholder,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),

                AppSpacing.verticalSpaceLG,

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalSpaceXXL,

                // Sign in button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleEmailSignIn,
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: AppConstants.loadingIndicatorSize,
                                  height: AppConstants.loadingIndicatorSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        AppConstants.loadingStrokeWidth,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                                : const Text(AppStrings.signIn),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.slate600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to sign up
                      },
                      child: Text(
                        AppStrings.signUp,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
