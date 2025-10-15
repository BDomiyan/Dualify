import 'package:flutter/material.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/question_of_the_day.dart';

/// UI configuration for daily log statuses
/// Separates presentation concerns from domain logic
class DailyLogStatusUI {
  DailyLogStatusUI._();

  /// Emoji representations for each status
  static const Map<DailyLogStatus, String> emojis = {
    DailyLogStatus.learning: '📚',
    DailyLogStatus.challenging: '💪',
    DailyLogStatus.neutral: '😐',
    DailyLogStatus.good: '😊',
  };

  /// Color hex codes for each status
  static const Map<DailyLogStatus, String> colorHexCodes = {
    DailyLogStatus.learning: '#87CEEB',
    DailyLogStatus.challenging: '#FFD700',
    DailyLogStatus.neutral: '#D3D3D3',
    DailyLogStatus.good: '#90EE90',
  };

  /// Flutter Color objects for each status
  static const Map<DailyLogStatus, Color> colors = {
    DailyLogStatus.learning: Color(0xFF87CEEB),
    DailyLogStatus.challenging: Color(0xFFFFD700),
    DailyLogStatus.neutral: Color(0xFFD3D3D3),
    DailyLogStatus.good: Color(0xFF90EE90),
  };

  /// Get emoji for a status
  static String getEmoji(DailyLogStatus status) => emojis[status] ?? '—';

  /// Get color hex code for a status
  static String getColorHex(DailyLogStatus status) =>
      colorHexCodes[status] ?? '#D3D3D3';

  /// Get color for a status
  static Color getColor(DailyLogStatus status) => colors[status] ?? Colors.grey;
}

/// UI configuration for auth providers
class AuthProviderUI {
  AuthProviderUI._();

  /// Emoji/icon representations for each provider
  static const Map<AuthProvider, String> icons = {
    AuthProvider.google: '🔍',
    AuthProvider.apple: '🍎',
    AuthProvider.email: '📧',
    AuthProvider.anonymous: '👤',
    AuthProvider.mock: '🧪',
  };

  /// Get icon for a provider
  static String getIcon(AuthProvider provider) => icons[provider] ?? '❓';

  /// Get display text with icon
  static String getDisplayTextWithIcon(AuthProvider provider) =>
      '${getIcon(provider)} ${provider.displayName}';
}

/// UI configuration for question categories
class QuestionCategoryUI {
  QuestionCategoryUI._();

  /// Emoji representations for each category
  static const Map<QuestionCategory, String> emojis = {
    QuestionCategory.learning: '📚',
    QuestionCategory.problemSolving: '🧩',
    QuestionCategory.achievement: '🏆',
    QuestionCategory.reflection: '🤔',
    QuestionCategory.skills: '🛠️',
    QuestionCategory.teamwork: '👥',
    QuestionCategory.safety: '⚠️',
    QuestionCategory.goals: '🎯',
  };

  /// Get emoji for a category
  static String getEmoji(QuestionCategory category) => emojis[category] ?? '❓';

  /// Get display text with emoji
  static String getDisplayTextWithEmoji(QuestionCategory category) =>
      '${getEmoji(category)} ${category.displayName}';
}
