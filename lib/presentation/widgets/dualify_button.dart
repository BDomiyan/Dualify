import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Custom button matching the HTML design
class DualifyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const DualifyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  // Constants
  static const double _disabledOpacity = 0.5;
  static const double _loadingIndicatorSize = 20.0;
  static const double _loadingStrokeWidth = 2.0;
  static const double _elevation = 0.0;

  @override
  Widget build(BuildContext context) {
    final bool enabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(_disabledOpacity),
          foregroundColor: AppColors.white,
          disabledForegroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: AppDimensions.buttonHeight / 3),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusMDBorder,
          ),
          elevation: _elevation,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: _loadingIndicatorSize,
                  width: _loadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _loadingStrokeWidth,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
                : Text(
                  text,
                  style: AppTextStyles.buttonLarge,
                ),
      ),
    );
  }
}
