import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Custom dropdown matching the HTML design
class DualifyDropdown extends StatelessWidget {
  final String label;
  final String placeholder;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? errorText;
  final bool required;
  final FormFieldValidator<String>? validator;

  const DualifyDropdown({
    super.key,
    required this.label,
    required this.placeholder,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
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
        DropdownButtonFormField<String>(
          value: value?.isEmpty == true ? null : value,
          onChanged: onChanged,
          validator: validator,
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
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.slate500,
            size: AppDimensions.iconMD,
          ),
          style: AppTextStyles.inputText,
          dropdownColor: AppColors.white,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
        ),
      ],
    );
  }
}
