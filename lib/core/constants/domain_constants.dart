/// Domain-specific validation and business rule constants
/// These constants define business rules and validation limits for domain entities
///
/// Note: This file should NOT contain UI-specific values like colors or emojis
/// Those belong in the presentation layer
class DomainConstants {
  // Private constructor to prevent instantiation
  DomainConstants._();

  // ============================================================================
  // AUTH USER VALIDATION
  // ============================================================================

  /// Maximum length for user display name
  static const int maxDisplayNameLength = 100;

  /// Prefix for mock user IDs (testing/development)
  static const String mockUserIdPrefix = 'mock_user_';

  /// Default email for mock users
  static const String mockUserEmail = 'test@example.com';

  /// Default display name for mock users
  static const String mockUserDisplayName = 'Test User';

  /// Email validation regex pattern
  static const String emailRegexPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // ============================================================================
  // DAILY LOG VALIDATION
  // ============================================================================

  /// Maximum number of days in the future for daily log entries
  static const int maxDailyLogFutureDays = 7;

  /// Maximum number of years in the past for daily log entries
  static const int maxDailyLogPastYears = 2;

  /// Maximum length for daily log notes
  static const int maxDailyLogNotesLength = 500;

  /// Number of days to display in daily log view
  static const int dailyLogDisplayDays = 7;

  /// Offset for daily log date range (days before today)
  static const int dailyLogDateOffset = 6;

  // ============================================================================
  // QUESTION OF THE DAY VALIDATION
  // ============================================================================

  /// Maximum length for question text
  static const int maxQuestionLength = 500;

  /// Maximum length for response text
  static const int maxResponseLength = 2000;

  /// Minimum word count for a valid response
  static const int minResponseWordCount = 5;

  /// Minimum character count for a valid response
  static const int minResponseCharCount = 20;

  /// ID prefix for question of the day
  static const String questionIdPrefix = 'qotd_';

  // ============================================================================
  // APPRENTICE PROFILE VALIDATION
  // ============================================================================

  /// Label for unspecified company or school
  static const String notSpecifiedLabel = 'Not specified';

  /// Average days per year (accounting for leap years)
  static const double daysPerYear = 365.25;

  /// Average days per month
  static const double daysPerMonth = 30.44;

  /// Minimum apprenticeship duration in days (6 months)
  static const int minApprenticeDurationDays = 180;

  /// Maximum apprenticeship duration in years
  static const int maxApprenticeDurationYears = 8;

  /// Maximum apprenticeship duration in days
  static const int maxApprenticeDurationDays = 365 * 8;

  /// ID prefix for apprentice profiles
  static const String profileIdPrefix = 'profile_';

  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================

  /// Maximum session duration in hours before expiration
  static const int maxSessionDurationHours = 24;

  /// Time window in hours to consider a sign-in as "recent"
  static const int recentSignInWindowHours = 1;

  // ============================================================================
  // METADATA KEYS
  // ============================================================================

  /// Metadata key indicating a mock user
  static const String metadataIsMockUser = 'isMockUser';

  /// Metadata key indicating user was created for testing
  static const String metadataCreatedForTesting = 'createdForTesting';

  // ============================================================================
  // DATE CALCULATIONS
  // ============================================================================

  /// Days in a week
  static const int daysInWeek = 7;

  /// Months in a year
  static const int monthsInYear = 12;

  /// Hours in a day
  static const int hoursInDay = 24;

  // ============================================================================
  // ENTITY ID GENERATION
  // ============================================================================

  /// ID prefix for daily log entries
  static const String dailyLogIdPrefix = 'daily_log_';

  /// ID separator for generated IDs
  static const String idSeparator = '_';

  // ============================================================================
  // VALIDATION ERROR MESSAGES
  // ============================================================================

  /// Error message for empty user ID
  static const String errorUserIdRequired = 'User ID is required';

  /// Error message for empty email
  static const String errorEmailRequired = 'Email is required';

  /// Error message for invalid email format
  static const String errorInvalidEmail = 'Invalid email format';

  /// Error message for display name too long
  static const String errorDisplayNameTooLong =
      'Display name cannot exceed 100 characters';

  /// Error message for invalid photo URL
  static const String errorInvalidPhotoUrl = 'Invalid photo URL format';

  /// Error message for empty profile ID
  static const String errorProfileIdRequired = 'Profile ID is required';

  /// Error message for date too far in future
  static const String errorDateTooFarFuture =
      'Date cannot be more than 7 days in the future';

  /// Error message for date too far in past
  static const String errorDateTooFarPast =
      'Date cannot be more than 2 years in the past';

  /// Error message for notes too long
  static const String errorNotesTooLong = 'Notes cannot exceed 500 characters';

  /// Error message for empty question
  static const String errorQuestionRequired = 'Question text is required';

  /// Error message for question too long
  static const String errorQuestionTooLong =
      'Question text cannot exceed 500 characters';

  /// Error message for response too long
  static const String errorResponseTooLong =
      'Response cannot exceed 2000 characters';

  /// Error message for missing response date
  static const String errorResponseDateRequired =
      'Response date is required when response is provided';

  /// Error message for empty first name
  static const String errorFirstNameRequired = 'First name is required';

  /// Error message for empty last name
  static const String errorLastNameRequired = 'Last name is required';

  /// Error message for empty trade
  static const String errorTradeRequired = 'Trade is required';

  /// Error message for invalid date range
  static const String errorInvalidDateRange =
      'Apprenticeship end date must be after start date';

  /// Error message for duration too short
  static const String errorDurationTooShort =
      'Apprenticeship must be at least 6 months long';

  /// Error message for duration too long
  static const String errorDurationTooLong =
      'Apprenticeship cannot exceed 8 years';

  // ============================================================================
  // DISPLAY TEXT CONSTANTS
  // ============================================================================

  /// Display text for today
  static const String displayToday = 'Today';

  /// Display text for yesterday
  static const String displayYesterday = 'Yesterday';

  /// Display text for tomorrow
  static const String displayTomorrow = 'Tomorrow';

  /// Display text for answered today
  static const String displayAnsweredToday = 'Answered today';

  /// Display text for answered yesterday
  static const String displayAnsweredYesterday = 'Answered yesterday';

  /// Fallback character for unknown/missing initials
  static const String fallbackInitial = '?';

  /// Space character for splitting names
  static const String spaceCharacter = ' ';

  /// Weekday abbreviations
  static const List<String> weekdayAbbreviations = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Month names
  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ============================================================================
  // AUTHENTICATION PROVIDER VALUES
  // ============================================================================

  /// Google authentication provider value
  static const String authProviderGoogle = 'google';

  /// Apple authentication provider value
  static const String authProviderApple = 'apple';

  /// Email authentication provider value
  static const String authProviderEmail = 'email';

  /// Anonymous authentication provider value
  static const String authProviderAnonymous = 'anonymous';

  /// Mock authentication provider value (testing)
  static const String authProviderMock = 'mock';

  // ============================================================================
  // AUTHENTICATION PROVIDER DISPLAY NAMES
  // ============================================================================

  /// Google provider display name
  static const String authProviderGoogleDisplay = 'Google';

  /// Apple provider display name
  static const String authProviderAppleDisplay = 'Apple';

  /// Email provider display name
  static const String authProviderEmailDisplay = 'Email';

  /// Anonymous provider display name
  static const String authProviderAnonymousDisplay = 'Anonymous';

  /// Mock provider display name
  static const String authProviderMockDisplay = 'Mock';

  // ============================================================================
  // AUTHENTICATION STATUS VALUES
  // ============================================================================

  /// Authenticated status value
  static const String authStatusAuthenticated = 'authenticated';

  /// Unauthenticated status value
  static const String authStatusUnauthenticated = 'unauthenticated';

  /// Loading status value
  static const String authStatusLoading = 'loading';

  /// Error status value
  static const String authStatusError = 'error';

  // ============================================================================
  // AUTHENTICATION STATUS DISPLAY NAMES
  // ============================================================================

  /// Authenticated status display name
  static const String authStatusAuthenticatedDisplay = 'Authenticated';

  /// Unauthenticated status display name
  static const String authStatusUnauthenticatedDisplay = 'Unauthenticated';

  /// Loading status display name
  static const String authStatusLoadingDisplay = 'Loading';

  /// Error status display name
  static const String authStatusErrorDisplay = 'Error';

  // ============================================================================
  // DAILY LOG STATUS VALUES
  // ============================================================================

  /// Learning status value
  static const String dailyLogStatusLearning = 'learning';

  /// Challenging status value
  static const String dailyLogStatusChallenging = 'challenging';

  /// Neutral status value
  static const String dailyLogStatusNeutral = 'neutral';

  /// Good status value
  static const String dailyLogStatusGood = 'good';

  // ============================================================================
  // DAILY LOG STATUS DESCRIPTIONS
  // ============================================================================

  /// Learning status display name
  static const String dailyLogStatusLearningDisplay = 'Learning';

  /// Learning status description
  static const String dailyLogStatusLearningDescription =
      'Had a great learning day';

  /// Challenging status display name
  static const String dailyLogStatusChallengingDisplay = 'Challenging';

  /// Challenging status description
  static const String dailyLogStatusChallengingDescription =
      'Faced some challenges but pushed through';

  /// Neutral status display name
  static const String dailyLogStatusNeutralDisplay = 'Neutral';

  /// Neutral status description
  static const String dailyLogStatusNeutralDescription =
      'A regular day at work';

  /// Good status display name
  static const String dailyLogStatusGoodDisplay = 'Good';

  /// Good status description
  static const String dailyLogStatusGoodDescription =
      'Had a good productive day';

  // ============================================================================
  // QUESTION CATEGORY VALUES
  // ============================================================================

  /// Learning category value
  static const String questionCategoryLearning = 'learning';

  /// Problem solving category value
  static const String questionCategoryProblemSolving = 'problem-solving';

  /// Achievement category value
  static const String questionCategoryAchievement = 'achievement';

  /// Reflection category value
  static const String questionCategoryReflection = 'reflection';

  /// Skills category value
  static const String questionCategorySkills = 'skills';

  /// Teamwork category value
  static const String questionCategoryTeamwork = 'teamwork';

  /// Safety category value
  static const String questionCategorySafety = 'safety';

  /// Goals category value
  static const String questionCategoryGoals = 'goals';

  // ============================================================================
  // QUESTION CATEGORY DISPLAY NAMES AND DESCRIPTIONS
  // ============================================================================

  /// Learning category display name
  static const String questionCategoryLearningDisplay = 'Learning';

  /// Learning category description
  static const String questionCategoryLearningDescription =
      'Questions about what you learned';

  /// Problem solving category display name
  static const String questionCategoryProblemSolvingDisplay = 'Problem Solving';

  /// Problem solving category description
  static const String questionCategoryProblemSolvingDescription =
      'Questions about challenges and solutions';

  /// Achievement category display name
  static const String questionCategoryAchievementDisplay = 'Achievement';

  /// Achievement category description
  static const String questionCategoryAchievementDescription =
      'Questions about accomplishments and milestones';

  /// Reflection category display name
  static const String questionCategoryReflectionDisplay = 'Reflection';

  /// Reflection category description
  static const String questionCategoryReflectionDescription =
      'Questions for self-reflection and growth';

  /// Skills category display name
  static const String questionCategorySkillsDisplay = 'Skills';

  /// Skills category description
  static const String questionCategorySkillsDescription =
      'Questions about skill development';

  /// Teamwork category display name
  static const String questionCategoryTeamworkDisplay = 'Teamwork';

  /// Teamwork category description
  static const String questionCategoryTeamworkDescription =
      'Questions about collaboration and communication';

  /// Safety category display name
  static const String questionCategorySafetyDisplay = 'Safety';

  /// Safety category description
  static const String questionCategorySafetyDescription =
      'Questions about workplace safety and best practices';

  /// Goals category display name
  static const String questionCategoryGoalsDisplay = 'Goals';

  /// Goals category description
  static const String questionCategoryGoalsDescription =
      'Questions about future goals and aspirations';

  // ============================================================================
  // APPRENTICESHIP STATUS DISPLAY NAMES
  // ============================================================================

  /// Not started status display name
  static const String apprenticeshipStatusNotStartedDisplay = 'Not Started';

  /// Active status display name
  static const String apprenticeshipStatusActiveDisplay = 'Active';

  /// Completed status display name
  static const String apprenticeshipStatusCompletedDisplay = 'Completed';
}
