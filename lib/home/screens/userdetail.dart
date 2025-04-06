import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/confirmordr.dart'; // Import the next page

class UserDetailsPage extends StatefulWidget {
  final String orderTitle;
  final double orderPrice;
  final String orderDetails;

  const UserDetailsPage({
    super.key,
    required this.orderTitle,
    required this.orderPrice,
    required this.orderDetails,
  });

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController =
      TextEditingController();

  void _navigateToNextPage() {
    String name = _nameController.text;
    String location = _locationController.text;
    String phone = _phoneController.text;
    String alternatePhone = _alternatePhoneController.text;

    if (name.isEmpty || location.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to the Order Summary Page with user details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          orderTitle: widget.orderTitle,
          orderPrice: widget.orderPrice,
          orderDetails: widget.orderDetails,
          userName: name,
          userLocation: location,
          userPhone: phone,
          alternatePhone: alternatePhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Enter Your Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Information",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // User Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                hintText: "Enter your name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),

            // Location Input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Location",
                hintText: "Enter your address",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 20),

            // Phone Number Input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                hintText: "Enter your primary phone number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.phone, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),

            // Alternate Phone Number Input (Optional)
            TextField(
              controller: _alternatePhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Alternate Phone Number (Optional)",
                hintText: "Enter an alternate phone number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.phone_android, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 30),

            // Next Button
            Center(
              child: ElevatedButton(
                onPressed: _navigateToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
