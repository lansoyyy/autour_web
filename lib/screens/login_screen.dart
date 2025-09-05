import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const Map<String, String> _accounts = {
    'admin': 'autour_admin',
    'super_admin': 'autour_super',
  };

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
      // Check hardcoded credentials first
      String enteredUsername = emailController.text.trim();
      String enteredPassword = passwordController.text.trim();

      String? accountType;
      if (enteredUsername == 'admin' && enteredPassword == _accounts['admin']) {
        accountType = 'Admin';
      } else if (enteredUsername == 'super_admin' &&
          enteredPassword == _accounts['super_admin']) {
        accountType = 'Super Admin';
      }

      if (accountType != null) {
        // Login successful for hardcoded accounts
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(accountType: accountType!),
          ),
        );
      } else {
        // Check admin users in Firestore
        await _checkAdminUser(enteredUsername, enteredPassword);
      }
    }
  }

  Future<void> _checkAdminUser(String username, String password) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .where('status', isEqualTo: 'Active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final adminDoc = querySnapshot.docs.first;
        final adminData = adminDoc.data();
        final role = adminData['role'] ?? 'Admin';

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(accountType: role),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showToast('Invalid username or password. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showToast('Error during login. Please try again.');
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
                  FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('config')
                          .doc('asset')
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        }

                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return Text("Document does not exist");
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(data['logo']),
                                fit: BoxFit.cover,
                              ),
                            ));
                      }),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
