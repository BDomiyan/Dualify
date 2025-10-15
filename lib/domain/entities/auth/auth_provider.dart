import '../../../core/constants/domain_constants.dart';

/// Enumeration for authentication providers
enum AuthProvider {
  google(
    DomainConstants.authProviderGoogle,
    DomainConstants.authProviderGoogleDisplay,
  ),
  apple(
    DomainConstants.authProviderApple,
    DomainConstants.authProviderAppleDisplay,
  ),
  email(
    DomainConstants.authProviderEmail,
    DomainConstants.authProviderEmailDisplay,
  ),
  anonymous(
    DomainConstants.authProviderAnonymous,
    DomainConstants.authProviderAnonymousDisplay,
  ),
  mock(
    DomainConstants.authProviderMock,
    DomainConstants.authProviderMockDisplay,
  ); // For testing/development

  const AuthProvider(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Gets provider from string value
  static AuthProvider fromValue(String value) {
    return AuthProvider.values.firstWhere(
      (provider) => provider.value == value,
      orElse: () => AuthProvider.anonymous,
    );
  }

  /// Gets all available providers
  static List<AuthProvider> get allProviders => AuthProvider.values;

  /// Checks if this is a social provider
  bool get isSocialProvider =>
      this == AuthProvider.google || this == AuthProvider.apple;

  /// Checks if this provider supports email verification
  bool get supportsEmailVerification =>
      this != AuthProvider.anonymous && this != AuthProvider.mock;
}
