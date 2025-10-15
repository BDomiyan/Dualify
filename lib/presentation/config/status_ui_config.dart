import 'package:flutter/material.dart';

import '../../core/constants/ui_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/entities.dart';

/// UI configuration for daily log statuses
/// Separates presentation concerns from domain logic
class DailyLogStatusUI {
  DailyLogStatusUI._();

  /// Emoji representations for each status
  static const Map<DailyLogStatus, String> emojis = {
    DailyLogStatus.learning: UIIcons.dailyLogEmojiLearning,
    DailyLogStatus.challenging: UIIcons.dailyLogEmojiChallenging,
    DailyLogStatus.neutral: UIIcons.dailyLogEmojiNeutral,
    DailyLogStatus.good: UIIcons.dailyLogEmojiGood,
  };

  /// Color hex codes for each status
  static const Map<DailyLogStatus, String> colorHexCodes = {
    DailyLogStatus.learning: UIIcons.dailyLogColorHexLearning,
    DailyLogStatus.challenging: UIIcons.dailyLogColorHexChallenging,
    DailyLogStatus.neutral: UIIcons.dailyLogColorHexNeutral,
    DailyLogStatus.good: UIIcons.dailyLogColorHexGood,
  };

  /// Flutter Color objects for each status
  static const Map<DailyLogStatus, Color> colors = {
    DailyLogStatus.learning: AppColors.statusLearning,
    DailyLogStatus.challenging: AppColors.statusChallenging,
    DailyLogStatus.neutral: AppColors.statusNeutral,
    DailyLogStatus.good: AppColors.statusGood,
  };

  /// Get emoji for a status
  static String getEmoji(DailyLogStatus status) =>
      emojis[status] ?? UIIcons.dailyLogEmojiDefault;

  /// Get color hex code for a status
  static String getColorHex(DailyLogStatus status) =>
      colorHexCodes[status] ?? UIIcons.dailyLogColorHexDefault;

  /// Get color for a status
  static Color getColor(DailyLogStatus status) =>
      colors[status] ?? AppColors.statusNeutral;
}

/// UI configuration for auth providers
class AuthProviderUI {
  AuthProviderUI._();

  /// Emoji/icon representations for each provider
  static const Map<AuthProvider, String> icons = {
    AuthProvider.google: UIIcons.authProviderIconGoogle,
    AuthProvider.apple: UIIcons.authProviderIconApple,
    AuthProvider.email: UIIcons.authProviderIconEmail,
    AuthProvider.anonymous: UIIcons.authProviderIconAnonymous,
    AuthProvider.mock: UIIcons.authProviderIconMock,
  };

  /// Get icon for a provider
  static String getIcon(AuthProvider provider) =>
      icons[provider] ?? UIIcons.authProviderIconDefault;

  /// Get display text with icon
  static String getDisplayTextWithIcon(AuthProvider provider) =>
      '${getIcon(provider)} ${provider.displayName}';
}

/// UI configuration for question categories
class QuestionCategoryUI {
  QuestionCategoryUI._();

  /// Emoji representations for each category
  static const Map<QuestionCategory, String> emojis = {
    QuestionCategory.learning: UIIcons.questionCategoryEmojiLearning,
    QuestionCategory.problemSolving:
        UIIcons.questionCategoryEmojiProblemSolving,
    QuestionCategory.achievement: UIIcons.questionCategoryEmojiAchievement,
    QuestionCategory.reflection: UIIcons.questionCategoryEmojiReflection,
    QuestionCategory.skills: UIIcons.questionCategoryEmojiSkills,
    QuestionCategory.teamwork: UIIcons.questionCategoryEmojiTeamwork,
    QuestionCategory.safety: UIIcons.questionCategoryEmojiSafety,
    QuestionCategory.goals: UIIcons.questionCategoryEmojiGoals,
  };

  /// Get emoji for a category
  static String getEmoji(QuestionCategory category) =>
      emojis[category] ?? UIIcons.questionCategoryEmojiDefault;

  /// Get display text with emoji
  static String getDisplayTextWithEmoji(QuestionCategory category) =>
      '${getEmoji(category)} ${category.displayName}';
}
