import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/constants.dart';

/// Header section with welcome message and notification button
class HeaderSection extends StatelessWidget {
  final String userName;
  final bool hasNotifications;
  final VoidCallback? onNotificationTap;

  const HeaderSection({
    super.key,
    required this.userName,
    this.hasNotifications = false,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.only(
        left: AppSpacing.lg,
        top: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${AppStrings.welcomePrefix}$userName',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          _NotificationButton(
            hasNotifications: hasNotifications,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool hasNotifications;
  final VoidCallback? onTap;

  const _NotificationButton({required this.hasNotifications, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppConstants.headerNotificationButtonSize,
        height: AppConstants.headerNotificationButtonSize,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: AppDimensions.shadowBlurRadius,
              offset: AppDimensions.shadowOffset,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: AppConstants.headerNotificationIconSize,
              color: AppColors.primary,
            ),
            if (hasNotifications)
              Positioned(
                top: AppConstants.headerNotificationBadgePosition,
                right: AppConstants.headerNotificationBadgePosition,
                child: Container(
                  width: AppConstants.headerNotificationBadgeSize,
                  height: AppConstants.headerNotificationBadgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: AppConstants.borderWidth2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
