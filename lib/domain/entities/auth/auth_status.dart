import '../../../core/constants/domain_constants.dart';

/// Authentication status enumeration
enum AuthStatus {
  authenticated(
    DomainConstants.authStatusAuthenticated,
    DomainConstants.authStatusAuthenticatedDisplay,
  ),
  unauthenticated(
    DomainConstants.authStatusUnauthenticated,
    DomainConstants.authStatusUnauthenticatedDisplay,
  ),
  loading(
    DomainConstants.authStatusLoading,
    DomainConstants.authStatusLoadingDisplay,
  ),
  error(
    DomainConstants.authStatusError,
    DomainConstants.authStatusErrorDisplay,
  );

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
