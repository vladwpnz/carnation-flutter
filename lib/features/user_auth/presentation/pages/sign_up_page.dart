import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motor_show/features/user_auth/data/profile_repository.dart';
import 'package:motor_show/features/user_auth/domain/auth_validators.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:motor_show/features/user_auth/presentation/pages/login_page.dart';
import 'package:motor_show/features/user_auth/presentation/widgets/form_container_widget.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white70],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/company_logo.png',
                      width: 200,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FormContainerWidget(
                        controller: _usernameController,
                        hintText: "Username",
                        isPasswordField: false,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.username,
                        enabled: !_isSigningUp,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FormContainerWidget(
                        controller: _emailController,
                        hintText: "Email",
                        isPasswordField: false,
                        inputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.email,
                        enabled: !_isSigningUp,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FormContainerWidget(
                        controller: _passwordController,
                        hintText: "Password",
                        isPasswordField: true,
                        textInputAction: TextInputAction.done,
                        validator: AuthValidators.password,
                        enabled: !_isSigningUp,
                        onFieldSubmitted: (_) => _signUp(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isSigningUp ? null : _signUp,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: _isSigningUp
                              ? const CircularProgressIndicator(
                                  color: Colors.blue,
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: _isSigningUp
                              ? null
                              : () {
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
                                },
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPartialSetupError(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created, but profile setup could not be completed. '
          'You are signed in with your email fallback. '
          'Setup error: $code.',
        ),
      ),
    );
  }

  void _showPartialProfileError(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created, but profile data could not be saved. '
          'You are signed in with your username and email fallback. '
          'Profile sync error: $code.',
        ),
      ),
    );
  }
}
