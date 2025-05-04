import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appp123/SettingsPage2.dart';
import 'package:flutter_appp123/home/screens/editprofile.dart';
import 'package:flutter_appp123/home/screens/fooddetails.dart';
import 'package:flutter_appp123/home/screens/helpandsupport.dart';
import 'package:flutter_appp123/home/screens/housedetails.dart';
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
  List<dynamic> userBlogs = [];
  bool loadingBlogs = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserBlogs();
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

  Future<void> _loadUserBlogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString == null) {
        print("User not found in SharedPreferences.");
        return;
      }

      final userMap = json.decode(userString);
      final userId = userMap['_id'];
      if (userId == null) {
        print("User ID not found");
        return;
      }

      String backendUrl = dotenv.env['BACKEND_URL']!;

      final response = await http.get(
        Uri.parse('$backendUrl/blogs/author/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            userBlogs = data['blogs'];
            loadingBlogs = false;
          });
        }
      } else {
        print("Failed to fetch user blogs: ${response.body}");
        setState(() {
          loadingBlogs = false;
        });
      }
    } catch (e) {
      print("Error loading user blogs: $e");
      setState(() {
        loadingBlogs = false;
      });
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
            await prefs.setString('user', json.encode(jsonData['user']));

            setState(() {
              profileImage = jsonData['user']['profileImage'];
              isUpdatingImage = false;
            });

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

  // Widget _buildDetailRow(IconData icon, String title, String content) {
  //   return Row(
  //     children: [
  //       Icon(icon, color: Colors.deepOrange),
  //       const SizedBox(width: 10),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(title,
  //               style:
  //                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //           Text(content, style: const TextStyle(fontSize: 14)),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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

  // Widget _buildBlogCard(dynamic blog) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (blog['type'] == 'food') {
  //         // Navigate to food detail page
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (_) => FoodDetailPage(
  //                       itemId: blog['itemId'],
  //                       imageUrl: blog['imageUrl'],
  //                       title: blog['title'],
  //                       description: blog['description'],
  //                       price: blog['price'],
  //                       // addToCart: {},
  //                       favorites: [],
  //                     )));
  //       } else if (blog['type'] == 'rental') {
  //         // Navigate to house detail page
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (_) => HouseDetailPage(
  //                       authorId: blog['authorId'],
  //                       imageUrl: blog['imageUrl'],
  //                       title: blog['title'],
  //                       description: blog['description'],
  //                       price: blog['price'],
  //                       // itemId: blog['itemId'],
  //                     )));
  //       }
  //     },
  //     child: Card(
  //       elevation: 4,
  //       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           ClipRRect(
  //             borderRadius:
  //                 const BorderRadius.vertical(top: Radius.circular(12)),
  //             child: Image.network(
  //               blog['photoPath'],
  //               height: 180,
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) => Container(
  //                 height: 180,
  //                 color: Colors.grey[300],
  //                 child: const Icon(Icons.broken_image, size: 50),
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(12),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         blog['title'],
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 18,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                     if (blog['isBlocked'] == true)
  //                       const Icon(Icons.block, color: Colors.red),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   blog['content'],
  //                   style: const TextStyle(fontSize: 14),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Chip(
  //                       label: Text(
  //                         blog['type'].toString().toUpperCase(),
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                       backgroundColor: const Color(0xFFE65100),
  //                     ),
  //                     Text(
  //                       '\$${blog['price']}',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18,
  //                         color: Colors.deepOrange,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   'Posted on: ${DateTime.parse(blog['createdAt']).toLocal().toString().split(' ')[0]}',
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

// ... (keep all your imports and other code above)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE65100),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
        ],
      ),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header with Gradient
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                      ),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : const AssetImage('assets/icons/girl.jfif')
                                        as ImageProvider,
                                child: isUpdatingImage
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )
                                    : null,
                              ),
                            ),
                            if (!isUpdatingImage)
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: Colors.white,
                                onPressed: _updateProfileImage,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFE65100),
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
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Details Card with Neumorphic Design
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: Colors.grey[200],
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.person_outline_rounded,
                                "Name",
                                userName,
                              ),
                              const Divider(height: 20, color: Colors.grey),
                              _buildDetailRow(
                                Icons.phone_iphone_rounded,
                                "Contact",
                                userContact,
                              ),
                              const Divider(height: 20, color: Colors.grey),
                              _buildDetailRow(
                                Icons.email_outlined,
                                "Email",
                                userEmail,
                              ),
                              const Divider(height: 20, color: Colors.grey),
                              _buildDetailRow(
                                Icons.location_on_outlined,
                                "Location",
                                userLocation,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // My Posts Section with Modern Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            "My Posts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                        loadingBlogs
                            ? const Center(child: CircularProgressIndicator())
                            : userBlogs.isEmpty
                                ? Center(
                                    child: Column(
                                      children: [
                                        // Image.asset(
                                        //   'assets/images/no_posts.png',
                                        //   height: 120,
                                        // ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          "No posts yet",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    height: 220,
                                    child: CarouselSlider.builder(
                                      itemCount: userBlogs.length,
                                      options: CarouselOptions(
                                        autoPlay: true,
                                        aspectRatio: 16 / 9,
                                        enlargeCenterPage: true,
                                        viewportFraction: 0.8,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                      ),
                                      itemBuilder: (context, index, realIndex) {
                                        final blog = userBlogs[index];
                                        return GestureDetector(
                                          onTap: () {
                                            // Keep your navigation logic
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.network(
                                                    blog['photoPath'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment
                                                            .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                       
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              blog['title'],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              '\$${blog['price']}',
                                                              style:
                                                                  const TextStyle(
                                                               color: const Color(
                                                                    0xFFE65100),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),

                  // Action Buttons with Modern Design
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share, size: 20),
                            label: const Text("Share"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFFE65100),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFFE65100),
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.message, size: 20),
                            label: const Text("Contact"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFFE65100),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
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

// Enhanced Detail Row Widget
  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFE65100), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
