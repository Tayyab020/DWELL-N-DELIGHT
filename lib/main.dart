import 'package:flutter/material.dart';
import 'package:flutter_appp123/Onboard_page1/Onboard_page1.dart';
import 'package:flutter_appp123/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '/home/screens/cartprovider.dart'; // Make sure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <--- Important!
  try {
    await dotenv.load(fileName: "assets/.env");
    print("✅ .env loaded. BACKEND_URL: ${dotenv.env['BACKEND_URL']}");
  } catch (e) {
    print("❌ Error loading environment variables: $e");
  }

  runApp(
    ChangeNotifierProvider(
      // Add this line to wrap your app with CartProvider
      create: (context) => CartProvider(),
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
      theme: ThemeData(primarySwatch: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.white),
      home: const LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('✅ Token found in localStorage: $token');

    // Delay just to simulate loading
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navigate after build completes
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                token != null ? const HomeScreen() : const Onboard_page1(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const SizedBox
              .shrink(), // Blank screen after loading, auto navigates
    );
  }
}
