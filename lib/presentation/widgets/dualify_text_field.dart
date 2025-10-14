import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Custom text field matching the HTML design
class DualifyTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool required;
  final FormFieldValidator<String>? validator;

  const DualifyTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.required = false,
    this.validator,
  });

  // Constants
  static const double _focusedBorderWidth = 2.0;
  static const double _errorBorderWidth = 1.0;

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
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.inputHint,
            filled: true,
            fillColor: AppColors.slate100,
            contentPadding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppDimensions.radiusMDBorder,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusMDBorder,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusMDBorder,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: _focusedBorderWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusMDBorder,
              borderSide: BorderSide(
                color: AppColors.error,
                width: _errorBorderWidth,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppDimensions.radiusMDBorder,
              borderSide: BorderSide(
                color: AppColors.error,
                width: _focusedBorderWidth,
              ),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.inputError,
          ),
        ),
      ],
    );
  }
}
