import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BlockedPostsPage extends StatefulWidget {
  const BlockedPostsPage({super.key});

  @override
  State<BlockedPostsPage> createState() => _BlockedPostsPageState();
}

class _BlockedPostsPageState extends State<BlockedPostsPage> {
  List<Map<String, dynamic>> blockedBlogs = [];

  @override
  void initState() {
    super.initState();
    _loadBlockedBlogs();
  }

  Future<void> _loadBlockedBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user'); // Get userId from local storage
    print('User ID: $user');
    if (user != null) {
      try {
        final response = await http.get(
          Uri.parse("${dotenv.env['BACKEND_URL']}/blog/all"),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            blockedBlogs =
                List<Map<String, dynamic>>.from(responseData['blogs']);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch blocked blogs")),
          );
        }
      } catch (e) {
        print("❌ Error fetching blocked blogs: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching blocked blogs")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
    }
  }

  void _deleteBlog(int index) {
    setState(() {
      blockedBlogs.removeAt(index);
    });
    _updateLocalStorage();
  }

  void _requestUnblock(int index) {
    final blog = blockedBlogs[index];
    print("📩 Requesting unblock for blog ID: ${blog['_id']}");
    // Add your API call here if needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Unblock request sent")),
    );
  }

  void _editBlog(int index) {
    final blog = blockedBlogs[index];
    // Navigate to your edit blog page with `blog` details
    print("✏️ Editing blog: ${blog['_id']}");
  }

  void _updateLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('blockedBlogs', jsonEncode(blockedBlogs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blocked Posts")),
      body: blockedBlogs.isEmpty
          ? const Center(child: Text("No blocked posts found."))
          : ListView.builder(
              itemCount: blockedBlogs.length,
              itemBuilder: (context, index) {
                final blog = blockedBlogs[index];
                return ListTile(
                  title: Text(blog['title'] ?? 'Untitled'),
                  subtitle: Text(blog['content'] ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') _deleteBlog(index);
                      if (value == 'unblock') _requestUnblock(index);
                      if (value == 'edit') _editBlog(index);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                      const PopupMenuItem(
                          value: 'unblock', child: Text('Request Unblock')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
