import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_animations.dart';
import '../../core/constants/constants.dart';

/// Question of the day card with blue background
class QuestionCard extends StatefulWidget {
  final String question;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewResponses;

  const QuestionCard({
    super.key,
    required this.question,
    this.onRefresh,
    this.onViewResponses,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: AppAnimations.refreshRotation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    _rotationController.forward(from: 0.0);
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.cardHover,
        curve: AppAnimations.cardHoverCurve,
        transform: Matrix4.identity()..translate(
          0.0,
          _isHovered ? AppAnimations.hoverTranslateY * 2 : 0.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppDimensions.radiusXLBorder,
          boxShadow: [
            BoxShadow(
              color:
                  _isHovered
                      ? Colors.black.withOpacity(AppConstants.opacity15)
                      : Colors.black.withOpacity(AppConstants.opacity10),
              blurRadius: _isHovered ? 20 : 15,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        padding: AppSpacing.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and refresh button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.questionOfTheDayTitle,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                AppSpacing.horizontalSpaceSM,
                GestureDetector(
                  onTap: _handleRefresh,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * AppAnimations.refreshRotationAngle,
                        child: Container(
                          width: AppConstants.questionCardRefreshButtonSize,
                          height: AppConstants.questionCardRefreshButtonSize,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(AppConstants.opacity10),
                            borderRadius: AppDimensions.radiusRoundBorder,
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: AppColors.white,
                            size: AppConstants.questionCardRefreshIconSize,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceLG,
            // Question text
            Text(
              widget.question,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(AppConstants.opacity95),
                height: 1.5,
              ),
            ),
            AppSpacing.verticalSpaceXXXL,
            // View responses button
            ElevatedButton(
              onPressed: widget.onViewResponses,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.radiusRoundBorder,
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.viewResponses,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
