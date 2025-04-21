import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/orders_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'screens/home_page.dart';
import 'screens/chat.dart';
import 'screens/search.dart';
import 'screens/profile_screen.dart';
import 'screens/camera.dart';
import 'screens/blocked_posts.dart'; // Make sure this file exists

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> favorites = [];

  List<Widget> _pages = [];
  List<TabItem> _tabItems = [];
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserAndSetupTabs();
  }

  Future<void> _loadUserAndSetupTabs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final user = jsonDecode(userString);

      final role = user['role'];
      print('User role: $role');
      setState(() {
        _role = role;

        // Conditionally show pages based on role
        if (role == 'admin') {
          _pages = [
            const HomePage(),
            //const SearchPage(),
            ProfileScreen(favorites: favorites),
          ];
          _tabItems = const [
            TabItem(icon: Icons.home, title: 'Home'),
           // TabItem(icon: Icons.search, title: 'Search'),
            TabItem(icon: Icons.person, title: 'Profile'),
          ];
        } else if (role == 'buyer') {
          _pages = [
            const HomePage(),
            const OrdersScreen(), // 👈 Orders
            const ChatPage(),
          //  const SearchPage(),
            ProfileScreen(favorites: favorites),
          ];
          _tabItems = const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.shopping_bag, title: 'Orders'),
            TabItem(icon: Icons.chat, title: 'Chat'),
          //  TabItem(icon: Icons.search, title: 'Search'),
            TabItem(icon: Icons.person, title: 'Profile'),
          ];
        } else if (role == 'provider') {
          _pages = [
            const HomePage(),
            const ChatPage(),
            const CreatePost(),
            const BlockedPostsPage(), // 👈 New screen
            ProfileScreen(favorites: favorites),
          ];
          _tabItems = const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.chat, title: 'Chat'),
            TabItem(icon: Icons.add, title: 'Add'),
            TabItem(icon: Icons.block, title: 'Blocked'),
            TabItem(icon: Icons.person, title: 'Profile'),
          ];
        }
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      // Loading indicator while waiting for user role
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.white,
        color: Colors.orange.shade900,
        activeColor: Colors.orange.shade900,
        style: TabStyle.react,
        initialActiveIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _tabItems,
      ),
    );
  }
}
