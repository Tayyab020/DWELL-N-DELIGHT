import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help and Support'),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Help and Support!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'If you need assistance, please refer to the following options:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Contact Support'),
              onTap: () {
                // Add your contact support functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contacting Support...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('FAQs'),
              onTap: () {
                // Add FAQ navigation here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening FAQs...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Report an Issue'),
              onTap: () {
                // Add issue reporting functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reporting an Issue...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
