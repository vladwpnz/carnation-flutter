class UserProfile {
  final String uid;
  final String username;
  final String email;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
  });

  factory UserProfile.fromMap(
    Map<String, dynamic>? data, {
    String? fallbackUid,
    String? fallbackUsername,
    String? fallbackEmail,
  }) {
    final uid = _readString(data?['uid']) ?? fallbackUid ?? '';
    final username =
        _readString(data?['username']) ?? fallbackUsername?.trim() ?? '';
    final email = _readString(data?['email']) ?? fallbackEmail?.trim() ?? '';

    return UserProfile(
      uid: uid,
      username: username,
      email: email,
    );
  }

  static String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
