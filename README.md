# Dualify Dashboard

A Flutter mobile application for tracking apprenticeship journeys, built with
Clean Architecture and SOLID principles.

## Features

- **Profile Management**: Track apprenticeship details, company, and school
  information
- **Daily Logging**: Record daily status and notes
- **Question of the Day**: Reflective questions for learning and growth
- **Progress Tracking**: Visual progress indicators and statistics
- **Offline-First**: All data stored locally with SQLite

---

## Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.0.0 or higher
  - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK**: Version 3.0.0 or higher (comes with Flutter)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
  - [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
  - [Android Studio Flutter Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)

### Platform-Specific Requirements

#### For Android Development

- **Android Studio**: Latest version
- **Android SDK**: API level 21 (Android 5.0) or higher
- **Java Development Kit (JDK)**: Version 11 or higher

#### For iOS Development (macOS only)

- **Xcode**: Latest version from Mac App Store
- **CocoaPods**: Install via `sudo gem install cocoapods`
- **iOS Simulator** or physical iOS device

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd dualify_dashboard
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all required components are installed. Fix any issues reported by
`flutter doctor`.

### 3. Install Dependencies

```bash
flutter pub get
```

This will install all required packages defined in `pubspec.yaml`.

### 4. Verify Project Structure

Ensure the following directories exist:

```
lib/
├── core/           # Shared utilities
├── data/           # Data layer
├── domain/         # Domain layer
└── presentation/   # Presentation layer
```

---

## Running the Application

### Run on Android Emulator

1. **Start Android Emulator**:
   - Open Android Studio → AVD Manager → Start an emulator
   - Or via command line: `emulator -avd <emulator_name>`

2. **Run the app**:
   ```bash
   flutter run
   ```

### Run on iOS Simulator (macOS only)

1. **Start iOS Simulator**:
   ```bash
   open -a Simulator
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

### Run on Physical Device

1. **Enable Developer Mode** on your device
2. **Connect device** via USB
3. **Verify device connection**:
   ```bash
   flutter devices
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

### Run in Release Mode

For better performance testing:

```bash
flutter run --release
```

---

## Architecture Overview

### Clean Architecture (3 Layers)

- **Presentation Layer**: BLoC pattern for state management, feature-based UI
  modules
- **Domain Layer**: Business logic with entities, use cases, and repository
  interfaces
- **Data Layer**: SQLite database and SharedPreferences for data persistence

### Key Design Principles

- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution,
  Interface Segregation, Dependency Inversion
- **Repository Pattern**: Abstraction between business logic and data sources
- **Use Case Pattern**: Single-purpose business operations
- **Either Pattern**: Type-safe functional error handling (using dartz)
- **Dependency Injection**: GetIt service locator for loose coupling

### Data Storage

- **SQLite**: Relational data (profiles, daily logs, questions) with foreign
  keys, indexes, and constraints
- **SharedPreferences**: Key-value storage for auth tokens and user settings

For detailed design documentation, see:

- [Design Choices Summary](../doc/DESIGN_CHOICES_SUMMARY.md) - Concise overview
- [Design Choices Documentation](../doc/DESIGN_CHOICES_DOCUMENTATION.md) -
  Comprehensive details

---

## Development Commands

### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/entities/apprentice_profile_test.dart
```

### Code Analysis

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Check formatting without modifying
flutter format --set-exit-if-changed lib/
```

### Build Commands

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release

# Build for specific flavor
flutter build apk --flavor production --release
```

### Clean Build

If you encounter build issues:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Project Structure

```
dualify_dashboard/
├── lib/
│   ├── core/                    # Shared utilities
│   │   ├── constants/           # App constants
│   │   ├── di/                  # Dependency injection
│   │   ├── errors/              # Error handling
│   │   ├── services/            # Core services
│   │   ├── theme/               # Design system
│   │   └── validation/          # Validation framework
│   ├── data/                    # Data layer
│   │   ├── datasources/         # SQLite data sources
│   │   ├── models/              # Data models
│   │   └── repositories/        # Repository implementations
│   ├── domain/                  # Domain layer
│   │   ├── entities/            # Business entities
│   │   ├── repositories/        # Repository interfaces
│   │   └── usecases/            # Business use cases
│   └── presentation/            # Presentation layer
│       ├── features/            # Feature modules
│       │   ├── auth/            # Authentication
│       │   ├── dashboard/       # Dashboard
│       │   ├── profile/         # Profile management
│       │   └── ...              # Other features
│       ├── navigation/          # Navigation logic
│       └── widgets/             # Shared widgets
├── test/                        # Unit and widget tests
└── pubspec.yaml                 # Dependencies
```

---

## Key Dependencies

### State Management

- `flutter_bloc`: ^8.1.3 - BLoC pattern implementation
- `equatable`: ^2.0.5 - Value equality for entities

### Data Persistence

- `sqflite`: ^2.3.0 - SQLite database
- `shared_preferences`: ^2.2.2 - Key-value storage

### Dependency Injection

- `get_it`: ^7.6.4 - Service locator

### Functional Programming

- `dartz`: ^0.10.1 - Either type for error handling

### UI

- `google_fonts`: ^6.1.0 - Custom fonts
- `intl`: ^0.18.1 - Internationalization

---

## Database

### SQLite Schema

The app uses SQLite with three main tables:

- **profiles**: Apprentice profile information
- **daily_logs**: Daily status and notes
- **questions**: Question of the day responses

Database features:

- Foreign key constraints
- Check constraints for validation
- Indexes for performance
- WAL mode for concurrency
- Transaction support

### Database Location

- **Android**:
  `/data/data/com.example.dualify_dashboard/databases/dualify_dashboard.db`
- **iOS**: `Library/Application Support/dualify_dashboard.db`

---

## Configuration

### App Configuration

Edit `lib/core/constants/app_config.dart` to modify:

- App name and version
- Route names
- Debug settings

### Theme Configuration

Edit `lib/core/theme/` files to customize:

- Colors (`app_colors.dart`)
- Typography (`app_text_styles.dart`)
- Spacing (`app_spacing.dart`)
- Dimensions (`app_dimensions.dart`)

---

## Troubleshooting

### Common Issues

**Issue**: `flutter doctor` shows issues

- **Solution**: Follow the instructions provided by `flutter doctor` to resolve
  each issue

**Issue**: Dependencies not installing

- **Solution**:
  ```bash
  flutter clean
  flutter pub cache repair
  flutter pub get
  ```

**Issue**: Build fails on iOS

- **Solution**:
  ```bash
  cd ios
  pod install
  cd ..
  flutter run
  ```

**Issue**: Database errors

- **Solution**: Uninstall and reinstall the app to reset the database

**Issue**: Hot reload not working

- **Solution**: Stop the app and run `flutter run` again

---

## Testing

The project follows a comprehensive testing strategy:

- **Unit Tests**: Domain entities, use cases, validators
- **Widget Tests**: UI components and BLoC integration
- **Integration Tests**: End-to-end feature testing

Run tests before committing:

```bash
flutter test
flutter analyze
```

---

## Contributing

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
  guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Write self-documenting code with minimal comments
- Maintain SOLID principles

### Before Committing

1. Run tests: `flutter test`
2. Analyze code: `flutter analyze`
3. Format code: `flutter format lib/`
4. Ensure no warnings or errors

---

## Resources

### Flutter Documentation

- [Flutter Official Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

### Architecture Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [BLoC Pattern](https://bloclibrary.dev/)

### Project Documentation

- [Design Choices Summary](../doc/DESIGN_CHOICES_SUMMARY.md)
- [Design Choices Documentation](../doc/DESIGN_CHOICES_DOCUMENTATION.md)

---

## License

This project is licensed under the MIT License - see the LICENSE file for
details.

---

## Support

For issues, questions, or contributions, please contact the development team or
open an issue in the repository.
