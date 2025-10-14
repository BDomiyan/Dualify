import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/entities.dart';
import '../../repositories/repositories.dart';
import '../usecase.dart';

/// Use case for getting the current apprentice profile
/// Follows Clean Architecture and Single Responsibility Principle
class GetProfileUseCase implements UseCase<ApprenticeProfile?, NoParams> {
  final ILocalApprenticeshipRepository _repository;

  const GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, ApprenticeProfile?>> call(NoParams params) async {
    try {
      // Get profile from repository
      final profileResult = await _repository.getProfile();

      return profileResult.fold((failure) => Left(failure), (profile) {
        if (profile == null) {
          // No profile found - this is a valid state
          return const Right(null);
        }

        // Validate the retrieved profile
        final validationErrors = profile.validate();
        if (validationErrors.isNotEmpty) {
          return Left(
            DataFailure(
              'Retrieved profile is invalid: ${validationErrors.join(', ')}',
              code: 'RETRIEVED_PROFILE_INVALID',
            ),
          );
        }

        // Check if profile data is consistent
        if (!profile.isValid) {
          return Left(
            DataFailure(
              'Profile data integrity check failed',
              code: 'PROFILE_INTEGRITY_CHECK_FAILED',
            ),
          );
        }

        return Right(profile);
      });
    } catch (e) {
      return Left(
        DataFailure(
          'Unexpected error retrieving profile: ${e.toString()}',
          code: 'PROFILE_RETRIEVAL_UNEXPECTED_ERROR',
        ),
      );
    }
  }
}
