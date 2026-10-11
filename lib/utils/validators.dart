/// Small, pure form-validation helpers. Kept free of Flutter imports so they
/// are trivial to unit test.
class Validators {
  Validators._();

  static final RegExp _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns an error message, or null if [value] is a valid email.
  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  /// Returns an error message, or null if [value] is an acceptable password.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Returns an error message, or null if [confirm] matches [password].
  static String? confirmPassword(String? confirm, String password) {
    if ((confirm ?? '').isEmpty) return 'Please confirm your password';
    if (confirm != password) return 'Passwords do not match';
    return null;
  }

  /// Generic "required" validator for names/labels.
  static String? required(String? value, {String field = 'This field'}) {
    if ((value ?? '').trim().isEmpty) return '$field is required';
    return null;
  }

  /// Optional field — never blocks submission, just here for symmetry/clarity.
  static String? optional(String? value) => null;
}
