import 'package:flutter/material.dart';
import 'package:flutter_appp123/verify-firgotPassOtp/verify_otp.dart';
import 'package:flutter_appp123/utils/api_service.dart';

class ForgetPswd extends StatefulWidget {
  const ForgetPswd({super.key});

  @override
  State<ForgetPswd> createState() => _ForgetPswdState();
}

class _ForgetPswdState extends State<ForgetPswd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await ApiService.requestOtp(_emailController.text);

        if (response['success'] == true) {
          Toast.showSuccess(context, response['message']);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerifyOtpScreen(email: _emailController.text),
            ),
          );
        } else {
          Toast.showError(context, response['message'] ?? 'Failed to send OTP');
        }
      } catch (e) {
        Toast.showError(context, 'An error occurred: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 140),
                  const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Don\'t worry! It happens. Please enter the address associated with your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 44,
              left: 26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFFE65100),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
