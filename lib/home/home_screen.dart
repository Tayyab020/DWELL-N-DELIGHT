import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'screens/home_page.dart';
import 'screens/chat.dart';
import 'screens/search.dart';
import 'screens/profile_screen.dart';
import 'screens/camera.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> favorites = [];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ChatPage(),
      const CameraPage(),
      const SearchPage(),
      ProfileScreen(favorites: favorites),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        items: const [
          TabItem(icon: Icons.home_rounded, title: ''),
          TabItem(icon: Icons.chat_bubble_outline, title: ''),
          TabItem(icon: Icons.camera_alt_rounded, title: ''),
          TabItem(icon: Icons.search, title: ''),
          TabItem(icon: Icons.person, title: ''),
        ],
      ),
    );
  }
}
