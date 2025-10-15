import '../../../core/constants/domain_constants.dart';
import 'auth_provider.dart';
import 'auth_user.dart';

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
    final mockId =
        id ??
        '${DomainConstants.mockUserIdPrefix}${now.millisecondsSinceEpoch}';
    final mockEmail = email ?? DomainConstants.mockUserEmail;
    final mockDisplayName = displayName ?? DomainConstants.mockUserDisplayName;

    return AuthUser(
      id: mockId,
      email: mockEmail,
      displayName: mockDisplayName,
      provider: AuthProvider.mock,
      isEmailVerified: true,
      createdAt: now,
      lastSignInAt: now,
      metadata: {
        DomainConstants.metadataIsMockUser: true,
        DomainConstants.metadataCreatedForTesting: true,
      },
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
