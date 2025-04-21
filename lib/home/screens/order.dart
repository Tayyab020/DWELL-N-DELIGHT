import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/userdetail.dart'; // Import UserDetailsPage

class OrderPage extends StatefulWidget {
  final String title;
  final double price;
  final String imageUrl;
  final String itemId;

  const OrderPage({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.itemId,
  });

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String customOrderDetails = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Customize Your Order",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Base Price: PKR ${widget.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 30),

            // Custom Order Input
            const Text("Enter Order Details:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  customOrderDetails = value;
                });
              },
              decoration: const InputDecoration(
                hintText:
                    "Describe your order (e.g., No onions, extra cheese)...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // Confirm Order Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsPage(
                        itemId: widget.itemId,
                        orderTitle: widget.title,
                        orderPrice: widget.price,
                        orderDetails: customOrderDetails.isEmpty
                            ? "No special instructions"
                            : customOrderDetails,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
