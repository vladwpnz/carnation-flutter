class AuthValidators {
  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static String? username(String? value) {
    final username = value?.trim() ?? '';

    if (username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3 || username.length > 30) {
      return 'Username must be 3-30 characters';
    }

    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
}
