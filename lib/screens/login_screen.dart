import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/widgets/textfield_widget.dart';
import 'package:autour_web/widgets/toast_widget.dart';
import 'package:autour_web/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;

  // Hardcoded credentials
  static const String _hardcodedUsername = 'autour_admin';
  static const String _hardcodedPassword = 'autour_admin';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Check hardcoded credentials
      String enteredUsername = emailController.text.trim();
      String enteredPassword = passwordController.text.trim();

      if (enteredUsername == _hardcodedUsername &&
          enteredPassword == _hardcodedPassword) {
        // Login successful
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Login failed
        setState(() {
          _isLoading = false;
        });
        showToast('Invalid username or password. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo or Title
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: TextWidget(
                        text: 'AuTour',
                        fontSize: 32,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextWidget(
                    text: 'Admin Login',
                    fontSize: 28,
                    color: primary,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Sign in to manage AuTour',
                    fontSize: 16,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 32),
                  // Username Field
                  TextFieldWidget(
                    label: 'Username',
                    hint: 'Enter your username',
                    controller: emailController,
                    inputType: TextInputType.text,
                    borderColor: primary,
                    hintColor: grey,
                    width: 350,
                    height: 60,
                    radius: 12,
                    hasValidator: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFieldWidget(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: passwordController,
                    isObscure: _isObscure,
                    showEye: true,
                    borderColor: primary,
                    hintColor: grey,
                    width: 350,
                    height: 60,
                    radius: 12,
                    hasValidator: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ButtonWidget(
                    label: _isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: _isLoading ? () {} : _handleLogin,
                    color: primary,
                    textColor: white,
                    width: 350,
                    height: 55,
                    fontSize: 18,
                    radius: 12,
                  ),
                  const SizedBox(height: 24),
                  // Optionally, add a 'Forgot password?' or other admin links here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
