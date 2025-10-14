import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated user
/// Immutable entity following Domain-Driven Design principles
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final AuthProvider provider;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final Map<String, dynamic> metadata;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.lastSignInAt,
    this.metadata = const {},
  });

  /// Creates a copy of this user with updated fields
  AuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AuthProvider? provider,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Gets the display name or falls back to email
  String get displayNameOrEmail =>
      displayName?.isNotEmpty == true ? displayName! : email;

  /// Gets the first name from display name
  String? get firstName {
    if (displayName == null || displayName!.isEmpty) return null;
    final parts = displayName!.split(' ');
    return parts.isNotEmpty ? parts.first : null;
  }

  /// Gets the last name from display name
  String? get lastName {
    if (displayName == null || displayName!.isEmpty) return null;
    final parts = displayName!.split(' ');
    return parts.length > 1 ? parts.skip(1).join(' ') : null;
  }

  /// Gets initials for avatar display
  String get initials {
    if (displayName?.isNotEmpty == true) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts.first[0].toUpperCase();
      }
    }

    // Fall back to email
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  /// Checks if the user has a profile photo
  bool get hasProfilePhoto => photoUrl?.isNotEmpty == true;

  /// Gets the time since last sign in
  Duration get timeSinceLastSignIn => DateTime.now().difference(lastSignInAt);

  /// Checks if the user signed in recently (within last hour)
  bool get signedInRecently => timeSinceLastSignIn.inHours < 1;

  /// Gets metadata value by key
  T? getMetadata<T>(String key) {
    final value = metadata[key];
    return value is T ? value : null;
  }

  /// Creates a copy with updated metadata
  AuthUser withMetadata(String key, dynamic value) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  /// Creates a copy with removed metadata
  AuthUser withoutMetadata(String key) {
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata.remove(key);
    return copyWith(metadata: newMetadata);
  }

  /// Validates the user data
  List<String> validate() {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('User ID is required');
    }

    if (email.trim().isEmpty) {
      errors.add('Email is required');
    } else {
      // Basic email validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(email)) {
        errors.add('Invalid email format');
      }
    }

    if (displayName != null && displayName!.length > 100) {
      errors.add('Display name cannot exceed 100 characters');
    }

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      try {
        Uri.parse(photoUrl!);
      } catch (e) {
        errors.add('Invalid photo URL format');
      }
    }

    return errors;
  }

  /// Checks if the user is valid
  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    provider,
    isEmailVerified,
    createdAt,
    lastSignInAt,
    metadata,
  ];

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, provider: ${provider.displayName})';
}

/// Enumeration for authentication providers
enum AuthProvider {
  google('google', 'Google', '🔍'),
  apple('apple', 'Apple', '🍎'),
  email('email', 'Email', '📧'),
  anonymous('anonymous', 'Anonymous', '👤'),
  mock('mock', 'Mock', '🧪'); // For testing/development

  const AuthProvider(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final String icon;

  /// Gets provider from string value
  static AuthProvider fromValue(String value) {
    return AuthProvider.values.firstWhere(
      (provider) => provider.value == value,
      orElse: () => AuthProvider.anonymous,
    );
  }

  /// Gets all available providers
  static List<AuthProvider> get allProviders => AuthProvider.values;

  /// Gets the display text with icon
  String get displayTextWithIcon => '$icon $displayName';

  /// Checks if this is a social provider
  bool get isSocialProvider =>
      this == AuthProvider.google || this == AuthProvider.apple;

  /// Checks if this provider supports email verification
  bool get supportsEmailVerification =>
      this != AuthProvider.anonymous && this != AuthProvider.mock;
}

/// Authentication status enumeration
enum AuthStatus {
  authenticated('authenticated', 'Authenticated'),
  unauthenticated('unauthenticated', 'Unauthenticated'),
  loading('loading', 'Loading'),
  error('error', 'Error');

  const AuthStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Gets status from string value
  static AuthStatus fromValue(String value) {
    return AuthStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AuthStatus.unauthenticated,
    );
  }
}

/// Factory class for creating AuthUser instances
class AuthUserFactory {
  /// Creates a new authenticated user
  static AuthUser create({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required AuthProvider provider,
    bool isEmailVerified = false,
    Map<String, dynamic> metadata = const {},
  }) {
    final now = DateTime.now();

    return AuthUser(
      id: id.trim(),
      email: email.trim().toLowerCase(),
      displayName: displayName?.trim(),
      photoUrl: photoUrl?.trim(),
      provider: provider,
      isEmailVerified: isEmailVerified,
      createdAt: now,
      lastSignInAt: now,
      metadata: Map<String, dynamic>.from(metadata),
    );
  }

  /// Creates a user from existing data (e.g., from storage)
  static AuthUser fromData({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required AuthProvider provider,
    bool isEmailVerified = false,
    required DateTime createdAt,
    required DateTime lastSignInAt,
    Map<String, dynamic> metadata = const {},
  }) {
    return AuthUser(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      provider: provider,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      metadata: metadata,
    );
  }

  /// Creates a mock user for testing/development
  static AuthUser createMockUser({
    String? id,
    String? email,
    String? displayName,
  }) {
    final now = DateTime.now();
    final mockId = id ?? 'mock_user_${now.millisecondsSinceEpoch}';
    final mockEmail = email ?? 'test@example.com';
    final mockDisplayName = displayName ?? 'Test User';

    return AuthUser(
      id: mockId,
      email: mockEmail,
      displayName: mockDisplayName,
      provider: AuthProvider.mock,
      isEmailVerified: true,
      createdAt: now,
      lastSignInAt: now,
      metadata: {'isMockUser': true, 'createdForTesting': true},
    );
  }

  /// Creates a user from JSON data
  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: AuthProvider.fromValue(json['provider'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: DateTime.parse(json['lastSignInAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Converts user to JSON
  static Map<String, dynamic> toJson(AuthUser user) {
    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'provider': user.provider.value,
      'isEmailVerified': user.isEmailVerified,
      'createdAt': user.createdAt.toIso8601String(),
      'lastSignInAt': user.lastSignInAt.toIso8601String(),
      'metadata': user.metadata,
    };
  }
}

/// User session information
class UserSession extends Equatable {
  final AuthUser user;
  final String sessionId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final bool isActive;

  const UserSession({
    required this.user,
    required this.sessionId,
    required this.sessionStart,
    this.sessionEnd,
    this.isActive = true,
  });

  /// Gets the session duration
  Duration get sessionDuration {
    final endTime = sessionEnd ?? DateTime.now();
    return endTime.difference(sessionStart);
  }

  /// Checks if the session is expired (inactive for more than 24 hours)
  bool get isExpired {
    if (!isActive) return true;
    return sessionDuration.inHours > 24;
  }

  /// Creates a copy with the session ended
  UserSession end() {
    return UserSession(
      user: user,
      sessionId: sessionId,
      sessionStart: sessionStart,
      sessionEnd: DateTime.now(),
      isActive: false,
    );
  }

  @override
  List<Object?> get props => [
    user,
    sessionId,
    sessionStart,
    sessionEnd,
    isActive,
  ];
}
