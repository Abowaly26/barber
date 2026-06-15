class Validators {
  Validators._();

  /// Validates email address format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validates phone number format
  /// Supports various formats including international numbers
  /// Returns error message if invalid, null if valid
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it starts with + or country code
    if (digitsOnly.startsWith('+')) {
      // International format: +966xxxxxxxxx (10-15 digits after +)
      if (digitsOnly.length < 11 || digitsOnly.length > 16) {
        return 'Invalid phone number';
      }
    } else if (digitsOnly.startsWith('00')) {
      // Alternative international format: 00966xxxxxxxxx
      if (digitsOnly.length < 12 || digitsOnly.length > 17) {
        return 'Invalid phone number';
      }
    } else if (digitsOnly.startsWith('05')) {
      // Saudi local format: 05xxxxxxxx (10 digits)
      if (digitsOnly.length != 10) {
        return 'Phone number must be 10 digits';
      }
    } else if (digitsOnly.startsWith('5')) {
      // Saudi format without leading 0: 5xxxxxxxx (9 digits)
      if (digitsOnly.length != 9) {
        return 'Invalid phone number';
      }
    } else {
      return 'Invalid phone number';
    }

    return null;
  }

  /// Validates password strength
  /// Minimum 8 characters, at least one letter and one number
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates password confirmation
  /// Checks if password and confirmation match
  /// Returns error message if invalid, null if valid
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Password confirmation is required';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates required text field
  /// Returns error message if empty, null if valid
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates name field
  /// Minimum 2 characters, letters and spaces only
  /// Returns error message if invalid, null if valid
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Allow Arabic, English letters, and spaces
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(value)) {
      return 'Name must contain letters only';
    }

    return null;
  }

  /// Validates minimum length
  /// Returns error message if shorter than minimum, null if valid
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length
  /// Returns error message if longer than maximum, null if valid
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validates numeric input
  /// Returns error message if not numeric, null if valid
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }

    return null;
  }

  /// Validates OTP code
  /// Checks if code is 6 digits
  /// Returns error message if invalid, null if valid
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }

    if (value.length != 6) {
      return 'Verification code must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Verification code must contain numbers only';
    }

    return null;
  }

  /// Validates URL format
  /// Returns error message if invalid, null if valid
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty if not required
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Invalid URL';
    }

    return null;
  }

  /// Validates price/amount
  /// Checks if value is positive number
  /// Returns error message if invalid, null if valid
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Price must be a number';
    }

    if (price <= 0) {
      return 'Price must be greater than zero';
    }

    return null;
  }
}
