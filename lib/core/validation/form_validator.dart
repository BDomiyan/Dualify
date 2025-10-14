import 'validation_rule.dart';
import '../errors/exceptions.dart';

/// Form field validation configuration
class FieldValidation {
  final String fieldName;
  final List<ValidationRule> rules;
  final bool isRequired;

  const FieldValidation({
    required this.fieldName,
    required this.rules,
    this.isRequired = false,
  });

  /// Creates a field validation with required rule automatically added
  factory FieldValidation.required(
    String fieldName,
    List<ValidationRule> additionalRules,
  ) {
    return FieldValidation(
      fieldName: fieldName,
      rules: [RequiredRule(fieldName), ...additionalRules],
      isRequired: true,
    );
  }

  /// Creates a field validation for optional fields
  factory FieldValidation.optional(
    String fieldName,
    List<ValidationRule> rules,
  ) {
    return FieldValidation(
      fieldName: fieldName,
      rules: rules,
      isRequired: false,
    );
  }
}

/// Form validation result containing all field errors
class FormValidationResult {
  final bool isValid;
  final Map<String, String> fieldErrors;
  final List<String> generalErrors;

  const FormValidationResult({
    required this.isValid,
    this.fieldErrors = const {},
    this.generalErrors = const [],
  });

  /// Creates a valid result
  const FormValidationResult.valid()
    : isValid = true,
      fieldErrors = const {},
      generalErrors = const [];

  /// Creates an invalid result with field errors
  const FormValidationResult.invalid({
    required this.fieldErrors,
    this.generalErrors = const [],
  }) : isValid = false;

  /// Gets the first error message for a field
  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  /// Checks if a specific field has errors
  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);

  /// Gets all error messages as a list
  List<String> get allErrors => [...fieldErrors.values, ...generalErrors];

  /// Gets the first error message
  String? get firstError {
    if (fieldErrors.isNotEmpty) return fieldErrors.values.first;
    if (generalErrors.isNotEmpty) return generalErrors.first;
    return null;
  }

  @override
  String toString() =>
      isValid
          ? 'FormValidationResult: Valid'
          : 'FormValidationResult: Invalid (${allErrors.length} errors)';
}

/// Comprehensive form validator with composite validation support
class FormValidator {
  final List<FieldValidation> _fieldValidations;
  final List<ValidationRule> _formLevelRules;

  const FormValidator({
    required List<FieldValidation> fieldValidations,
    List<ValidationRule> formLevelRules = const [],
  }) : _fieldValidations = fieldValidations,
       _formLevelRules = formLevelRules;

  /// Validates all fields in the form data
  FormValidationResult validateForm(Map<String, dynamic> formData) {
    final Map<String, String> fieldErrors = {};
    final List<String> generalErrors = [];

    // Validate individual fields
    for (final fieldValidation in _fieldValidations) {
      final fieldName = fieldValidation.fieldName;
      final fieldValue = formData[fieldName];

      // Validate field with all its rules
      final fieldError = _validateField(fieldValidation, fieldValue, formData);
      if (fieldError != null) {
        fieldErrors[fieldName] = fieldError;
      }
    }

    // Validate form-level rules
    for (final rule in _formLevelRules) {
      final error = rule.validate(formData);
      if (error != null) {
        generalErrors.add(error);
      }
    }

    final isValid = fieldErrors.isEmpty && generalErrors.isEmpty;

    return FormValidationResult(
      isValid: isValid,
      fieldErrors: fieldErrors,
      generalErrors: generalErrors,
    );
  }

  /// Validates a single field
  String? validateField(
    String fieldName,
    dynamic value, [
    Map<String, dynamic>? formData,
  ]) {
    final fieldValidation =
        _fieldValidations.where((fv) => fv.fieldName == fieldName).firstOrNull;

    if (fieldValidation == null) {
      return null; // Field not configured for validation
    }

    return _validateField(fieldValidation, value, formData ?? {});
  }

  /// Internal method to validate a field with its rules
  String? _validateField(
    FieldValidation fieldValidation,
    dynamic value,
    Map<String, dynamic> formData,
  ) {
    for (final rule in fieldValidation.rules) {
      String? error;

      // Handle conditional rules
      if (rule is ConditionalRule) {
        if (rule.condition(formData)) {
          error = rule.rule.validate(value);
        }
      } else {
        error = rule.validate(value);
      }

      if (error != null) {
        return error; // Return first error found
      }
    }

    return null; // All validations passed
  }

  /// Validates form and throws ValidationException if invalid
  void validateFormOrThrow(Map<String, dynamic> formData) {
    final result = validateForm(formData);

    if (!result.isValid) {
      throw ValidationException.multipleFields(result.fieldErrors);
    }
  }

  /// Checks if a field is required
  bool isFieldRequired(String fieldName) {
    final fieldValidation =
        _fieldValidations.where((fv) => fv.fieldName == fieldName).firstOrNull;

    return fieldValidation?.isRequired ?? false;
  }

  /// Gets all validation rules for a field
  List<ValidationRule> getFieldRules(String fieldName) {
    final fieldValidation =
        _fieldValidations.where((fv) => fv.fieldName == fieldName).firstOrNull;

    return fieldValidation?.rules ?? [];
  }

  /// Gets field validation description
  String getFieldDescription(String fieldName) {
    final rules = getFieldRules(fieldName);
    if (rules.isEmpty) return '';

    return rules.map((rule) => rule.description).join(', ');
  }
}

/// Builder class for creating FormValidator instances
class FormValidatorBuilder {
  final List<FieldValidation> _fieldValidations = [];
  final List<ValidationRule> _formLevelRules = [];

  /// Adds a required field validation
  FormValidatorBuilder addRequiredField(
    String fieldName,
    List<ValidationRule> additionalRules,
  ) {
    _fieldValidations.add(FieldValidation.required(fieldName, additionalRules));
    return this;
  }

  /// Adds an optional field validation
  FormValidatorBuilder addOptionalField(
    String fieldName,
    List<ValidationRule> rules,
  ) {
    _fieldValidations.add(FieldValidation.optional(fieldName, rules));
    return this;
  }

  /// Adds a form-level validation rule
  FormValidatorBuilder addFormRule(ValidationRule rule) {
    _formLevelRules.add(rule);
    return this;
  }

  /// Builds the FormValidator instance
  FormValidator build() {
    return FormValidator(
      fieldValidations: List.unmodifiable(_fieldValidations),
      formLevelRules: List.unmodifiable(_formLevelRules),
    );
  }
}

/// Common validation rule factories for convenience
class ValidationRules {
  /// Creates a required text field validation
  static List<ValidationRule> requiredText(
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    return [
      RequiredRule(fieldName),
      if (minLength != null || maxLength != null)
        LengthRule(fieldName, minLength: minLength, maxLength: maxLength),
    ];
  }

  /// Creates an email field validation
  static List<ValidationRule> email(String fieldName, {bool required = true}) {
    return [if (required) RequiredRule(fieldName), EmailRule(fieldName)];
  }

  /// Creates a date field validation
  static List<ValidationRule> date(
    String fieldName, {
    bool required = true,
    DateTime? minDate,
    DateTime? maxDate,
    bool allowFuture = true,
    bool allowPast = true,
  }) {
    return [
      if (required) RequiredRule(fieldName),
      DateRule(
        fieldName,
        minDate: minDate,
        maxDate: maxDate,
        allowFuture: allowFuture,
        allowPast: allowPast,
      ),
    ];
  }

  /// Creates a numeric range validation
  static List<ValidationRule> numericRange(
    String fieldName, {
    bool required = true,
    num? minValue,
    num? maxValue,
    bool inclusive = true,
  }) {
    return [
      if (required) RequiredRule(fieldName),
      RangeRule(
        fieldName,
        minValue: minValue,
        maxValue: maxValue,
        inclusive: inclusive,
      ),
    ];
  }

  /// Creates a dropdown/selection validation
  static List<ValidationRule> selection(
    String fieldName,
    List<String> validOptions, {
    bool required = true,
  }) {
    return [
      if (required) RequiredRule(fieldName),
      CustomRule(
        fieldName,
        (value) {
          if (value == null || (value is String && value.isEmpty)) {
            return null; // Let RequiredRule handle empty values
          }

          final stringValue = value.toString();
          if (!validOptions.contains(stringValue)) {
            return '$fieldName must be one of: ${validOptions.join(', ')}';
          }

          return null;
        },
        'validation.selection',
        'Must be one of: ${validOptions.join(', ')}',
      ),
    ];
  }
}
