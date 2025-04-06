import 'package:flutter/material.dart';
import 'package:flutter_appp123/Onboard_page1/Onboard_page1.dart';
import 'package:flutter_appp123/Otp/otp_creen.dart';
import 'package:flutter_appp123/home/screens/cart1.dart';
import 'package:flutter_appp123/forget-pswd/forget_pswd.dart';
import 'package:flutter_appp123/home/home_screen.dart';
import 'package:flutter_appp123/home/screens/search.dart';
import 'package:provider/provider.dart';

//import 'package:flutter_appp123/onboard_page2/onboard_page2.dart';
import 'package:flutter_appp123/onboard_page3/onboard_page3.dart';
import 'package:flutter_appp123/orderhistory.dart';
import 'package:flutter_appp123/reset-pswd/reset_pswd.dart';
import 'package:flutter_appp123/screens/splash_screen.dart';
import 'package:flutter_appp123/sign_up/sign_up.dart';
import 'package:flutter_appp123/home/screens/profile_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_appp123/home/screens/cartprovider.dart';

// import 'package:flutter_appp123/home/home_screen.dart';
// import 'package:flutter_appp123/onboard_page1/onboard_page1.dart';
// import 'package:flutter_appp123/Onboard_page2/Onboard_page2.dart';
// import 'package:flutter_appp123/onboard_page3/onboard_page3.dart';
class Post {
  final String imagePath;
  final String caption;
  final bool isPublic;

  Post(
      {required this.imagePath, required this.caption, required this.isPublic});
}

// ✅ Global list to store posts
List<Post> userPosts = [];

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const Onboard_page1(),
    );
  }
}

class DwellNDelightScreen extends StatelessWidget {
  const DwellNDelightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classico'),
      ),
      body: const Text('hello'),
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Dwell N Delight',
    theme: ThemeData(
      primarySwatch: Colors.orange,
      fontFamily: 'Poppins',
    ),
    home: const DwellNDelightScreen(),
  );
}
