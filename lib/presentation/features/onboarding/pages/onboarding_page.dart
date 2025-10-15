import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/shared_preferences_service.dart';
import '../blocs/onboarding_bloc.dart';
import '../../../widgets/dualify_button.dart';
import '../../../widgets/dualify_text_field.dart';
import '../../../widgets/dualify_dropdown.dart';
import '../../../widgets/dualify_date_picker.dart';
import '../../../widgets/feedback_widgets.dart';
import '../blocs/onboarding_event.dart';
import '../blocs/onboarding_form_data.dart';
import '../blocs/onboarding_state.dart';

/// Onboarding page matching the HTML design exactly
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedTrade = '';
  DateTime? _startDate;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_checkFormValidity);
    _durationController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    setState(() {
      _isFormValid =
          _fullNameController.text.trim().isNotEmpty &&
          _selectedTrade.isNotEmpty &&
          _startDate != null &&
          _durationController.text.trim().isNotEmpty;
    });
  }

  void _handleSubmit() {
    if (!_isFormValid) return;

    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fullNameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : AppConstants.defaultLastName;

      final durationMonths = int.tryParse(_durationController.text.trim()) ?? 0;
      // Calculate end date based on duration in months
      final endDate = DateTime(
        _startDate!.year,
        _startDate!.month + durationMonths,
        _startDate!.day,
      );

      final formData = OnboardingFormData(
        firstName: firstName,
        lastName: lastName,
        trade: _selectedTrade,
        apprenticeshipStartDate: _startDate,
        apprenticeshipEndDate: endDate,
      );

      context.read<OnboardingBloc>().add(OnboardingSubmitted(formData));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final firstDate = DateTime.now().subtract(
      const Duration(
        days: AppConstants.daysInYear * AppConstants.datePickerYearsPast,
      ),
    );
    final lastDate = DateTime.now().add(
      const Duration(
        days: AppConstants.daysInYear * AppConstants.datePickerYearsFuture,
      ),
    );

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        _checkFormValidity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          if (state is OnboardingSuccess) {
            await SharedPreferencesService.setOnboardingComplete(true);
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            }
          } else if (state is OnboardingError) {
            ToastManager.showError(context, state.message);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header
                          _buildHeader(),

                          const SizedBox(height: 32),

                          // Title
                          _buildTitle(),

                          const SizedBox(height: 24),

                          // Form Fields
                          _buildFormFields(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Submit Button at bottom
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      AppStrings.appName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        AppStrings.startYourJourney,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Full Name
        DualifyTextField(
          label: AppStrings.fullName,
          placeholder: AppStrings.fullNamePlaceholder,
          controller: _fullNameController,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.fullNameRequired;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Trade/Program
        DualifyDropdown(
          label: AppStrings.tradeProgram,
          placeholder: AppStrings.tradePlaceholder,
          value: _selectedTrade.isEmpty ? null : _selectedTrade,
          items: AppStrings.tradeOptions,
          onChanged: (value) {
            setState(() {
              _selectedTrade = value ?? '';
              _checkFormValidity();
            });
          },
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.tradeRequired;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Start Date
        DualifyDatePicker(
          label: AppStrings.startDate,
          selectedDate: _startDate,
          onTap: () => _selectDate(context),
          required: true,
        ),

        const SizedBox(height: 16),

        // Duration
        DualifyTextField(
          label: AppStrings.apprenticeshipDuration,
          placeholder: AppStrings.durationPlaceholder,
          controller: _durationController,
          keyboardType: TextInputType.number,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.durationRequired;
            }
            final duration = int.tryParse(value);
            if (duration == null || duration <= 0) {
              return AppStrings.invalidDuration;
            }
            if (duration < AppConstants.minApprenticeDurationMonths) {
              return AppStrings.durationTooShort;
            }
            if (duration > AppConstants.maxApprenticeDurationMonths) {
              return AppStrings.durationTooLong;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final isSubmitting = state is OnboardingSubmitting;

        return DualifyButton(
          text: AppStrings.calculateProgressAndStart,
          onPressed: _handleSubmit,
          isLoading: isSubmitting,
          isEnabled: _isFormValid,
        );
      },
    );
  }
}
