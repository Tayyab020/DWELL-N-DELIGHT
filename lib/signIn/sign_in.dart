import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_appp123/home/home_screen.dart';
import 'package:flutter_appp123/forget-pswd/forget_pswd.dart';
import 'package:flutter_appp123/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For showing toast messages
import 'package:http/http.dart' as http; // Import HTTP package
import 'package:url_launcher/url_launcher.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_sign_in_button.dart';
import 'widgets/sign_in_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();

  // Create controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    
    if (_formKey.currentState?.validate() ?? false) {
     
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      AuthService authService = AuthService();

      var response = await authService.loginUser(
        email: email,
        password: password,
      );

      if (response != null && !response.containsKey('error')) {
        //final prefs = await SharedPreferences.getInstance();

        // Save token and userId
        // await prefs.setString('token', response['token']);
        // await prefs.setString('userId', response['userId']);

        Fluttertoast.showToast(
          msg: "login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        String errorMsg = response?['error'] ?? "login failed!";
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }



  // Function to handle user login
  // Future<void> _loginUser() async {
  //   String email = _emailController.text.trim();
  //   String password = _passwordController.text.trim();

  //   Map<String, String> data = {
  //     'email': email,
  //     'password': password,
  //   };

  //   try {
  //     String backendUrl = dotenv.env['BACKEND_URL']!;

  //     final response = await http.post(
  //       Uri.parse('$backendUrl/login'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(data),
  //     );

  //     if (response.statusCode == 200) {
  //       print('response after signin: ${response.body}');
        
  //       //   void _showAdminRedirect() async {
  //       //   // Show a message that the admin panel is only available on the web
  //       //   showDialog(
  //       //     context: context,
  //       //     builder: (BuildContext context) {
  //       //       return AlertDialog(
  //       //         title: const Text("Admin Panel"),
  //       //         content: const Text(
  //       //             "The Admin Panel is only available on the web. Please visit the web app."),
  //       //         actions: [
  //       //           TextButton(
  //       //             onPressed: () async {
  //       //               Navigator.pop(context); // Close the dialog
  //       //               // Redirect to the web app
  //       //               const url =
  //       //                   'https://your-web-app-url.com'; // Replace with your web app's URL
  //       //               if (await canLaunch(url)) {
  //       //                 await launch(url); // Launch the URL
  //       //               } else {
  //       //                 throw 'Could not launch $url'; // If URL can't be opened
  //       //               }
  //       //             },
  //       //             child: const Text("OK"),
  //       //           ),
  //       //         ],
  //       //       );
  //       //     },
  //       //   );
  //       // }


          

  //       //       // Conditionally show pages based on role
  //       //       if (role == 'admin') {
  //       //         _showAdminRedirect(); // Show the redirect alert for admins
  //       //         _pages = []; // Empty or loading page until admin redirects
  //       //         _tabItems = [];
  //       //       } 
              
      
  //       // Save cookies
  //       final rawCookie = response.headers['set-cookie'];
  //       if (rawCookie != null) {
  //         final cookies = rawCookie.split(';');
  //         final sessionToken = cookies[0]; // Just the token

  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('token', sessionToken);
  //         print('Saved token: $sessionToken');
  //       }

     
  //       // Show success snackbar
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Login Successful!'),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );

  //       // Navigate to HomeScreen
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     } else {
  //       var errorResponse = json.decode(response.body);
  //       String errorMessage = errorResponse['message'] ??
  //           'Failed to login. Please try again later.';
  //       print(errorMessage);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(errorMessage),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     // Handle connection or general errors
  //     print('error: $e');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.orange,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 81, 0),
      body: SafeArea(
        child: Stack(
          children: [
            /// Background Design
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 20.0, left: 10.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 90),

                    /// Sign In Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgetPswd(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFFE65100),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SignInButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _loginUser();
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const HomeScreen(),
                                  //   ),
                                  // );
                                }
                              },
                            ),
                            const SizedBox(height: 26),
                            const DividerWithText(
                              text: 'Or Sign in with',
                              textStyle: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w800,
                              ), // Set your preferred color
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            const SizedBox(height: 18),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800),
                                    ),
                                    TextSpan(
                                      text: 'Sign up',
                                      style: const TextStyle(
                                        color: Color(0xFFE65100),
                                        fontWeight: FontWeight.w800,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
