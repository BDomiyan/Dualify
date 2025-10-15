import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_animations.dart';

/// Community placeholder screen
class CommunityPage extends StatefulWidget {
  final bool isInNavigationWrapper;

  const CommunityPage({super.key, this.isInNavigationWrapper = false});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
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
        title: const Text(AppStrings.community),
        backgroundColor: AppColors.cardBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show coming soon message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.notificationsComingSoon),
                ),
              );
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
                  // Large groups icon
                  Container(
                    width: AppConstants.comingSoonIconContainerSize,
                    height: AppConstants.comingSoonIconContainerSize,
                    decoration: BoxDecoration(
                      color: AppColors.comingSoonIcon.withOpacity(
                        AppConstants.opacity10,
                      ),
                      borderRadius: AppDimensions.radiusXXLBorder,
                    ),
                    child: Icon(
                      Icons.groups,
                      size: AppConstants.comingSoonIconSize,
                      color: AppColors.comingSoonIcon,
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
                    AppStrings.communityDescription,
                    style: AppTextStyles.comingSoonDescription,
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSpaceXXL,

                  // Feature highlights
                  _buildFeatureList(),

                  AppSpacing.verticalSpaceXXL,

                  // Notify me button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showNotifyDialog();
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text(AppStrings.notifyMeWhenAvailable),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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

        ...AppStrings.communityFeatures.map(
          (feature) => Padding(
            padding: AppSpacing.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: AppConstants.featureBulletSize,
                  height: AppConstants.featureBulletSize,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
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
        ),
      ],
    );
  }

  void _showNotifyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.getNotified),
            content: const Text(AppStrings.communityNotifyMessage),
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
