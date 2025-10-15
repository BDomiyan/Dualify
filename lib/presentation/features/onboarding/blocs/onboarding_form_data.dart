import 'package:equatable/equatable.dart';

class OnboardingFormData extends Equatable {
  final String firstName;
  final String lastName;
  final String trade;
  final DateTime? apprenticeshipStartDate;
  final DateTime? apprenticeshipEndDate;
  final String? companyName;
  final String? schoolName;
  final String? email;
  final String? phone;

  const OnboardingFormData({
    this.firstName = '',
    this.lastName = '',
    this.trade = '',
    this.apprenticeshipStartDate,
    this.apprenticeshipEndDate,
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

  OnboardingFormData copyWith({
    String? firstName,
    String? lastName,
    String? trade,
    DateTime? apprenticeshipStartDate,
    DateTime? apprenticeshipEndDate,
    String? companyName,
    String? schoolName,
    String? email,
    String? phone,
  }) {
    return OnboardingFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      trade: trade ?? this.trade,
      apprenticeshipStartDate:
          apprenticeshipStartDate ?? this.apprenticeshipStartDate,
      apprenticeshipEndDate:
          apprenticeshipEndDate ?? this.apprenticeshipEndDate,
      companyName: companyName ?? this.companyName,
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        trade.isNotEmpty &&
        apprenticeshipStartDate != null &&
        apprenticeshipEndDate != null;
  }
}
