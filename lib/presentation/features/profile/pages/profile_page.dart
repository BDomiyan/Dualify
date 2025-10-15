import 'package:dualify_dashboard/presentation/widgets/dualify_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/constants.dart';
import '../blocs/profile_bloc.dart';
import '../../dashboard/blocs/dashboard_bloc.dart';
import '../../../widgets/dualify_text_field.dart';
import '../../../widgets/dualify_dropdown.dart';
import '../../../widgets/dualify_date_picker.dart';
import '../../../widgets/feedback_widgets.dart';

/// Profile page for viewing and editing user information
class ProfilePage extends StatefulWidget {
  final bool isInNavigationWrapper;

  const ProfilePage({super.key, this.isInNavigationWrapper = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedTrade = '';
  DateTime? _startDate;
  bool _isFormValid = false;
  bool _hasLoadedData = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_checkFormValidity);
    _durationController.addListener(_checkFormValidity);

    // Load profile data
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadProfileData(dynamic profile, {bool isUpdate = false}) {
    if (_hasLoadedData && !isUpdate) return;

    final fullName = '${profile.firstName} ${profile.lastName}';
    _fullNameController.text = fullName;
    _selectedTrade = profile.trade;
    _startDate = profile.apprenticeshipStartDate;

    // Calculate duration in months
    final durationMonths = profile.apprenticeshipDurationMonths;
    _durationController.text = durationMonths.toString();

    if (!_hasLoadedData) {
      _hasLoadedData = true;
    }

    _checkFormValidity();
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

  void _handleUpdate() {
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
      final calculatedEndDate = DateTime(
        _startDate!.year,
        _startDate!.month + durationMonths,
        _startDate!.day,
      );

      setState(() {
        _isUpdating = true;
      });

      context.read<ProfileBloc>().add(
        ProfileUpdateRequested(
          firstName: firstName,
          lastName: lastName,
          trade: _selectedTrade,
          apprenticeshipStartDate: _startDate,
          apprenticeshipEndDate: calculatedEndDate,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final firstDate = DateTime.now().subtract(
      Duration(
        days: AppConstants.daysInYear * AppConstants.datePickerYearsPast,
      ),
    );
    final lastDate = DateTime.now().add(
      Duration(
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
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            final wasUpdating = _isUpdating;
            _loadProfileData(state.profile, isUpdate: wasUpdating);

            // Show success toast only if we just updated
            if (wasUpdating) {
              setState(() {
                _isUpdating = false;
              });
              ToastManager.showSuccess(
                context,
                AppStrings.profileUpdatedSuccess,
              );

              // Refresh dashboard data
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            }
          } else if (state is ProfileError) {
            setState(() {
              _isUpdating = false;
            });
            ToastManager.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is ProfileEmpty) {
            return _buildEmptyState();
          }

          return _buildProfileForm(state);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: AppConstants.comingSoonIconSize + 16,
              color: AppColors.slate400,
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              AppStrings.noProfileFound,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              AppStrings.completeOnboardingFirst,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(ProfileState state) {
    final isSubmitting = state is ProfileUpdating;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxl),
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

                      AppSpacing.verticalSpaceXXXL,

                      // Title
                      _buildTitle(),

                      AppSpacing.verticalSpaceXXL,

                      // Form Fields
                      _buildFormFields(),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button at bottom
            AppSpacing.verticalSpaceXXXL,
            _buildSubmitButton(isSubmitting),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      AppStrings.appName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        AppStrings.updateYourProfile,
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

        AppSpacing.verticalSpaceLG,

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

        AppSpacing.verticalSpaceLG,

        // Start Date
        DualifyDatePicker(
          label: AppStrings.startDate,
          selectedDate: _startDate,
          onTap: () => _selectDate(context),
          required: true,
        ),

        AppSpacing.verticalSpaceLG,

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

  Widget _buildSubmitButton(bool isSubmitting) {
    return DualifyButton(
      text: AppStrings.updateProfile,
      onPressed: _handleUpdate,
      isLoading: isSubmitting,
      isEnabled: _isFormValid,
    );
  }
}
