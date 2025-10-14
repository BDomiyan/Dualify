import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_datasources.dart';
import '../../data/repositories/repositories.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/usecases.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/profile/profile_bloc.dart';
import '../../presentation/blocs/dashboard/dashboard_bloc.dart';
import '../../presentation/blocs/onboarding/onboarding_bloc.dart';

import '../services/question_of_the_day_service.dart';
import '../storage/shared_preferences_service.dart';
import '../utils/logger.dart';
import '../validation/form_validator.dart';

/// Dependency injection container using GetIt
/// Follows Dependency Inversion Principle and Single Responsibility Principle
/// Manages all app dependencies in a centralized location
final sl = GetIt.instance;

/// Initializes all dependencies for the application
/// Must be called before app startup to ensure proper dependency resolution
Future<void> initializeDependencies() async {
  AppLogger.info('Initializing dependencies...');

  try {
    // Initialize external dependencies first
    await _initializeExternalDependencies();

    // Initialize core services
    _initializeCoreServices();

    // Initialize data sources
    _initializeDataSources();

    // Initialize repositories
    _initializeRepositories();

    // Initialize use cases
    _initializeUseCases();

    // Initialize BLoCs
    _initializeBlocs();

    AppLogger.info('Dependencies initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.fatal('Failed to initialize dependencies: $e', e, stackTrace);
    rethrow;
  }
}

/// Initializes external dependencies that require async operations
/// These are dependencies that need to be initialized before other services
Future<void> _initializeExternalDependencies() async {
  AppLogger.debug('Initializing external dependencies...');

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Initialize SharedPreferencesService
  await SharedPreferencesService.init();

  AppLogger.debug('External dependencies initialized');
}

/// Initializes core services that don't depend on other services
/// These are foundational services used throughout the app
void _initializeCoreServices() {
  AppLogger.debug('Initializing core services...');

  // Database Helper (Singleton)
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Question of the Day Service (Singleton)
  sl.registerLazySingleton<QuestionOfTheDayService>(
    () => QuestionOfTheDayService(),
  );

  // Form Validator (Singleton)
  sl.registerLazySingleton<FormValidator>(
    () => const FormValidator(fieldValidations: []),
  );

  AppLogger.debug('Core services initialized');
}

/// Initializes data sources for local storage operations
/// These handle direct interaction with SQLite and SharedPreferences
void _initializeDataSources() {
  AppLogger.debug('Initializing data sources...');

  // Local Profile Data Source
  sl.registerLazySingleton<LocalProfileDataSource>(
    () => LocalProfileDataSource(sl<DatabaseHelper>()),
  );

  // Local Daily Log Data Source
  sl.registerLazySingleton<LocalDailyLogDataSource>(
    () => LocalDailyLogDataSource(sl<DatabaseHelper>()),
  );

  // Local Question Data Source
  sl.registerLazySingleton<LocalQuestionDataSource>(
    () => LocalQuestionDataSource(sl<DatabaseHelper>()),
  );

  AppLogger.debug('Data sources initialized');
}

/// Initializes repository implementations
/// These provide abstraction over data sources following Repository pattern
void _initializeRepositories() {
  AppLogger.debug('Initializing repositories...');

  // Local Apprenticeship Repository
  sl.registerLazySingleton<ILocalApprenticeshipRepository>(
    () => LocalApprenticeshipRepositoryImpl(
      sl<LocalProfileDataSource>(),
      sl<LocalDailyLogDataSource>(),
      sl<LocalQuestionDataSource>(),
    ),
  );

  // Local Auth Repository
  sl.registerLazySingleton<IAuthRepository>(() => LocalAuthRepositoryImpl());

  AppLogger.debug('Repositories initialized');
}

/// Initializes use cases for business logic
/// These encapsulate specific business operations following Single Responsibility
void _initializeUseCases() {
  AppLogger.debug('Initializing use cases...');

  // Authentication Use Cases
  sl.registerLazySingleton(
    () => SignInWithMockGoogleUseCase(sl<IAuthRepository>()),
  );
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<IAuthRepository>()));

  // Profile Management Use Cases
  sl.registerLazySingleton(
    () => CreateProfileUseCase(sl<ILocalApprenticeshipRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProfileUseCase(sl<ILocalApprenticeshipRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateProfileUseCase(sl<ILocalApprenticeshipRepository>()),
  );

  // Dashboard Use Cases
  sl.registerLazySingleton(
    () => GetDashboardDataUseCase(sl<ILocalApprenticeshipRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateDailyStatusUseCase(sl<ILocalApprenticeshipRepository>()),
  );
  sl.registerLazySingleton(
    () => RefreshQotdUseCase(sl<ILocalApprenticeshipRepository>()),
  );

  AppLogger.debug('Use cases initialized');
}

/// Initializes BLoC instances for state management
/// These are registered as factories to create new instances when needed
void _initializeBlocs() {
  AppLogger.debug('Initializing BLoCs...');

  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
      signInWithGoogleUseCase: sl<SignInWithMockGoogleUseCase>(),
    ),
  );

  // Profile BLoC
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl<GetProfileUseCase>(),
      createProfileUseCase: sl<CreateProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
    ),
  );

  // Dashboard BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardDataUseCase: sl<GetDashboardDataUseCase>(),
      updateDailyStatusUseCase: sl<UpdateDailyStatusUseCase>(),
      refreshQotdUseCase: sl<RefreshQotdUseCase>(),
    ),
  );

  // Onboarding BLoC
  sl.registerFactory(
    () => OnboardingBloc(
      createProfileUseCase: sl<CreateProfileUseCase>(),
      formValidator: sl<FormValidator>(),
    ),
  );

  AppLogger.debug('BLoCs initialized');
}

/// Resets all dependencies
/// Useful for testing or when reinitializing the app
Future<void> resetDependencies() async {
  AppLogger.info('Resetting dependencies...');
  await sl.reset();
  AppLogger.info('Dependencies reset successfully');
}
