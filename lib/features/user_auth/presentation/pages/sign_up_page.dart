import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carnation/core/theme/carnation_theme.dart';
import 'package:carnation/features/user_auth/data/profile_repository.dart';
import 'package:carnation/features/user_auth/domain/auth_validators.dart';
import 'package:carnation/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:carnation/features/user_auth/presentation/pages/login_page.dart';
import 'package:carnation/features/user_auth/presentation/widgets/auth_brand_header.dart';
import 'package:carnation/features/user_auth/presentation/widgets/auth_page_shell.dart';
import 'package:carnation/features/user_auth/presentation/widgets/auth_primary_button.dart';
import 'package:carnation/features/user_auth/presentation/widgets/form_container_widget.dart';

class SignUpPage extends StatefulWidget {
  final FirebaseAuthService? authService;
  final ProfileRepository? profileRepository;

  const SignUpPage({super.key, this.authService, this.profileRepository});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final FirebaseAuthService _auth;
  late final ProfileRepository _profileRepository;

  bool _isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? const FirebaseAuthService();
    _profileRepository = widget.profileRepository ?? const ProfileRepository();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return AuthPageShell(
      topAction: canGoBack
          ? IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader(
              title: 'Create your account',
              supportingText: 'Enter your details to get started',
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormContainerWidget(
                    controller: _usernameController,
                    labelText: 'Username',
                    hintText: 'Your display name',
                    prefixIcon: Icons.person_outline_rounded,
                    isPasswordField: false,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    textCapitalization: TextCapitalization.words,
                    validator: AuthValidators.username,
                    enabled: !_isSigningUp,
                  ),
                  const SizedBox(height: 14),
                  FormContainerWidget(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icons.email_outlined,
                    isPasswordField: false,
                    inputType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: AuthValidators.email,
                    enabled: !_isSigningUp,
                  ),
                  const SizedBox(height: 14),
                  FormContainerWidget(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'At least 6 characters',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPasswordField: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: AuthValidators.password,
                    enabled: !_isSigningUp,
                    onFieldSubmitted: (_) => _signUp(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Create account',
                    loadingLabel: 'Creating account...',
                    icon: Icons.person_add_alt_1_rounded,
                    isLoading: _isSigningUp,
                    onPressed: _signUp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: CarNationColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: _isSigningUp ? null : _openLogin,
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_isSigningUp || _formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    var authUserWasCreated = false;

    try {
      final user = await _auth.signUpWithEmailAndPassword(email, password);
      authUserWasCreated = true;
      await _auth.updateDisplayName(username);
      await _profileRepository.saveUserProfile(
        uid: user.uid,
        username: username,
        email: user.email ?? email,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      if (authUserWasCreated) {
        _showPartialSetupError(error.code);
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      _showError(error.message);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showPartialProfileError(error.code);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  void _openLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPartialSetupError(String code) {
    _showProfileSyncMessage(
      message:
          'Account created, but profile setup is temporarily unavailable. Your email account details will be used instead.',
      code: code,
    );
  }

  void _showPartialProfileError(String code) {
    _showProfileSyncMessage(
      message:
          'Account created, but profile sync is currently unavailable. Your username and email will be used instead.',
      code: code,
    );
  }

  void _showProfileSyncMessage({
    required String message,
    required String code,
  }) {
    final sanitizedCode = code.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: CarNationColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            if (sanitizedCode.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'Technical code: $sanitizedCode',
                style: const TextStyle(
                  color: CarNationColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
