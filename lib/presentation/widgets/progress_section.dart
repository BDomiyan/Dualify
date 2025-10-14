import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_animations.dart';
import '../../core/constants/constants.dart';

/// A complete progress section that displays:
/// - An animated circular progress ring
/// - Progress percentage and days remaining
/// - A motivational message badge
class ProgressSection extends StatelessWidget {
  final double progressPercentage;
  final int daysRemaining;
  final String? motivationalMessage;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  const ProgressSection({
    super.key,
    required this.progressPercentage,
    required this.daysRemaining,
    this.motivationalMessage,
    this.strokeWidth = AppConstants.progressStrokeWidth,
    this.progressColor = AppColors.primary,
    this.backgroundColor = AppColors.progressBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressRing(
          percentage: progressPercentage,
          daysRemaining: daysRemaining,
          strokeWidth: strokeWidth,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          size: AppConstants.progressRingSize,
        ),
        AppSpacing.verticalSpaceXL,
        _MotivationalBadge(
          message: motivationalMessage ?? AppStrings.defaultMotivationalMessage,
        ),
      ],
    );
  }
}

/// The animated circular progress ring component
class _ProgressRing extends StatefulWidget {
  final double percentage;
  final int daysRemaining;
  final double strokeWidth;
  final double size;
  final Color progressColor;
  final Color backgroundColor;

  const _ProgressRing({
    required this.percentage,
    required this.daysRemaining,
    required this.strokeWidth,
    required this.size,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double _percentageDivisor = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _initializeAnimation();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _initializeAnimation() {
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage / _percentageDivisor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.progressCurve,
    ));
  }

  @override
  void didUpdateWidget(_ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage / _percentageDivisor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.progressCurve,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  progressColor: widget.progressColor,
                  backgroundColor: widget.backgroundColor,
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Text(
                    '${(_animation.value * _percentageDivisor).round()}%',
                    style: AppTextStyles.progressPercentage.copyWith(
                      fontSize: 36,
                      color: widget.progressColor,
                    ),
                  );
                },
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                '${AppStrings.daysRemainingPrefix}${widget.daysRemaining}',
                style: AppTextStyles.progressLabel.copyWith(
                  color: widget.progressColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing the progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  static const double _startAngleOffset = -math.pi / 2;
  static const double _fullCircle = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = _fullCircle * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _startAngleOffset,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// A styled container for displaying the motivational message
class _MotivationalBadge extends StatelessWidget {
  final String message;

  const _MotivationalBadge({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(AppConstants.opacity10),
        borderRadius: AppDimensions.radiusRoundBorder,
      ),
      child: Text(
        message,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
