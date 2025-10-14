import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';

/// Error display widget with retry functionality
class ErrorDisplay extends StatefulWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showRetry;
  final Widget? customAction;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.showRetry = true,
    this.customAction,
  });

  @override
  State<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<ErrorDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error icon
                Icon(
                  widget.icon ?? Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),

                AppSpacing.verticalSpaceLG,

                // Error title
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSpaceSM,
                ],

                // Error message
                Text(
                  widget.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.slate600,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalSpaceLG,

                // Action buttons
                if (widget.customAction != null)
                  widget.customAction!
                else if (widget.showRetry && widget.onRetry != null)
                  ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(widget.retryText ?? 'Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast notification with slide-in animations
class ToastNotification extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const ToastNotification({
    super.key,
    required this.message,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  State<ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<ToastNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: AppAnimations.toastSlide,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppAnimations.fadeTransition,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: AppAnimations.toastCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppAnimations.easeOut),
    );

    _slideController.forward();
    _fadeController.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _fadeController.reverse();
    await _slideController.reverse();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: AppSpacing.all(AppSpacing.toastMargin),
          padding: AppSpacing.all(AppSpacing.toastPadding),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: AppDimensions.radiusLGBorder,
            border: Border.all(color: _getBorderColor(), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                widget.icon ?? _getDefaultIcon(),
                color: _getIconColor(),
                size: AppDimensions.iconLG,
              ),

              AppSpacing.horizontalSpaceMD,

              // Message
              Expanded(
                child: Text(
                  widget.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getTextColor(),
                  ),
                ),
              ),

              // Action button
              if (widget.actionText != null && widget.onAction != null) ...[
                AppSpacing.horizontalSpaceMD,
                TextButton(
                  onPressed: widget.onAction,
                  child: Text(
                    widget.actionText!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _getActionColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Dismiss button
              IconButton(
                onPressed: _dismiss,
                icon: const Icon(Icons.close),
                iconSize: 16,
                color: _getTextColor().withOpacity(0.7),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.successLight;
      case ToastType.error:
        return AppColors.errorLight;
      case ToastType.warning:
        return AppColors.warningLight;
      case ToastType.info:
        return AppColors.infoLight;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  Color _getTextColor() {
    return AppColors.foreground;
  }

  Color _getActionColor() {
    return _getIconColor();
  }

  IconData _getDefaultIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}

/// Toast type enumeration
enum ToastType { success, error, warning, info }

/// Loading indicator with consistent styling
class LoadingIndicator extends StatefulWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size ?? 32,
              height: widget.size ?? 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? AppColors.primary,
                ),
              ),
            ),

            if (widget.showMessage && widget.message != null) ...[
              AppSpacing.verticalSpaceLG,
              Text(
                widget.message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state component for no data scenarios
class EmptyState extends StatefulWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.illustration,
    this.actionText,
    this.onAction,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration or icon
                if (widget.illustration != null)
                  widget.illustration!
                else
                  Icon(
                    widget.icon ?? Icons.inbox_outlined,
                    size: 80,
                    color: AppColors.slate300,
                  ),

                AppSpacing.verticalSpaceLG,

                // Title
                Text(
                  widget.title,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.slate700,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Message
                if (widget.message != null) ...[
                  AppSpacing.verticalSpaceSM,
                  Text(
                    widget.message!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.slate500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Action button
                if (widget.actionText != null && widget.onAction != null) ...[
                  AppSpacing.verticalSpaceLG,
                  ElevatedButton(
                    onPressed: widget.onAction,
                    child: Text(widget.actionText!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast manager for showing toast notifications
class ToastManager {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    // Remove existing toast
    _currentToast?.remove();

    // Create new toast
    _currentToast = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: ToastNotification(
                message: message,
                type: type,
                duration: duration,
                icon: icon,
                actionText: actionText,
                onAction: onAction,
                onDismiss: () {
                  _currentToast?.remove();
                  _currentToast = null;
                },
              ),
            ),
          ),
    );

    // Show toast
    Overlay.of(context).insert(_currentToast!);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }

  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }
}
