import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Custom date picker field matching the HTML design
class DualifyDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback? onTap;
  final String? errorText;
  final bool required;
  final FormFieldValidator<DateTime>? validator;

  const DualifyDatePicker({
    super.key,
    required this.label,
    this.selectedDate,
    this.onTap,
    this.errorText,
    this.required = false,
    this.validator,
  });

  // Constants
  static const String _dateFormat = 'yyyy-MM-dd';
  static const double _borderWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel,
        ),
        AppSpacing.verticalSpaceXS,
        InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.radiusMDBorder,
          child: Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: AppDimensions.radiusMDBorder,
              border:
                  errorText != null
                      ? Border.all(color: AppColors.error, width: _borderWidth)
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat(_dateFormat).format(selectedDate!)
                      : '',
                  style: AppTextStyles.inputText.copyWith(
                    color:
                        selectedDate != null
                            ? AppColors.foreground
                            : AppColors.slate500,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: AppDimensions.iconMD,
                  color: AppColors.slate500,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: AppSpacing.only(
              top: AppSpacing.xs,
              left: AppSpacing.md,
            ),
            child: Text(
              errorText!,
              style: AppTextStyles.inputError,
            ),
          ),
      ],
    );
  }
}
