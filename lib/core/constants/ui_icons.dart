import 'package:flutter/material.dart';

/// UI icon and emoji constants for the presentation layer
/// Contains all emoji representations and icon definitions
class UIIcons {
  // Private constructor to prevent instantiation
  UIIcons._();

  // ============================================================================
  // DAILY LOG STATUS - EMOJIS
  // ============================================================================
  static const String dailyLogEmojiLearning = '📚';
  static const String dailyLogEmojiChallenging = '💪';
  static const String dailyLogEmojiNeutral = '😐';
  static const String dailyLogEmojiGood = '😊';
  static const String dailyLogEmojiDefault = '—';

  // ============================================================================
  // AUTH PROVIDER - ICONS/EMOJIS
  // ============================================================================
  static const String authProviderIconGoogle = '🔍';
  static const String authProviderIconApple = '🍎';
  static const String authProviderIconEmail = '📧';
  static const String authProviderIconAnonymous = '👤';
  static const String authProviderIconMock = '🧪';
  static const String authProviderIconDefault = '❓';

  // ============================================================================
  // QUESTION CATEGORY - EMOJIS
  // ============================================================================
  static const String questionCategoryEmojiLearning = '📚';
  static const String questionCategoryEmojiProblemSolving = '🧩';
  static const String questionCategoryEmojiAchievement = '🏆';
  static const String questionCategoryEmojiReflection = '🤔';
  static const String questionCategoryEmojiSkills = '🛠️';
  static const String questionCategoryEmojiTeamwork = '👥';
  static const String questionCategoryEmojiSafety = '⚠️';
  static const String questionCategoryEmojiGoals = '🎯';
  static const String questionCategoryEmojiDefault = '❓';

  // ============================================================================
  // ERROR PAGE - MATERIAL ICONS
  // ============================================================================
  static const IconData errorIconOutline = Icons.error_outline;
  static const double errorIconSize = 64.0;

  // ============================================================================
  // COMMON ICONS
  // ============================================================================
  static const IconData iconCheck = Icons.check;
  static const IconData iconClose = Icons.close;
  static const IconData iconError = Icons.error;
  static const IconData iconWarning = Icons.warning;
  static const IconData iconInfo = Icons.info;

  // ============================================================================
  // COLOR HEX CODES (for external APIs or string-based color systems)
  // ============================================================================
  static const String dailyLogColorHexLearning = '#87CEEB';
  static const String dailyLogColorHexChallenging = '#FFD700';
  static const String dailyLogColorHexNeutral = '#D3D3D3';
  static const String dailyLogColorHexGood = '#90EE90';
  static const String dailyLogColorHexDefault = '#D3D3D3';
}
