import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

// Import all your screens
import 'screens/home_page.dart';
import 'screens/chat.dart';
import 'screens/search.dart';
import 'screens/profile_screen.dart';
import 'screens/camera.dart';
import 'screens/blocked_posts.dart';
import 'screens/orders_screen.dart';
import 'screens/camera.dart'; // Make sure this exists

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> favorites = [];
  String? _role;
  bool _isLoading = true;

  // Navigation items for each role
  late final Map<String, _NavigationConfig> _roleNavigationConfigs = {
    'admin': _NavigationConfig(
      pages: const [
        HomePage(),
        ProfileScreen(favorites: []),
      ],
      tabItems: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
    ),
    'buyer': _NavigationConfig(
      pages: [
        HomePage(),
        const OrdersScreen(),
        const ChatPage(),
        ProfileScreen(favorites: favorites),
      ],
      tabItems: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.shopping_bag, title: 'Orders'),
        TabItem(icon: Icons.chat, title: 'Chat'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
    ),
    'provider': _NavigationConfig(
      pages: [
        HomePage(
          onRefresh: () {
            // This will be called when HomePage refreshes itself
            // You can add additional logic here if needed
          },
        ),
        const ChatPage(),
        CreatePost(
          onPostCreated: () {
            // This will refresh the HomePage when a post is created
            (_pages[0] as HomePage).refreshPosts();
          },
        ),
        const BlockedPostsPage(),
        ProfileScreen(favorites: favorites),
      ],
      tabItems: const [
        TabItem(icon: Icons.home, title: 'Home'),
        TabItem(icon: Icons.chat, title: 'Chat'),
        TabItem(icon: Icons.add, title: 'Add'),
        TabItem(icon: Icons.block, title: 'Blocked'),
        TabItem(icon: Icons.person, title: 'Profile'),
      ],
    ),
  };

  List<Widget> _pages = [];
  List<TabItem> _tabItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndSetupTabs();
  }

  Future<void> _loadUserAndSetupTabs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null) {
        final user = jsonDecode(userString);
        final role =
            user['role'] ?? 'buyer'; // Default to buyer if role is null
        print('User role: $role');

        setState(() {
          _role = role;
          final config =
              _roleNavigationConfigs[role] ?? _roleNavigationConfigs['buyer']!;
          _pages = config.pages;
          _tabItems = config.tabItems;
          _isLoading = false;
        });
      } else {
        // Handle case when user is not logged in
        setState(() {
          _isLoading = false;
        });
        // You might want to navigate to login screen here
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshHomePage() {
    // This will be called when a new post is created
    if (_pages.isNotEmpty && _pages[0] is HomePage) {
      // Find the HomePage in your navigation and refresh it
      // You might need to implement a refresh mechanism in your HomePage
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

// Helper class to organize navigation configurations
class _NavigationConfig {
  final List<Widget> pages;
  final List<TabItem> tabItems;

  const _NavigationConfig({
    required this.pages,
    required this.tabItems,
  });
}
