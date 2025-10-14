/// Domain use cases exports
/// Contains all use cases following Clean Architecture principles
library;

// Base use case interface
export 'usecase.dart';

// Authentication use cases
export 'auth/check_auth_status_usecase.dart';
export 'auth/sign_in_with_mock_google_usecase.dart';

// Profile management use cases
export 'profile/create_profile_usecase.dart';
export 'profile/get_profile_usecase.dart';
export 'profile/update_profile_usecase.dart';

// Dashboard use cases
export 'dashboard/get_dashboard_data_usecase.dart';
export 'dashboard/refresh_qotd_usecase.dart';
export 'dashboard/update_daily_status_usecase.dart';
