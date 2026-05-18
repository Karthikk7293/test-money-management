class Validators {
  Validators._();

  /// Indian mobile: exactly 10 digits, starting with 6-9.
  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Phone number is required';
    if (digits.length != 10) return 'Enter a 10-digit phone number';
    if (!RegExp(r'^[6-9]').hasMatch(digits)) {
      return 'Mobile numbers start with 6, 7, 8 or 9';
    }
    return null;
  }

  /// 6 numeric digits.
  static String? otp(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'OTP is required';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'Enter the 6-digit OTP';
    return null;
  }

  /// 2-24 chars; letters, digits, spaces, period, apostrophe, hyphen.
  static String? nickname(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Nickname is required';
    if (v.length < 2) return 'Nickname must be at least 2 characters';
    if (v.length > 24) return 'Nickname must be under 24 characters';
    if (!RegExp(r"^[A-Za-z0-9 .'\-]+$").hasMatch(v)) {
      return 'Use letters, numbers, spaces, . \' or -';
    }
    return null;
  }

  /// Transaction / category title: 1-50 chars.
  static String? title(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Title is required';
    if (v.length > 50) return 'Keep title under 50 characters';
    return null;
  }

  /// Optional note: max 120 chars, may be empty.
  static String? optionalNote(String? value) {
    final v = (value ?? '').trim();
    if (v.length > 120) return 'Note must be under 120 characters';
    return null;
  }

  /// Money amount: positive, up to ₹99,99,999.99.
  static String? amount(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Amount is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Amount must be greater than 0';
    if (n > 9999999.99) return 'Amount is too large';
    return null;
  }

  /// Category name: 1-30 chars; letters, digits, spaces, & / -.
  static String? categoryName(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Category name is required';
    if (v.length > 30) return 'Keep it under 30 characters';
    if (!RegExp(r'^[A-Za-z0-9 &/\-]+$').hasMatch(v)) {
      return 'Letters, numbers, spaces, & / - only';
    }
    return null;
  }

  /// Budget limit: same shape as amount.
  static String? budgetLimit(String? value) => amount(value);
}
