import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_appp123/home/screens/helpandsupport.dart';
import 'package:flutter_appp123/home/screens/rateapp.dart';
import 'editprofile.dart';
import 'package:flutter_appp123/orderhistory.dart'; // Import your OrderHistoryPage here
import 'package:flutter_appp123/SettingsPage2.dart'; // Import your SettingsPage here
import 'package:flutter_appp123/signout.dart';

class ProfileScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;

  const ProfileScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "App Deve";
  String userContact = "+1234567890";
  String userEmail = "application12@gmail.com";
  String userLocation = "New York";

  final List<String> userPosts = [
    'assets/icons/house1.png',
    'assets/icons/house2.png',
    'assets/icons/house3.png',
    'assets/icons/house4.jpg',
  ];

  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: userName,
          contact: userContact,
          email: userEmail,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userName = result['name'];
        userContact = result['contact'];
        userEmail = result['email'];
      });
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'Settings':
        // Navigate to the SettingsPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case 'Logout':
        // Navigate to the LogoutPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignOutScreen()),
        );
        break;
      case 'Order History':
        // Navigate to the OrderHistoryPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderHistoryPage()),
        );
        break;
      case 'Help and Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpAndSupportPage()),
        );
        break;
      case 'Rate the App':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RateTheAppPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            const SizedBox(height: 60), // Adds space at the top of the drawer
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () => _onMenuSelected('Order History'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => _onMenuSelected('Settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _onMenuSelected('Logout'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help and Support'),
              onTap: () => _onMenuSelected('Help and Support'),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rate the App'),
              onTap: () => _onMenuSelected('Rate the App'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/icons/girl.jfif')),
              const SizedBox(height: 10),
              Text(userName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Contact: $userContact",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 5),
              Text("Email: $userEmail",
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.deepOrange),
                  const SizedBox(width: 5),
                  Text("Gujrat",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Posts",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100))),
              const SizedBox(height: 10),
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: userPosts.map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(imagePath,
                        width: double.infinity, fit: BoxFit.cover),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
