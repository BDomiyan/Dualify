import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_animations.dart';

/// AI Assistant placeholder screen
class AiAssistantPage extends StatefulWidget {
  final bool isInNavigationWrapper;

  const AiAssistantPage({super.key, this.isInNavigationWrapper = false});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.comingSoonBackground,
      appBar: AppBar(
        title: const Text(AppStrings.aiAssistant),
        backgroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large support agent icon
                  Container(
                    width: AppConstants.comingSoonIconContainerSize,
                    height: AppConstants.comingSoonIconContainerSize,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(
                        AppConstants.opacity10,
                      ),
                      borderRadius: AppDimensions.radiusXXLBorder,
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: AppConstants.comingSoonIconSize,
                      color: AppColors.accent,
                    ),
                  ),

                  AppSpacing.verticalSpaceXXL,

                  // Coming Soon title
                  Text(
                    AppStrings.comingSoon,
                    style: AppTextStyles.comingSoonTitle,
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSpaceLG,

                  // Description
                  Text(
                    AppStrings.aiAssistantDescription,
                    style: AppTextStyles.comingSoonDescription,
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSpaceXXL,

                  // Feature highlights
                  _buildFeatureList(),

                  AppSpacing.verticalSpaceXXL,

                  // Chat preview
                  _buildChatPreview(),

                  AppSpacing.verticalSpaceXXL,

                  // Notify me button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showNotifyDialog();
                    },
                    icon: const Icon(Icons.smart_toy),
                    label: const Text(AppStrings.notifyMeWhenAvailable),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      padding: AppSpacing.buttonLarge,
                    ),
                  ),

                  AppSpacing.verticalSpaceXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.whatToExpect,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.slate700,
          ),
        ),

        AppSpacing.verticalSpaceMD,

        ...AppStrings.aiAssistantFeatures
            .map(
              (feature) => Padding(
                padding: AppSpacing.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: AppConstants.featureBulletSize,
                      height: AppConstants.featureBulletSize,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),

                    AppSpacing.horizontalSpaceSM,

                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.slate600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildChatPreview() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppDimensions.radiusLGBorder,
        border: Border.all(
          color: AppColors.borderLight,
          width: AppConstants.borderWidth1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: AppConstants.elevation4,
            offset: const Offset(
              AppConstants.elevation0,
              AppConstants.elevation2,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppConstants.chatPreviewIconContainerSize,
                height: AppConstants.chatPreviewIconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(AppConstants.opacity10),
                  borderRadius: AppDimensions.radiusMDBorder,
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: AppConstants.iconSize20,
                  color: AppColors.accent,
                ),
              ),

              AppSpacing.horizontalSpaceSM,

              Text(
                AppStrings.aiAssistantPreviewTitle,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceMD,

          Container(
            padding: AppSpacing.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: AppDimensions.radiusMDBorder,
            ),
            child: Text(
              AppStrings.aiAssistantPreviewChat,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.slate600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.aboutAiAssistantTitle),
            content: const Text(AppStrings.aboutAiAssistantMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.gotIt),
              ),
            ],
          ),
    );
  }

  void _showNotifyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.getNotified),
            content: const Text(AppStrings.aiAssistantNotifyMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.gotIt),
              ),
            ],
          ),
    );
  }
}
