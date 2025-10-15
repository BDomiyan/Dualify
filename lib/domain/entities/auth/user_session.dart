import 'package:equatable/equatable.dart';

import '../../../core/constants/domain_constants.dart';
import 'auth_user.dart';

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
    return sessionDuration.inHours > DomainConstants.maxSessionDurationHours;
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
