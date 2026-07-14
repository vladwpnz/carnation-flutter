import 'package:flutter/material.dart';
import 'package:motor_show/features/user_auth/domain/auth_validators.dart';
import 'package:motor_show/features/user_auth/firebase_auth_implementation/firebase_auth_service.dart';
import 'package:motor_show/features/user_auth/presentation/pages/sign_up_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                      "Login",
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
                        controller: _emailController,
                        hintText: "Email",
                        isPasswordField: false,
                        inputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: AuthValidators.email,
                        enabled: !_isSigning,
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
                        enabled: !_isSigning,
                        onFieldSubmitted: (_) => _signIn(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isSigning ? null : _signIn,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: _isSigning
                              ? const CircularProgressIndicator(
                                  color: Colors.blue,
                                )
                              : const Text(
                                  "Login",
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
                        const Text("Don't have an account?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: _isSigning
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                },
                          child: const Text(
                            "Sign Up",
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
