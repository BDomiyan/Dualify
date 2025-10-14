/// Application-wide string constants
/// Centralized location for all UI strings, labels, and messages
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // ============================================================================
  // NAVIGATION & TABS
  // ============================================================================
  static const String dashboardLabel = 'Dashboard';
  static const String communityLabel = 'Community';
  static const String askDualifyLabel = 'Ask Dualify';
  static const String profileLabel = 'Profile';

  // ============================================================================
  // AUTHENTICATION
  // ============================================================================
  static const String appName = 'Dualify';
  static const String loginTitle = 'Track your apprenticeship journey';
  static const String loginSubtitle =
      'Stay organized and motivated throughout your learning experience';
  static const String continueWithGoogle = 'Continue with Google';
  static const String signingIn = 'Signing in...';
  static const String mockLoginDisclaimer =
      'Note: This is a mock login for demonstration purposes';
  static const String termsAndPrivacy =
      'By continuing, you agree to our Terms of Service and Privacy Policy';
  static const String welcomeBack = 'Welcome back';
  static const String signInToAccount = 'Sign in to your account';
  static const String forgotPassword = 'Forgot password?';
  static const String signIn = 'Sign In';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = 'Sign up';

  // ============================================================================
  // DASHBOARD
  // ============================================================================
  static const String welcomePrefix = 'Welcome, ';
  static const String dailyLogTitle = 'Daily Log';
  static const String questionOfTheDayTitle = 'Question of the Day';
  static const String viewResponses = 'View Responses';
  static const String todayLabel = 'TODAY';
  static const String daysRemainingPrefix = 'Days Remaining: ';
  static const String defaultMotivationalMessage = 'Keep up the great work! ✨';

  // ============================================================================
  // DAILY STATUS
  // ============================================================================
  static const String statusGood = 'good';
  static const String statusLearning = 'learning';
  static const String statusChallenging = 'challenging';
  static const String emojiGood = '✅';
  static const String emojiLearning = '🧠';
  static const String emojiChallenging = '🤔';
  static const String emojiEmpty = '—';
  static const String howWasYourDay = 'How was your day?';
  static const String statusGoodTitle = 'Good';
  static const String statusGoodDescription = 'Had a productive day';
  static const String statusLearningTitle = 'Learning';
  static const String statusLearningDescription =
      'Focused on learning new skills';
  static const String statusChallengingTitle = 'Challenging';
  static const String statusChallengingDescription = 'Faced some challenges';

  // ============================================================================
  // VERIFICATION
  // ============================================================================
  static const String verifiedLabel = 'Verified';
  static const String notVerifiedLabel = 'Not Verified';
  static const String companyLabel = 'Company';
  static const String schoolLabel = 'School';
  static const String defaultCompany = 'AFI Corp';
  static const String defaultSchool = 'City College';

  // ============================================================================
  // PROFILE
  // ============================================================================
  static const String updateYourProfile = 'Update Your Profile';
  static const String updateProfile = 'Update Profile';
  static const String fullName = 'Full Name';
  static const String fullNamePlaceholder = 'John Doe';
  static const String tradeProgram = 'Trade/Program';
  static const String tradePlaceholder = 'Select your trade';
  static const String startDate = 'Start Date';
  static const String apprenticeshipDuration =
      'Apprenticeship Duration (months)';
  static const String durationPlaceholder = 'e.g., 48';
  static const String noProfileFound = 'No Profile Found';
  static const String completeOnboardingFirst =
      'Please complete the onboarding process first.';

  // ============================================================================
  // TRADES
  // ============================================================================
  static const List<String> tradeOptions = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Welder',
  ];

  // ============================================================================
  // VALIDATION MESSAGES
  // ============================================================================
  static const String fullNameRequired = 'Full name is required';
  static const String tradeRequired = 'Please select your trade';
  static const String durationRequired = 'Duration is required';
  static const String invalidDuration = 'Please enter a valid duration';
  static const String durationTooShort = 'Duration must be at least 6 months';
  static const String durationTooLong =
      'Duration cannot exceed 96 months (8 years)';
  static const String emailRequired = 'Please enter your email';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort =
      'Password must be at least 6 characters';

  // ============================================================================
  // COMING SOON PAGES
  // ============================================================================
  static const String comingSoon = 'Coming Soon';
  static const String communityDescription =
      'Connect with fellow apprentices, share experiences, and learn from each other in our upcoming community feature.';
  static const String aiAssistantDescription =
      'Get personalized guidance and instant answers to your apprenticeship questions with our AI-powered assistant.';
  static const String whatToExpect = 'What to expect:';
  static const String notifyMeWhenAvailable = 'Notify Me When Available';
  static const String getNotified = 'Get Notified';
  static const String notifyDialogMessage =
      'We\'ll let you know as soon as this feature is available! Keep an eye on app updates.';
  static const String gotIt = 'Got it';

  // Community features
  static const List<String> communityFeatures = [
    'Discussion forums by trade',
    'Peer mentorship programs',
    'Experience sharing',
    'Q&A with experts',
    'Local meetup coordination',
  ];

  // AI Assistant features
  static const List<String> aiAssistantFeatures = [
    '24/7 instant support',
    'Trade-specific guidance',
    'Career path recommendations',
    'Learning resource suggestions',
    'Progress tracking insights',
  ];

  static const String aiAssistantPreviewTitle = 'AI Assistant Preview';
  static const String aiAssistantPreviewChat =
      '"How can I improve my welding technique?" \n\n'
      '🤖 I can help you with that! Here are some key areas to focus on for better welding...';
  static const String aboutAiAssistant = 'About AI Assistant';
  static const String aiAssistantAboutMessage =
      'Our AI Assistant will provide personalized guidance for your apprenticeship journey. '
      'It will be trained on trade-specific knowledge and best practices to help you succeed.';

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String loadingError = 'Failed to load data';
  static const String updateError = 'Failed to update';
  static const String networkError = 'Network connection error';

  // ============================================================================
  // SUCCESS MESSAGES
  // ============================================================================
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String statusUpdatedSuccess = 'Status updated successfully!';
  static const String dataRefreshedSuccess = 'Data refreshed successfully!';

  // ============================================================================
  // SNACKBAR MESSAGES
  // ============================================================================
  static const String notificationsComingSoon = 'Notifications coming soon!';
  static const String responsesComingSoon = 'Responses coming soon!';
  static const String verificationComingSoon = 'Verification coming soon!';
  static const String useMainNavigation = 'Use main navigation';
  static const String updatingLatestQuestions = 'Updating Latest questions...';

  // ============================================================================
  // FORM LABELS
  // ============================================================================
  static const String email = 'Email';
  static const String emailPlaceholder = 'Enter your email address';
  static const String password = 'Password';
  static const String passwordPlaceholder = 'Enter your password';

  // ============================================================================
  // DATE FORMATS
  // ============================================================================
  static const String dateFormatYMD = 'yyyy-MM-dd';
  static const String dateFormatShort =
      'E'; // Day abbreviation (Mon, Tue, etc.)

  // ============================================================================
  // ONBOARDING
  // ============================================================================
  static const String startYourJourney = 'Start Your Apprenticeship Journey';
  static const String calculateProgressAndStart = 'Calculate Progress & Start';

  // ============================================================================
  // SPLASH SCREEN
  // ============================================================================
  static const String settingUpJourney =
      'Setting up your apprenticeship journey...';
  static const String appVersion = 'Version 1.0.0';

  // ============================================================================
  // COMING SOON PAGES
  // ============================================================================
  static const String aiAssistant = 'AI Assistant';
  static const String community = 'Community';
  static const String aboutAiAssistantTitle = 'About AI Assistant';
  static const String aboutAiAssistantMessage =
      'Our AI Assistant will provide personalized guidance for your apprenticeship journey. '
      'It will be trained on trade-specific knowledge and best practices to help you succeed.';
  static const String communityNotifyMessage =
      'We\'ll let you know as soon as the community feature is available! Keep an eye on app updates.';
  static const String aiAssistantNotifyMessage =
      'We\'ll let you know as soon as the AI Assistant is available! Keep an eye on app updates.';

  // ============================================================================
  // ACCESSIBILITY
  // ============================================================================
  static const String notificationButtonLabel = 'Notifications';
  static const String refreshButtonLabel = 'Refresh';
  static const String backButtonLabel = 'Back';
  static const String closeButtonLabel = 'Close';
  static const String helpButtonLabel = 'Help';
}
