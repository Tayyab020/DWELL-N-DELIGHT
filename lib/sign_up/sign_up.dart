import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_appp123/Otp/otp_creen.dart';
import 'package:flutter_appp123/home/screens/home_page.dart';
import 'package:flutter_appp123/signIn/sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_sign_up_button.dart';
import 'widgets/terms_checkbox.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _agreedToTerms = false;
  bool _isLoading = false;
  String _selectedRole = 'buyer'; // default role
  final List<String> _roles = ['buyer', 'provider'];

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _registerUser() async {
    if (!_agreedToTerms) {
      _showErrorDialog('You must agree to the terms and conditions.');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await AuthService().signUpUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          role: _selectedRole,
        );

        if (response['success'] == true) {
          Fluttertoast.showToast(
            msg: response['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: response['error'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 81, 0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          size: 30, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.85,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline,
                              textInputType: TextInputType.name,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              textInputType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _mobileController,
                              label: 'Mobile Number',
                              icon: Icons.phone_outlined,
                              textInputType: TextInputType.phone,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your mobile number'
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              textInputType: TextInputType
                                  .text, // ✅ This line fixes the issue
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                } else if (value.length < 9) {
                                  return 'Password must be at least 9 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  border: InputBorder.none,
                                  icon: Icon(Icons.person_outline),
                                ),
                                items: _roles.map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role[0].toUpperCase() +
                                        role.substring(1)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please select a role'
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TermsCheckbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE65100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DefaultTextStyle(
                              style: const TextStyle(color: Color(0xFFE65100)),
                              child: DividerWithText(text: 'Or Sign in with'),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SocialSignUpButton(
                                    icon: 'assets/icons/google.png',
                                    onTap: () {}),
                                SocialSignUpButton(
                                    icon: 'assets/icons/facebook.png',
                                    onTap: () {}),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign in',
                                      style: const TextStyle(
                                        color: Color(0xFFE65100),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignIn(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
