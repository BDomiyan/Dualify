/// Domain entities exports
/// Contains all core business entities for the Dualify Dashboard
library;

// Auth entities
export 'auth/auth_provider.dart';
export 'auth/auth_status.dart';
export 'auth/auth_user.dart';
export 'auth/auth_user_factory.dart';
export 'auth/user_session.dart';

// Apprentice entities
export 'apprentice/apprentice_profile.dart';
export 'apprentice/apprentice_profile_factory.dart';
export 'apprentice/apprenticeship_status.dart';

// Daily log entities
export 'daily_log/daily_log.dart';
export 'daily_log/daily_log_factory.dart';
export 'daily_log/daily_log_statistics.dart';
export 'daily_log/daily_log_status.dart';
export 'daily_log/daily_log_utils.dart';

// Question entities
export 'question/question_category.dart';
export 'question/question_of_the_day.dart';
export 'question/question_of_the_day_factory.dart';

// External dependencies
export '../../../core/services/progress_calculation_service.dart'
    show ProgressCalculationResult;
