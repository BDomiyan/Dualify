/// Base interface for validation rules
/// Follows Strategy Pattern for flexible validation logic
abstract class ValidationRule {
  /// Validates the given value and returns error message if invalid
  /// Returns null if validation passes
  String? validate(dynamic value);

  /// Returns the error message key for localization
  String get errorKey;

  /// Returns a description of the validation rule
  String get description;
}

/// Validation result containing error information
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorKey;

  const ValidationResult.valid()
    : isValid = true,
      errorMessage = null,
      errorKey = null;

  const ValidationResult.invalid(this.errorMessage, this.errorKey)
    : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

/// Required field validation rule
class RequiredRule implements ValidationRule {
  final String fieldName;

  const RequiredRule(this.fieldName);

  @override
  String? validate(dynamic value) {
    if (value == null) {
      return '$fieldName is required';
    }

    if (value is String && value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value is List && value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  @override
  String get errorKey => 'validation.required';

  @override
  String get description => 'Field must not be empty';
}

/// String length validation rule
class LengthRule implements ValidationRule {
  final String fieldName;
  final int? minLength;
  final int? maxLength;

  const LengthRule(this.fieldName, {this.minLength, this.maxLength})
    : assert(
        minLength != null || maxLength != null,
        'At least one of minLength or maxLength must be provided',
      );

  @override
  String? validate(dynamic value) {
    if (value == null) return null; // Let RequiredRule handle null values

    final String stringValue = value.toString();
    final int length = stringValue.length;

    if (minLength != null && length < minLength!) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (maxLength != null && length > maxLength!) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  @override
  String get errorKey => 'validation.length';

  @override
  String get description =>
      'Length must be ${minLength != null ? 'at least $minLength' : ''}'
      '${minLength != null && maxLength != null ? ' and ' : ''}'
      '${maxLength != null ? 'at most $maxLength' : ''} characters';
}

/// Email format validation rule
class EmailRule implements ValidationRule {
  final String fieldName;

  // RFC 5322 compliant email regex (simplified)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  const EmailRule(this.fieldName);

  @override
  String? validate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return null; // Let RequiredRule handle empty values
    }

    final String email = value.toString().trim();

    if (!_emailRegex.hasMatch(email)) {
      return '$fieldName must be a valid email address';
    }

    return null;
  }

  @override
  String get errorKey => 'validation.email';

  @override
  String get description => 'Must be a valid email address';
}

/// Date validation rule
class DateRule implements ValidationRule {
  final String fieldName;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool allowFuture;
  final bool allowPast;

  const DateRule(
    this.fieldName, {
    this.minDate,
    this.maxDate,
    this.allowFuture = true,
    this.allowPast = true,
  });

  @override
  String? validate(dynamic value) {
    if (value == null) return null; // Let RequiredRule handle null values

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      try {
        date = DateTime.parse(value);
      } catch (e) {
        return '$fieldName must be a valid date';
      }
    } else {
      return '$fieldName must be a valid date';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (!allowFuture && dateOnly.isAfter(today)) {
      return '$fieldName cannot be in the future';
    }

    if (!allowPast && dateOnly.isBefore(today)) {
      return '$fieldName cannot be in the past';
    }

    if (minDate != null && date.isBefore(minDate!)) {
      return '$fieldName must be after ${_formatDate(minDate!)}';
    }

    if (maxDate != null && date.isAfter(maxDate!)) {
      return '$fieldName must be before ${_formatDate(maxDate!)}';
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  String get errorKey => 'validation.date';

  @override
  String get description =>
      'Must be a valid date'
      '${!allowFuture ? ' (not in future)' : ''}'
      '${!allowPast ? ' (not in past)' : ''}';
}

/// Numeric range validation rule
class RangeRule implements ValidationRule {
  final String fieldName;
  final num? minValue;
  final num? maxValue;
  final bool inclusive;

  const RangeRule(
    this.fieldName, {
    this.minValue,
    this.maxValue,
    this.inclusive = true,
  }) : assert(
         minValue != null || maxValue != null,
         'At least one of minValue or maxValue must be provided',
       );

  @override
  String? validate(dynamic value) {
    if (value == null) return null; // Let RequiredRule handle null values

    num? numValue;

    if (value is num) {
      numValue = value;
    } else if (value is String) {
      numValue = num.tryParse(value);
      if (numValue == null) {
        return '$fieldName must be a valid number';
      }
    } else {
      return '$fieldName must be a valid number';
    }

    if (minValue != null) {
      if (inclusive && numValue < minValue!) {
        return '$fieldName must be at least $minValue';
      } else if (!inclusive && numValue <= minValue!) {
        return '$fieldName must be greater than $minValue';
      }
    }

    if (maxValue != null) {
      if (inclusive && numValue > maxValue!) {
        return '$fieldName must be at most $maxValue';
      } else if (!inclusive && numValue >= maxValue!) {
        return '$fieldName must be less than $maxValue';
      }
    }

    return null;
  }

  @override
  String get errorKey => 'validation.range';

  @override
  String get description =>
      'Must be ${minValue != null ? '${inclusive ? 'at least' : 'greater than'} $minValue' : ''}'
      '${minValue != null && maxValue != null ? ' and ' : ''}'
      '${maxValue != null ? '${inclusive ? 'at most' : 'less than'} $maxValue' : ''}';
}

/// Pattern matching validation rule
class PatternRule implements ValidationRule {
  final String fieldName;
  final RegExp pattern;
  final String patternDescription;

  const PatternRule(this.fieldName, this.pattern, this.patternDescription);

  @override
  String? validate(dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      return null; // Let RequiredRule handle empty values
    }

    final String stringValue = value.toString();

    if (!pattern.hasMatch(stringValue)) {
      return '$fieldName $patternDescription';
    }

    return null;
  }

  @override
  String get errorKey => 'validation.pattern';

  @override
  String get description => patternDescription;
}

/// Custom validation rule with user-defined logic
class CustomRule implements ValidationRule {
  final String fieldName;
  final String? Function(dynamic value) validator;
  final String _errorKey;
  final String _description;

  const CustomRule(
    this.fieldName,
    this.validator,
    this._errorKey,
    this._description,
  );

  @override
  String? validate(dynamic value) => validator(value);

  @override
  String get errorKey => _errorKey;

  @override
  String get description => _description;
}

/// Conditional validation rule that applies another rule based on a condition
class ConditionalRule implements ValidationRule {
  final ValidationRule rule;
  final bool Function(Map<String, dynamic> formData) condition;

  const ConditionalRule(this.rule, this.condition);

  @override
  String? validate(dynamic value) {
    // Note: This requires access to form data, which should be provided by FormValidator
    // For now, we'll always apply the rule
    return rule.validate(value);
  }

  @override
  String get errorKey => rule.errorKey;

  @override
  String get description => 'Conditional: ${rule.description}';
}
