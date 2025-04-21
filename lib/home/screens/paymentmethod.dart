import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'paymentonline.dart'; // Import the PaymentDetailsPage
import 'paymentsuccess.dart'; // Import the PaymentSuccessPage
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For making HTTP requests

class PaymentMethodsPage extends StatelessWidget {
  final String orderTitle;
  final double orderPrice;
  final String orderDetails;
  final String userName;
  final String userLocation;
  final String userPhone;
  final String alternatePhone;
  final String itemId;

  const PaymentMethodsPage({
    super.key,
    required this.orderTitle,
    required this.orderPrice,
    required this.orderDetails,
    required this.userName,
    required this.userLocation,
    required this.userPhone,
    required this.alternatePhone,
    required this.itemId,
  });


Future<void> createOrder(BuildContext context, String paymentMethod) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user'); // Adjust key if needed

    if (userString == null) {
      Fluttertoast.showToast(
        msg: "User not found. Please login again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final user = json.decode(userString);
    final userId = user['_id'];

    final orderData = {
      "orderTitle": orderTitle,
      "orderPrice": orderPrice,
      "description": orderDetails,
      "name": userName,
      "address": userLocation,
      "phone": userPhone,
      "alternativePhone": alternatePhone,
      "itemId": itemId,
      "paymentMethod": paymentMethod,
      "orderedBy": userId, // ✅ Add orderedBy
    };

    final backendUrl = dotenv.env['BACKEND_URL'];
    final url = Uri.parse('${backendUrl}/createOrder');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(orderData),
    );

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "Order placed successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            paymentService: "Cash on Delivery",
            accountNumber: "N/A",
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to place order. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("Error creating order: ${response.body}");
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: "Something went wrong. Check your connection.",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    print("Error: $error");
  }
}
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Payment Method",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPaymentMethod(context, Icons.account_balance_wallet,
                "JazzCash / Easypaisa", true),
            const SizedBox(height: 10),
            _buildPaymentMethod(
                context, Icons.money, "Cash on Delivery", false),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
      BuildContext context, IconData icon, String title, bool isOnlinePayment) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange.shade900, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        onTap: () async {
          if (isOnlinePayment) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentDetailsPage(
                    // pass necessary data if needed
                    ),
              ),
            );
          } else {
            // Pass context and payment method to createOrder
            await createOrder(context, "Cash on Delivery");
          }
        },
      ),
    );
  }
}
