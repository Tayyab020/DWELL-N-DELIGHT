import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_appp123/home/screens/home_page.dart'; // Make sure this import is correct
import 'package:flutter_appp123/signIn/sign_in.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_sign_up_button.dart';
import 'widgets/terms_checkbox.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUp> {
  bool _agreedToTerms = false;

  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 81, 0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    /// Back Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        ),
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

                    /// Form Container
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width * 1,
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
                          key: _formKey, // Form key attached here
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              /// Input Fields
                              CustomTextField(
                                controller: _nameController,
                                label: 'Name',
                                icon: Icons.person_outline,
                                textInputType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                textInputType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                controller: _mobileController,
                                label: 'Mobile Number',
                                icon: Icons.phone_outlined,
                                textInputType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your mobile number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              CustomTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                textInputType: TextInputType.text,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 9) {
                                    return 'Password must be at least 9 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              /// Terms Checkbox
                              TermsCheckbox(
                                value: _agreedToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value ?? false;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),

                              /// Sign Up Button
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // If form is valid, navigate to HomePage
                                    print(
                                        "Form validated, navigating to HomePage");
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()),
                                    );
                                  } else {
                                    print("Form validation failed");
                                  }
                                },
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

                              /// Divider with Text
                              DefaultTextStyle(
                                style:
                                    const TextStyle(color: Color(0xFFE65100)),
                                child: DividerWithText(text: 'Or Sign in with'),
                              ),

                              const SizedBox(height: 12),

                              /// Social Media Sign Up buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SocialSignUpButton(
                                    icon: 'assets/icons/google.png',
                                    onTap: () {},
                                  ),
                                  SocialSignUpButton(
                                    icon: 'assets/icons/apple.png',
                                    onTap: () {},
                                  ),
                                  SocialSignUpButton(
                                    icon: 'assets/icons/facebook.png',
                                    onTap: () {},
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              /// Sign In Link
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
            ),
          ],
        ),
      ),
    );
  }
}
