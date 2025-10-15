import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileCreateRequested extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime apprenticeshipStartDate;
  final DateTime apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;

  const ProfileCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.trade,
    required this.apprenticeshipStartDate,
    required this.apprenticeshipEndDate,
    this.companyName,
    this.schoolName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    trade,
    apprenticeshipStartDate,
    apprenticeshipEndDate,
    companyName,
    schoolName,
    email,
    phone,
  ];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? trade;
  final DateTime? apprenticeshipStartDate;
  final DateTime? apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;
  final bool? isCompanyVerified;
  final bool? isSchoolVerified;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.trade,
    this.apprenticeshipStartDate,
    this.apprenticeshipEndDate,
    this.companyName,
    this.schoolName,
    this.email,
    this.phone,
    this.isCompanyVerified,
    this.isSchoolVerified,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    trade,
    apprenticeshipStartDate,
    apprenticeshipEndDate,
    companyName,
    schoolName,
    email,
    phone,
    isCompanyVerified,
    isSchoolVerified,
  ];
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}
