import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/constants.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../widgets/header_section.dart';
import '../widgets/progress_section.dart';
import '../widgets/verification_card.dart';
import '../widgets/daily_log_card.dart';
import '../widgets/question_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../domain/entities/entities.dart';

/// Main dashboard page matching HTML design exactly
class DashboardPage extends StatefulWidget {
  final bool isInNavigationWrapper;

  const DashboardPage({super.key, this.isInNavigationWrapper = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  void _handleDayTap(DateTime date) {
    // Show status selection bottom sheet
    _showStatusSelection(date);
  }

  void _showStatusSelection(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _StatusSelectionSheet(
            date: date,
            onStatusSelected: (status) {
              context.read<DashboardBloc>().add(
                DailyStatusUpdateRequested(date: date, status: status),
              );
              Navigator.pop(context);
            },
          ),
    );
  }

  void _handleQotdRefresh() {
    context.read<DashboardBloc>().add(const QuestionOfTheDayRefreshRequested());

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.updatingLatestQuestions),
        duration: Duration(seconds: AppConstants.snackbarDurationShort),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          // Show success message when QOTD is refreshed
          if (state is DashboardLoaded) {
            // Check if this is a refresh (not initial load)
            if (state.dashboardData.questionOfTheDay != null) {
              // Only show if we have a question (indicates successful refresh)
              // This will show after refresh completes
            }
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return _buildLoadingState();
            } else if (state is DashboardLoaded || state is DashboardUpdating) {
              final data =
                  state is DashboardLoaded
                      ? state.dashboardData
                      : (state as DashboardUpdating).currentData;
              return _buildLoadedState(data);
            } else if (state is DashboardError) {
              return _buildErrorState(state);
            }
            return _buildLoadingState();
          },
        ),
      ),
      bottomNavigationBar:
          widget.isInNavigationWrapper
              ? null
              : BottomNavBar(
                currentIndex: 0,
                onTap: (index) {
                  // Fallback navigation for standalone usage
                  switch (index) {
                    case 0:
                      break;
                    case 1:
                    case 2:
                    case 3:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.useMainNavigation)),
                      );
                      break;
                  }
                },
              ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState(DashboardError error) {
    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.iconSize64,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              AppStrings.somethingWentWrong,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate600),
            ),
            if (error.isRecoverable) ...[
              AppSpacing.verticalSpaceXXL,
              ElevatedButton(
                onPressed: () {
                  context.read<DashboardBloc>().add(
                    const DashboardLoadRequested(),
                  );
                },
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(DashboardData data) {
    final userName = data.profile?.firstName ?? AppConstants.defaultUserName;
    final dates = _generateLast7Days();
    final statusMap = _buildStatusMap(data.recentDailyLogs);

    return Column(
      children: [
        // Header
        HeaderSection(
          userName: userName,
          hasNotifications: true,
          onNotificationTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.notificationsComingSoon)),
            );
          },
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppSpacing.verticalSpaceMD,
                // Progress section
                if (data.progressData != null)
                  ProgressSection(
                    progressPercentage:
                        data.progressData!.progressPercentage * 100,
                    daysRemaining: data.progressData!.daysRemaining,
                  ),
                AppSpacing.verticalSpaceXL,
                // Verification cards
                if (data.profile != null) ...[
                  Padding(
                    padding: AppSpacing.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        VerificationCard(
                          title: AppStrings.companyLabel,
                          subtitle: AppStrings.defaultCompany,
                          icon: Icons.business,
                          iconBackgroundColor: AppColors.primary.withOpacity(
                            AppConstants.opacity10,
                          ),
                          isVerified: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.verificationComingSoon),
                              ),
                            );
                          },
                        ),
                        AppSpacing.verticalSpaceMD,
                        VerificationCard(
                          title: AppStrings.schoolLabel,
                          subtitle: data.profile!.schoolName ?? AppStrings.defaultSchool,
                          icon: Icons.school,
                          iconBackgroundColor: AppColors.accent.withOpacity(
                            AppConstants.opacity10,
                          ),
                          isVerified: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.verificationComingSoon),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalSpaceXL,
                ],
                // Daily log section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppSpacing.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        AppStrings.dailyLogTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    AppSpacing.verticalSpaceMD,
                    DailyLogScroller(
                      dates: dates,
                      statusMap: statusMap,
                      onDayTap: _handleDayTap,
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXL,
                // Question of the day
                if (data.questionOfTheDay != null)
                  Padding(
                    padding: AppSpacing.symmetric(horizontal: AppSpacing.lg),
                    child: QuestionCard(
                      question: data.questionOfTheDay!.question,
                      onRefresh: _handleQotdRefresh,
                      onViewResponses: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.responsesComingSoon),
                          ),
                        );
                      },
                    ),
                  ),
                AppSpacing.verticalSpaceXXL,
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<DateTime> _generateLast7Days() {
    final today = DateTime.now();
    return List.generate(AppConstants.defaultDaysToGenerate, (index) {
      return today.subtract(Duration(days: AppConstants.defaultDaysOffset - index));
    });
  }

  Map<DateTime, String> _buildStatusMap(List<DailyLog> logs) {
    final map = <DateTime, String>{};
    for (final log in logs) {
      final key = DateTime(log.date.year, log.date.month, log.date.day);
      map[key] = log.status.name;
    }
    return map;
  }
}

/// Status selection bottom sheet
class _StatusSelectionSheet extends StatelessWidget {
  final DateTime date;
  final Function(String) onStatusSelected;

  const _StatusSelectionSheet({
    required this.date,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      padding: AppSpacing.all(AppSpacing.xxl),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.howWasYourDay,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            AppSpacing.verticalSpaceXXL,
            _StatusOption(
              emoji: AppStrings.emojiGood,
              title: AppStrings.statusGoodTitle,
              description: AppStrings.statusGoodDescription,
              onTap: () => onStatusSelected(AppStrings.statusGood),
            ),
            AppSpacing.verticalSpaceMD,
            _StatusOption(
              emoji: AppStrings.emojiLearning,
              title: AppStrings.statusLearningTitle,
              description: AppStrings.statusLearningDescription,
              onTap: () => onStatusSelected(AppStrings.statusLearning),
            ),
            AppSpacing.verticalSpaceMD,
            _StatusOption(
              emoji: AppStrings.emojiChallenging,
              title: AppStrings.statusChallengingTitle,
              description: AppStrings.statusChallengingDescription,
              onTap: () => onStatusSelected(AppStrings.statusChallenging),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _StatusOption({
    required this.emoji,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.slate100,
          borderRadius: AppDimensions.radiusLGBorder,
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: AppConstants.statusOptionEmojiSize)),
            AppSpacing.horizontalSpaceLG,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: AppColors.slate600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
