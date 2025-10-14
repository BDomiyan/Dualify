import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';

/// Skeleton loading widget for the entire dashboard
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress section skeleton
        _buildSectionHeader(),
        AppSpacing.verticalSpaceLG,
        Center(
          child: SkeletonWidget(
            width: 200,
            height: 200,
            borderRadius: BorderRadius.circular(100),
          ),
        ),

        AppSpacing.verticalSpaceXXL,

        // Profile cards section skeleton
        _buildSectionHeader(),
        AppSpacing.verticalSpaceLG,
        Row(
          children: [
            const Expanded(child: SkeletonCard(height: 120)),
            AppSpacing.horizontalSpaceMD,
            const Expanded(child: SkeletonCard(height: 120)),
          ],
        ),

        AppSpacing.verticalSpaceXXL,

        // Daily log section skeleton
        _buildSectionHeader(),
        AppSpacing.verticalSpaceLG,
        const SkeletonSevenDayCalendar(),

        AppSpacing.verticalSpaceXXL,

        // QOTD section skeleton
        _buildSectionHeader(),
        AppSpacing.verticalSpaceLG,
        const SkeletonCard(height: 200),

        AppSpacing.verticalSpaceXXXL,
      ],
    );
  }

  Widget _buildSectionHeader() {
    return SkeletonWidget(
      width: 150,
      height: 24,
      borderRadius: AppDimensions.radiusXSBorder,
    );
  }
}

/// Base skeleton widget with shimmer animation
class SkeletonWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? margin;
  final Widget? child;

  const SkeletonWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.margin,
    this.child,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: AppAnimations.shimmerAnimation,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: AppAnimations.shimmerCurve,
      ),
    );

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Color.lerp(
                widget.baseColor ?? AppColors.skeletonBase,
                widget.highlightColor ?? AppColors.skeletonHighlight,
                _shimmerAnimation.value,
              ),
              borderRadius: widget.borderRadius ?? AppDimensions.radiusXSBorder,
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Skeleton for seven day calendar
class SkeletonSevenDayCalendar extends StatelessWidget {
  const SkeletonSevenDayCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: AppSpacing.symmetric(horizontal: AppSpacing.xs),
            child: SkeletonWidget(
              width: 60,
              height: 80,
              borderRadius: AppDimensions.radiusLGBorder,
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton for list items
class SkeletonListItem extends StatelessWidget {
  final double? height;
  final bool showAvatar;
  final bool showTrailing;

  const SkeletonListItem({
    super.key,
    this.height,
    this.showAvatar = true,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 72,
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Avatar
          if (showAvatar) ...[
            SkeletonWidget(
              width: AppDimensions.avatarSize,
              height: AppDimensions.avatarSize,
              borderRadius: BorderRadius.circular(AppDimensions.avatarSize / 2),
            ),
            AppSpacing.horizontalSpaceLG,
          ],

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: AppDimensions.radiusXSBorder,
                ),

                AppSpacing.verticalSpaceXS,

                SkeletonWidget(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 14,
                  borderRadius: AppDimensions.radiusXSBorder,
                ),
              ],
            ),
          ),

          // Trailing
          if (showTrailing) ...[
            AppSpacing.horizontalSpaceLG,
            SkeletonWidget(
              width: 24,
              height: 24,
              borderRadius: AppDimensions.radiusXSBorder,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton for buttons
class SkeletonButton extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? margin;

  const SkeletonButton({super.key, this.width, this.height, this.margin});

  @override
  Widget build(BuildContext context) {
    return SkeletonWidget(
      width: width ?? double.infinity,
      height: height ?? AppDimensions.buttonHeight,
      borderRadius: AppDimensions.radiusLGBorder,
      margin: margin,
    );
  }
}

/// Skeleton for text blocks
class SkeletonText extends StatelessWidget {
  final int lines;
  final double? lineHeight;
  final double? lineSpacing;
  final double? lastLineWidth;

  const SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 16,
    this.lineSpacing = 8,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final width =
            isLastLine && lastLineWidth != null
                ? lastLineWidth!
                : double.infinity;

        return Container(
          margin:
              index > 0
                  ? EdgeInsets.only(top: lineSpacing ?? 8)
                  : EdgeInsets.zero,
          child: SkeletonWidget(
            width: width,
            height: lineHeight ?? 16,
            borderRadius: AppDimensions.radiusXSBorder,
          ),
        );
      }),
    );
  }
}

/// Skeleton for image placeholders
class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showIcon;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonWidget(
      width: width,
      height: height,
      borderRadius: borderRadius,
      child:
          showIcon
              ? Icon(
                Icons.image,
                color: AppColors.slate300,
                size:
                    (width != null && height != null)
                        ? (width! < height! ? width! : height!) * 0.3
                        : 32,
              )
              : null,
    );
  }
}

/// Skeleton for form fields
class SkeletonFormField extends StatelessWidget {
  final String? label;
  final double? height;

  const SkeletonFormField({super.key, this.label, this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SkeletonWidget(
            width: 80,
            height: 14,
            borderRadius: AppDimensions.radiusXSBorder,
          ),
          AppSpacing.verticalSpaceSM,
        ],

        SkeletonWidget(
          width: double.infinity,
          height: height ?? AppDimensions.inputHeight,
          borderRadius: AppDimensions.radiusLGBorder,
        ),
      ],
    );
  }
}

/// Skeleton for cards with content
class SkeletonCard extends StatelessWidget {
  final double? height;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SkeletonCard({
    super.key,
    this.height,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppDimensions.radiusLGBorder,
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? AppSpacing.card,
        child: child ?? const SkeletonText(lines: 3),
      ),
    );
  }
}

/// Skeleton for grid items
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        mainAxisSpacing: mainAxisSpacing ?? 16,
        crossAxisSpacing: crossAxisSpacing ?? 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonCard();
      },
    );
  }
}

/// Skeleton for navigation items
class SkeletonNavigation extends StatelessWidget {
  final int itemCount;
  final bool isHorizontal;

  const SkeletonNavigation({
    super.key,
    this.itemCount = 4,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(itemCount, (index) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonWidget(
            width: 24,
            height: 24,
            borderRadius: AppDimensions.radiusXSBorder,
          ),

          AppSpacing.verticalSpaceXS,

          SkeletonWidget(
            width: 40,
            height: 12,
            borderRadius: AppDimensions.radiusXSBorder,
          ),
        ],
      );
    });

    if (isHorizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      );
    } else {
      return Column(
        children:
            items
                .map(
                  (item) => Container(
                    margin: AppSpacing.only(bottom: AppSpacing.lg),
                    child: item,
                  ),
                )
                .toList(),
      );
    }
  }
}
