import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/paymentmethod.dart'; // Import payment method page

class PaymentPage extends StatelessWidget {
  final String orderTitle;
  final double orderPrice;
  final String orderDetails;
  final String userName; // Updated to match the previous page
  final String userLocation;
  final String userPhone;
  final String alternatePhone;

  const PaymentPage({
    super.key,
    required this.orderTitle,
    required this.orderPrice,
    required this.orderDetails,
    required this.userName,
    required this.userLocation,
    required this.userPhone,
    required this.alternatePhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.fastfood, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(orderTitle,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(orderDetails,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 10),
                        Text("PKR ${orderPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Delivery Details",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(userName,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(userLocation,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(userPhone,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black)),
                      ],
                    ),
                    if (alternatePhone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_android, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(alternatePhone,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentMethodsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text(
                "Proceed to Payment",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel Order",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
