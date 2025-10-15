import '../../../core/constants/domain_constants.dart';

/// Enumeration for question categories
enum QuestionCategory {
  learning(
    DomainConstants.questionCategoryLearning,
    DomainConstants.questionCategoryLearningDisplay,
    DomainConstants.questionCategoryLearningDescription,
  ),
  problemSolving(
    DomainConstants.questionCategoryProblemSolving,
    DomainConstants.questionCategoryProblemSolvingDisplay,
    DomainConstants.questionCategoryProblemSolvingDescription,
  ),
  achievement(
    DomainConstants.questionCategoryAchievement,
    DomainConstants.questionCategoryAchievementDisplay,
    DomainConstants.questionCategoryAchievementDescription,
  ),
  reflection(
    DomainConstants.questionCategoryReflection,
    DomainConstants.questionCategoryReflectionDisplay,
    DomainConstants.questionCategoryReflectionDescription,
  ),
  skills(
    DomainConstants.questionCategorySkills,
    DomainConstants.questionCategorySkillsDisplay,
    DomainConstants.questionCategorySkillsDescription,
  ),
  teamwork(
    DomainConstants.questionCategoryTeamwork,
    DomainConstants.questionCategoryTeamworkDisplay,
    DomainConstants.questionCategoryTeamworkDescription,
  ),
  safety(
    DomainConstants.questionCategorySafety,
    DomainConstants.questionCategorySafetyDisplay,
    DomainConstants.questionCategorySafetyDescription,
  ),
  goals(
    DomainConstants.questionCategoryGoals,
    DomainConstants.questionCategoryGoalsDisplay,
    DomainConstants.questionCategoryGoalsDescription,
  );

  const QuestionCategory(this.value, this.displayName, this.description);

  final String value;
  final String displayName;
  final String description;

  /// Gets category from string value
  static QuestionCategory fromValue(String value) {
    return QuestionCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => QuestionCategory.reflection,
    );
  }

  /// Gets all available categories
  static List<QuestionCategory> get allCategories => QuestionCategory.values;
}
