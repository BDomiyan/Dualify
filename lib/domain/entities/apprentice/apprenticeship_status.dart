import '../../../core/constants/domain_constants.dart';

/// Enumeration for apprenticeship status
enum ApprenticeshipStatus {
  notStarted(DomainConstants.apprenticeshipStatusNotStartedDisplay),
  active(DomainConstants.apprenticeshipStatusActiveDisplay),
  completed(DomainConstants.apprenticeshipStatusCompletedDisplay);

  const ApprenticeshipStatus(this.displayName);
  final String displayName;
}
