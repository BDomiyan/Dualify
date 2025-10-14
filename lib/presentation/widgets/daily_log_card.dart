import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_animations.dart';
import '../../core/constants/constants.dart';

/// Daily log card showing day, date, status emoji, and indicator
class DailyLogCard extends StatefulWidget {
  final DateTime date;
  final String? status;
  final bool isToday;
  final VoidCallback? onTap;

  const DailyLogCard({
    super.key,
    required this.date,
    this.status,
    this.isToday = false,
    this.onTap,
  });

  @override
  State<DailyLogCard> createState() => _DailyLogCardState();
}

class _DailyLogCardState extends State<DailyLogCard> {
  bool _isHovered = false;

  String get _dayName => DateFormat('E').format(widget.date).toUpperCase();
  String get _dayNumber => widget.date.day.toString();

  Color get _borderColor {
    if (widget.status == null) return Colors.transparent;
    return AppColors.getStatusColor(widget.status!);
  }

  Color get _dateColor {
    if (widget.isToday) return AppColors.primary;
    if (widget.status == null) return AppColors.slate500;
    return AppColors.getStatusColor(widget.status!);
  }

  String get _emoji {
    if (widget.status == null) return AppStrings.emojiEmpty;
    switch (widget.status) {
      case AppStrings.statusGood:
        return AppStrings.emojiGood;
      case AppStrings.statusLearning:
        return AppStrings.emojiLearning;
      case AppStrings.statusChallenging:
        return AppStrings.emojiChallenging;
      default:
        return AppStrings.emojiEmpty;
    }
  }

  Color get _dotColor {
    if (widget.status == null) return Colors.transparent;
    return AppColors.getStatusColor(widget.status!);
  }

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
              Matrix4.identity()
                ..translate(0.0, _isHovered ? AppAnimations.hoverTranslateY * 3 : 0.0)
                ..scale(_isHovered ? AppAnimations.hoverScale + 0.01 : 1.0),
          width: AppConstants.dailyLogCardWidth,
          height: AppConstants.dailyLogCardHeight,
          decoration: BoxDecoration(
            color:
                widget.isToday
                    ? AppColors.primary.withOpacity(AppConstants.opacity10)
                    : AppColors.cardBackground,
            borderRadius: AppDimensions.radiusXLBorder,
            border: Border.all(
              color:
                  widget.isToday
                      ? AppColors.primary
                      : (widget.status == null
                          ? AppColors.slate200
                          : _borderColor),
              width: AppConstants.borderWidth2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? AppColors.shadowMedium
                        : AppColors.shadowLight,
                blurRadius: _isHovered ? AppDimensions.shadowBlurRadiusLarge : AppDimensions.shadowBlurRadius,
                offset: _isHovered ? AppDimensions.shadowOffsetLarge : AppDimensions.shadowOffset,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppSpacing.verticalSpaceLG,
              // Day name
              Text(
                _dayName,
                style: AppTextStyles.dayLabel.copyWith(
                  color: widget.isToday ? AppColors.primary : AppColors.slate500,
                ),
              ),
              // Day number
              Text(
                _dayNumber,
                style: AppTextStyles.dayNumber.copyWith(
                  fontSize: 28,
                  color: _dateColor,
                ),
              ),
              // Emoji
              GestureDetector(
                onTap: widget.onTap,
                child: SizedBox(
                  width: AppConstants.iconSize40,
                  height: AppConstants.iconSize40,
                  child: Center(
                    child: Text(_emoji, style: AppTextStyles.emojiStatus.copyWith(fontSize: 36)),
                  ),
                ),
              ),
              // Status indicator or today badge
              if (widget.isToday)
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppDimensions.radiusRoundBorder,
                  ),
                  child: Text(
                    AppStrings.todayLabel,
                    style: AppTextStyles.todayBadge,
                  ),
                )
              else
                Container(
                  width: AppConstants.dailyLogDotSize,
                  height: AppConstants.dailyLogDotSize,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              AppSpacing.verticalSpaceLG,
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrolling daily log section
class DailyLogScroller extends StatefulWidget {
  final List<DateTime> dates;
  final Map<DateTime, String> statusMap;
  final Function(DateTime)? onDayTap;

  const DailyLogScroller({
    super.key,
    required this.dates,
    required this.statusMap,
    this.onDayTap,
  });

  @override
  State<DailyLogScroller> createState() => _DailyLogScrollerState();
}

class _DailyLogScrollerState extends State<DailyLogScroller> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    final todayIndex = widget.dates.indexWhere(_isToday);
    if (todayIndex >= 0 && _scrollController.hasClients) {
      final cardTotalWidth = AppConstants.dailyLogCardWidth + AppConstants.dailyLogCardSpacing;
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollOffset =
          (todayIndex * cardTotalWidth) - (screenWidth / AppConstants.scrollDivisor) + (AppConstants.dailyLogCardWidth / AppConstants.scrollDivisor);

      _scrollController.animateTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: AppAnimations.easeOut,
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String? _getStatus(DateTime date) {
    return widget.statusMap[DateTime(date.year, date.month, date.day)];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.dailyLogCardHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.symmetric(horizontal: AppSpacing.lg),
        itemCount: widget.dates.length,
        separatorBuilder: (context, index) => SizedBox(width: AppConstants.dailyLogCardSpacing),
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          return DailyLogCard(
            date: date,
            status: _getStatus(date),
            isToday: _isToday(date),
            onTap: () => widget.onDayTap?.call(date),
          );
        },
      ),
    );
  }
}
