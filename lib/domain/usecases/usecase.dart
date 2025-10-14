import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/errors/failures.dart';

/// Base interface for all use cases
/// Follows Command Pattern and Single Responsibility Principle
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  /// Returns Either a Failure or the expected Type
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't require parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}

/// Base class for use cases with a single parameter
class SingleParam<T> extends Equatable {
  final T value;

  const SingleParam(this.value);

  @override
  List<Object?> get props => [value];
}

/// Base class for use cases with two parameters
class TwoParams<T1, T2> extends Equatable {
  final T1 first;
  final T2 second;

  const TwoParams(this.first, this.second);

  @override
  List<Object?> get props => [first, second];
}

/// Base class for use cases with three parameters
class ThreeParams<T1, T2, T3> extends Equatable {
  final T1 first;
  final T2 second;
  final T3 third;

  const ThreeParams(this.first, this.second, this.third);

  @override
  List<Object?> get props => [first, second, third];
}
