import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appp123/SettingsPage2.dart';
import 'package:flutter_appp123/home/screens/editprofile.dart';
import 'package:flutter_appp123/home/screens/helpandsupport.dart';
import 'package:flutter_appp123/home/screens/rateapp.dart';
import 'package:flutter_appp123/orderhistory.dart';
import 'package:flutter_appp123/signout.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;

  const ProfileScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "App Developer";
  String userContact = "+1234567890";
  String userEmail = "application12@gmail.com";
  String userLocation = "New York, USA";

  String profileImage = "";
  bool isLoading = true;
  bool isUpdatingImage = false;

  final List<String> userPosts = [
    'assets/icons/house1.png',
    'assets/icons/house2.png',
    'assets/icons/house3.png',
    'assets/icons/house4.jpg',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString == null) {
        print("User not found in SharedPreferences.");
        return;
      }

      final userMap = json.decode(userString);
      final userId = userMap['_id'];

      print("User ID: $userId");
      String backendUrl = dotenv.env['BACKEND_URL'] ?? "";
      print("Backend URL: $backendUrl");

      if (userId != null && backendUrl.isNotEmpty) {
        final response = await http.get(Uri.parse('$backendUrl/users/$userId'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            userName = data['name'] ?? 'N/A';
            userContact = data['phone'] ?? 'N/A';
            userEmail = data['email'] ?? 'N/A';
            userLocation = data['address'] ?? 'N/A';
            profileImage = data['profileImage'] ?? '';
            isLoading = false;
          });
        } else {
          print("Failed to fetch user data: ${response.body}");
        }
      } else {
        print("Missing userId or BACKEND_URL");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final userMap = json.decode(userString);
      final userId = userMap['_id'];
      String backendUrl = dotenv.env['BACKEND_URL'] ?? "";

      // Show image picker options
      final XFile? image = await showModalBottomSheet<XFile>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context,
                        await _picker.pickImage(source: ImageSource.gallery));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(context,
                        await _picker.pickImage(source: ImageSource.camera));
                  },
                ),
              ],
            ),
          );
        },
      );

      if (image != null && userId != null && backendUrl.isNotEmpty) {
        setState(() => isUpdatingImage = true);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$backendUrl/updateProfileImage/$userId'),
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            image.path,
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonData = jsonDecode(responseData);

          if (jsonData['user']?['profileImage'] != null) {
            // Update both local state and shared preferences
            await prefs.setString('user', json.encode(jsonData['user']));

            setState(() {
              profileImage = jsonData['user']['profileImage'];
              isUpdatingImage = false;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile image updated successfully')),
            );
          }
        } else {
          setState(() => isUpdatingImage = false);
          final errorResponse = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to update profile image: $errorResponse')),
          );
        }
      }
    } catch (e) {
      setState(() => isUpdatingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error updating profile image: ${e.toString()}')),
      );
      print("Error updating profile image: $e");
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
            name: userName,
            contact: userContact,
            email: userEmail,
            profileImage: profileImage),
      ),
    );

    if (result != null && mounted) {
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
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => SettingsPage()));
        break;
      case 'Logout':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => SignOutScreen()));
        break;
      case 'Order History':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => OrderHistoryPage()));
        break;
      case 'Help and Support':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => HelpAndSupportPage()));
        break;
      case 'Rate the App':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => RateTheAppPage()));
        break;
    }
  }

  Widget _buildDrawerItem(IconData icon, String text, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        _onMenuSelected(value);
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepOrange),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreOptionsSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => _onMenuSelected('Settings'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () => _onMenuSelected('Order History'),
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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _onMenuSelected('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => _buildMoreOptionsSheet(),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: profileImage.isNotEmpty
                                  ? NetworkImage(profileImage)
                                  : const AssetImage('assets/icons/girl.jfif')
                                      as ImageProvider,
                              child: isUpdatingImage
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : null,
                            ),
                            if (!isUpdatingImage)
                              GestureDetector(
                                onTap: _updateProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE65100),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Real Estate Agent",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow(Icons.person, "Name", userName),
                               const Divider(height: 20),
                            _buildDetailRow(
                                Icons.phone, "Contact", userContact),
                            const Divider(height: 20),
                            _buildDetailRow(Icons.email, "Email", userEmail),
                            const Divider(height: 20),
                            _buildDetailRow(
                                Icons.location_on, "Location", userLocation),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Properties Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Properties",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100)),
                        ),
                        const SizedBox(height: 12),
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: true,
                            viewportFraction: 0.8,
                          ),
                          items: userPosts.map((imagePath) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.share,
                                color: Color(0xFFE65100)),
                            label: const Text("Share",
                                style: TextStyle(color: Color(0xFFE65100))),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(color: Color(0xFFE65100)),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon:
                                const Icon(Icons.message, color: Colors.white),
                            label: const Text("Contact",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFE65100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : const AssetImage('assets/icons/girl.jfif')
                          as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.history, 'Order History', 'Order History'),
          _buildDrawerItem(Icons.settings, 'Settings', 'Settings'),
          _buildDrawerItem(Icons.help, 'Help & Support', 'Help and Support'),
          _buildDrawerItem(Icons.star, 'Rate App', 'Rate the App'),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', 'Logout'),
        ],
      ),
    );
  }
}
