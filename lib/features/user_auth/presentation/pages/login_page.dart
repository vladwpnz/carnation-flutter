import 'package:flutter/material.dart';
import 'package:motor_show/core/theme/carnation_theme.dart';
import 'package:motor_show/features/user_auth/domain/auth_validators.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:motor_show/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:motor_show/features/user_auth/presentation/widgets/auth_brand_header.dart';
import 'package:motor_show/features/user_auth/presentation/widgets/auth_page_shell.dart';
import 'package:motor_show/features/user_auth/presentation/widgets/auth_primary_button.dart';
import 'package:motor_show/features/user_auth/presentation/widgets/form_container_widget.dart';

class LoginPage extends StatefulWidget {
  final FirebaseAuthService? authService;

  const LoginPage({super.key, this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final FirebaseAuthService _auth;
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? const FirebaseAuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader(
              title: 'Welcome back',
              supportingText: 'Sign in to your account',
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    enabled: !_isSigning,
                  ),
                  const SizedBox(height: 16),
                  FormContainerWidget(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPasswordField: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: AuthValidators.password,
                    enabled: !_isSigning,
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Login',
                    loadingLabel: 'Signing in...',
                    icon: Icons.login_rounded,
                    isLoading: _isSigning,
                    onPressed: _signIn,
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
                  "Don't have an account?",
                  style: TextStyle(
                    color: CarNationColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: _isSigning ? null : _openSignUp,
                  child: const Text(
                    'Sign Up',
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

  Future<void> _signIn() async {
    if (_isSigning || _formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSigning = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await _auth.signInWithEmailAndPassword(email, password);
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthServiceException catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  void _openSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpPage(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}