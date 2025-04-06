import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller; // Define the controller here
  final String label;
  final IconData icon;
  final TextInputType textInputType;
  final bool isPassword;
  final String? Function(String?)? validator; // Validator function

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.textInputType,
    this.isPassword = false, // Default to false if no value is provided
    this.validator, // Optionally pass a validator function
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // Manage password visibility toggle

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      // Pass the controller to the TextFormField
      keyboardType: widget.textInputType,
      obscureText: widget.isPassword && _obscureText,
      // Toggle password visibility
      validator: widget.validator ?? _defaultValidator,
      // Use the provided validator, or a default one
      style: const TextStyle(
        // Set the input text style
        color: Colors.black, // Change the text color to white
        fontSize: 16, // Adjust font size if needed
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: Colors.orange.shade900),
        // Set the icon color
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.orange.shade900, // Set the icon color
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color.fromARGB(64, 255, 165, 0),
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 182, 180, 180),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Default validator logic for all fields
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ${widget.label.toLowerCase()}';
    }
    if (widget.isPassword && value.length < 9) {
      return 'Password must be at least 9 characters';
    }
    return null;
  }
}
