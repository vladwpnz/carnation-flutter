import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carnation/core/navigation/carnation_route.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/requests/data/vehicle_request_repository.dart';
import 'package:carnation/features/requests/presentation/pages/my_requests_page.dart';
import 'package:carnation/features/user_auth/data/profile_repository.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseAuthService? authService;
  final ProfileRepository? profileRepository;
  final VehicleRequestRepository? requestRepository;

  const ProfilePage({
    super.key,
    this.authService,
    this.profileRepository,
    this.requestRepository,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FirebaseAuthService _auth;
  late final ProfileRepository _profileRepository;
  late final VehicleRequestRepository _requestRepository;
  late final Future<_ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? const FirebaseAuthService();
    _profileRepository = widget.profileRepository ?? const ProfileRepository();
    _requestRepository =
        widget.requestRepository ?? const FirestoreVehicleRequestRepository();
    _profileFuture = _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: CarNationTheme.dark,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
          top: false,
          child: FutureBuilder<_ProfileViewData>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final data = snapshot.data;
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileHeader(data, isLoading),
                          const SizedBox(height: 24),
                          const Text(
                            'Account',
                            style: TextStyle(
                              color: CarNationColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAccountSection(data, isLoading),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            key: const Key('profile-my-requests'),
                            onPressed: _openMyRequests,
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('My requests'),
                          ),
                          if (data?.showSyncWarning == true) ...[
                            const SizedBox(height: 14),
                            _buildSyncWarning(data!.warningCode),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _backToHome,
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Back to Home'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _signOut,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CarNationColors.danger,
                              side: const BorderSide(
                                color: CarNationColors.danger,
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Sign out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(_ProfileViewData? data, bool isLoading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: CarNationColors.accent,
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            radius: 52,
            backgroundImage: AssetImage('assets/profile_picture.jpg'),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isLoading ? 'Loading profile' : data?.username ?? 'User',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CarNationColors.textPrimary,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          isLoading ? 'Please wait' : data?.email ?? 'No email available',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CarNationColors.textSecondary,
            fontSize: 15,
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSection(_ProfileViewData? data, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CarNationColors.surface,
        borderRadius: BorderRadius.circular(CarNationRadii.page),
        border: Border.all(color: CarNationColors.border),
      ),
      child: Column(
        children: [
          _AccountRow(
            icon: Icons.person_outline_rounded,
            label: 'Username',
            value: isLoading ? 'Loading...' : data?.username ?? 'User',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _AccountRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value:
                isLoading ? 'Loading...' : data?.email ?? 'No email available',
          ),
        ],
      ),
    );
  }

  Widget _buildSyncWarning(String? warningCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CarNationColors.warningSurface,
        borderRadius: BorderRadius.circular(CarNationRadii.card),
        border: Border.all(color: const Color(0xFF66521D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.sync_problem_rounded,
            color: CarNationColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile sync is currently unavailable. Account details are shown instead.',
                  style: TextStyle(
                    color: CarNationColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                if (warningCode != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Technical code: $warningCode',
                    style: const TextStyle(
                      color: CarNationColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<_ProfileViewData> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return const _ProfileViewData(
        username: 'User',
        email: 'No email available',
        showSyncWarning: true,
        warningCode: 'no-current-user',
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
        showSyncWarning: true,
        warningCode: _sanitizeErrorCode(error.code),
      );
    } catch (_) {
      return _ProfileViewData(
        username: _firstNonEmpty([fallbackUsername, 'User']),
        email: _firstNonEmpty([fallbackEmail, 'No email available']),
        showSyncWarning: true,
      );
    }
  }

  void _openMyRequests() {
    Navigator.of(context).push(
      carNationRoute<void>(
        builder: (_) => MyRequestsPage(
          requestRepository: _requestRepository,
        ),
      ),
    );
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

  void _backToHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
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

  String? _sanitizeErrorCode(String code) {
    final sanitized = code.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return sanitized.isEmpty ? null : sanitized;
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: CarNationColors.accentSoft, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: CarNationColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: CarNationColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileViewData {
  final String username;
  final String email;
  final bool showSyncWarning;
  final String? warningCode;

  const _ProfileViewData({
    required this.username,
    required this.email,
    this.showSyncWarning = false,
    this.warningCode,
  });
}
