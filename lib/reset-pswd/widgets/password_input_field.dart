import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final String label;
  final bool isNewPassword;

  const PasswordInputField({
    super.key,
    required this.label,
    required this.isNewPassword,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //padding: const EdgeInsets.only(top: -10),
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0x40FFA500),
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: Color(0xFFDADADA),
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.orange.shade900,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 9) {
          return 'Password must be at least 9 characters';
        }
        return null;
      },
      style: const TextStyle(
        color: Colors.black, // Set input text color to white
        fontSize: 16, // Optional: Adjust the font size if needed
      ),
    );
  }
}
