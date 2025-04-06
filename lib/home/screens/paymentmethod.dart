import 'package:flutter/material.dart';
import 'paymentonline.dart'; // Import the PaymentDetailsPage
import 'paymentsuccess.dart'; // Import the PaymentSuccessPage

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

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
        onTap: () {
          if (isOnlinePayment) {
            // Navigate to the Payment Details Page for JazzCash/Easypaisa
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PaymentDetailsPage()),
            );
          } else {
            // Navigate to the Payment Success Page for Cash on Delivery
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPage(
                  paymentService: "Cash on Delivery",
                  accountNumber: "N/A", // No account number needed for COD
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
