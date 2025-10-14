import 'package:flutter/material.dart' hide Colors;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart' as material show Colors;
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_animations.dart';
import '../../core/constants/constants.dart';

/// Verification card for company or school with verification status
class VerificationCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isVerified;
  final VoidCallback? onTap;
  final Color iconBackgroundColor;

  const VerificationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isVerified,
    this.onTap,
    required this.iconBackgroundColor,
  });

  @override
  State<VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<VerificationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppAnimations.cardHover,
          curve: AppAnimations.cardHoverCurve,
          transform:
              Matrix4.identity()..translateByVector3(
                Vector3(0.0, _isHovered ? AppAnimations.hoverTranslateY * 2 : 0.0, 0.0),
              ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppDimensions.radiusLGBorder,
            border: Border.all(
              color: widget.isVerified ? AppColors.borderAccent : material.Colors.transparent,
              width: AppConstants.borderWidth2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? (widget.isVerified
                            ? AppColors.accent.withOpacity(AppConstants.opacity30)
                            : material.Colors.black.withValues(alpha: AppConstants.opacity10))
                        : material.Colors.black.withValues(alpha: AppConstants.opacity05),
                blurRadius: _isHovered ? AppDimensions.shadowBlurRadiusLarge : AppDimensions.shadowBlurRadius,
                offset: _isHovered ? AppDimensions.shadowOffsetLarge : AppDimensions.shadowOffset,
              ),
            ],
          ),
          padding: AppSpacing.all(AppSpacing.lg),
          child: Row(
            children: [
              // Icon container
              Container(
                width: AppConstants.verificationIconContainerSize,
                height: AppConstants.verificationIconContainerSize,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor,
                  borderRadius: AppDimensions.radiusMDBorder,
                ),
                child: Icon(
                  widget.icon,
                  size: AppConstants.verificationIconSize,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.horizontalSpaceLG,
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            widget.isVerified
                                ? AppColors.primary
                                : AppColors.slate500,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      widget.title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              // Verification badge
              _VerificationBadge(isVerified: widget.isVerified),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatefulWidget {
  final bool isVerified;

  const _VerificationBadge({required this.isVerified});

  @override
  State<_VerificationBadge> createState() => _VerificationBadgeState();
}

class _VerificationBadgeState extends State<_VerificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: AppConstants.scaleMin, end: AppConstants.scalePeak),
        weight: AppConstants.scaleUpWeight.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: AppConstants.scalePeak, end: AppConstants.scaleNormal),
        weight: AppConstants.scaleDownWeight.toDouble(),
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOut,
    ));

    if (widget.isVerified) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVerified) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: AppConstants.verificationBadgeSize,
                  height: AppConstants.verificationBadgeSize,
                  decoration: BoxDecoration(
                    color: AppColors.verifiedBadge,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: AppColors.white,
                    size: AppConstants.iconSize24,
                  ),
                ),
              );
            },
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            AppStrings.verifiedLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.verifiedBadge,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppConstants.verificationBadgeSize,
            height: AppConstants.verificationBadgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.unverifiedBadge,
                width: AppConstants.borderWidth2,
              ),
            ),
            child: Icon(
              Icons.add,
              color: AppColors.unverifiedBadge,
              size: AppConstants.iconSize24,
            ),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            AppStrings.notVerifiedLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
        ],
      );
    }
  }
}
