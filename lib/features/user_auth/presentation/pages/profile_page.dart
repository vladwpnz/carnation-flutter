import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motor_show/features/user_auth/data/profile_repository.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseAuthService? authService;
  final ProfileRepository? profileRepository;

  const ProfilePage({super.key, this.authService, this.profileRepository});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FirebaseAuthService _auth;
  late final ProfileRepository _profileRepository;
  late final Future<_ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? const FirebaseAuthService();
    _profileRepository = widget.profileRepository ?? const ProfileRepository();
    _profileFuture = _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: FutureBuilder<_ProfileViewData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_picture.jpg'),
                ),
                const SizedBox(height: 20),
                if (isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                ] else ...[
                  Text(
                    data?.username ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data?.email ?? 'No email available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (data?.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        data!.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: _signOut,
                  child: const Text("Sign out"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Back to Home"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_ProfileViewData> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return const _ProfileViewData(
        username: 'User',
        email: 'No email available',
        errorMessage: 'No signed-in user is available.',
      );
    }

    final fallbackUsername = _trimOrEmpty(user.displayName);
    final fallbackEmail = _trimOrEmpty(user.email);

    try {
      final profile = await _profileRepository.loadUserProfile(user.uid);

      return _ProfileViewData(
        username: _firstNonEmpty([
          profile?.username,
          fallbackUsername,
          'User',
        ]),
        email: _firstNonEmpty([
          profile?.email,
          fallbackEmail,
          'No email available',
        ]),
      );
    } on FirebaseException catch (error) {
      return _ProfileViewData(
        username: _firstNonEmpty([fallbackUsername, 'User']),
        email: _firstNonEmpty([fallbackEmail, 'No email available']),
        errorMessage:
            'Could not load profile data. Using account fallback. Error code: ${error.code}.',
      );
    } catch (_) {
      return _ProfileViewData(
        username: _firstNonEmpty([fallbackUsername, 'User']),
        email: _firstNonEmpty([fallbackEmail, 'No email available']),
        errorMessage: 'Could not load profile data. Using account fallback.',
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  String _trimOrEmpty(String? value) => value?.trim() ?? '';

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return 'User';
  }
}

class _ProfileViewData {
  final String username;
  final String email;
  final String? errorMessage;

  const _ProfileViewData({
    required this.username,
    required this.email,
    this.errorMessage,
  });
}
