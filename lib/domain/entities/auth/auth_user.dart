import 'package:equatable/equatable.dart';

import '../../../core/constants/domain_constants.dart';
import 'auth_provider.dart';

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
    final parts = displayName!.split(DomainConstants.spaceCharacter);
    return parts.isNotEmpty ? parts.first : null;
  }

  /// Gets the last name from display name
  String? get lastName {
    if (displayName == null || displayName!.isEmpty) return null;
    final parts = displayName!.split(DomainConstants.spaceCharacter);
    return parts.length > 1
        ? parts.skip(1).join(DomainConstants.spaceCharacter)
        : null;
  }

  /// Gets initials for avatar display
  String get initials {
    if (displayName?.isNotEmpty == true) {
      final parts = displayName!.split(DomainConstants.spaceCharacter);
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty) {
        return parts.first[0].toUpperCase();
      }
    }

    // Fall back to email
    return email.isNotEmpty
        ? email[0].toUpperCase()
        : DomainConstants.fallbackInitial;
  }

  /// Checks if the user has a profile photo
  bool get hasProfilePhoto => photoUrl?.isNotEmpty == true;

  /// Gets the time since last sign in
  Duration get timeSinceLastSignIn => DateTime.now().difference(lastSignInAt);

  /// Checks if the user signed in recently (within last hour)
  bool get signedInRecently =>
      timeSinceLastSignIn.inHours < DomainConstants.recentSignInWindowHours;

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
      errors.add(DomainConstants.errorUserIdRequired);
    }

    if (email.trim().isEmpty) {
      errors.add(DomainConstants.errorEmailRequired);
    } else {
      // Basic email validation
      final emailRegex = RegExp(DomainConstants.emailRegexPattern);
      if (!emailRegex.hasMatch(email)) {
        errors.add(DomainConstants.errorInvalidEmail);
      }
    }

    if (displayName != null &&
        displayName!.length > DomainConstants.maxDisplayNameLength) {
      errors.add(DomainConstants.errorDisplayNameTooLong);
    }

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      try {
        Uri.parse(photoUrl!);
      } catch (e) {
        errors.add(DomainConstants.errorInvalidPhotoUrl);
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
