import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BlockedPostsPage extends StatefulWidget {
  const BlockedPostsPage({super.key});

  @override
  State<BlockedPostsPage> createState() => _BlockedPostsPageState();
}

class _BlockedPostsPageState extends State<BlockedPostsPage> {
  List<Map<String, dynamic>> blockedBlogs = [];
  bool _isLoading = true;
  String _filter = 'all';
  final TextEditingController _unblockReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBlockedBlogs();
  }

  Future<void> _loadBlockedBlogs() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userObj = json.decode(user);
      final response = await http.get(
        Uri.parse(
            "${dotenv.env['BACKEND_URL']}/blogs/author/${userObj['_id']}"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          blockedBlogs = List<Map<String, dynamic>>.from(data['blogs'])
              .where((blog) => blog['isBlocked'] == true)
              .toList();
        });
      }
    } catch (e) {
      _showErrorSnackbar("Error loading posts: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredBlogs {
    if (_filter == 'all') return blockedBlogs;
    return blockedBlogs.where((blog) => blog['type'] == _filter).toList();
  }

  Future<void> _deletePost(String blogId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to permanently delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse("${dotenv.env['BACKEND_URL']}/blogs/$blogId"),
      );

      if (response.statusCode == 200) {
        _loadBlockedBlogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully")),
        );
      }
    } catch (e) {
      _showErrorSnackbar("Failed to delete post");
    }
  }

  Future<void> _requestUnblock(String blogId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Request Unblock"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please explain why this post should be unblocked:"),
            const SizedBox(height: 16),
            TextField(
              controller: _unblockReasonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Reason for unblock request...",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitUnblockRequest(blogId);
            },
            child: const Text("Submit Request"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUnblockRequest(String blogId) async {
    if (_unblockReasonController.text.isEmpty) {
      _showErrorSnackbar("Please provide a reason");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${dotenv.env['BACKEND_URL']}/blogs/unblock-request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "blogId": blogId,
          "reason": _unblockReasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unblock request submitted")),
        );
        _unblockReasonController.clear();
      }
    } catch (e) {
      _showErrorSnackbar("Failed to submit request");
    }
  }

  @override
  void dispose() {
    _unblockReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange, // Set background color
        title: const Text(
          "Blocked Posts",
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Set font weight to bold
            fontSize: 20, // Set font size
          ),
          
        ),
      //  title: const Text("Blocked Posts"),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBlockedBlogs,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text("All Posts"),
              ),
              const PopupMenuItem(
                value: 'food',
                child: Text("Food Posts"),
              ),
              const PopupMenuItem(
                value: 'rental',
                child: Text("Rental Posts"),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBlogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        size: 64,
                        color: colors.error.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No blocked posts found",
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _filter == 'all'
                            ? "You don't have any blocked posts"
                            : "No ${_filter == 'food' ? 'food' : 'rental'} posts blocked",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = _filteredBlogs[index];
                      return _BlockedPostCard(
                        blog: blog,
                        onDelete: () => _deletePost(blog['_id']),
                        onUnblock: () => _requestUnblock(blog['_id']),
                      );
                    },
                  ),
                ),
    );
  }
}

class _BlockedPostCard extends StatelessWidget {
  final Map<String, dynamic> blog;
  final VoidCallback onDelete;
  final VoidCallback onUnblock;

  const _BlockedPostCard({
    required this.blog,
    required this.onDelete,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isFood = blog['type'] == 'food';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isFood
                        ? Colors.deepOrange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    image: blog['photoPath'] != null
                        ? DecorationImage(
                            image: NetworkImage(blog['photoPath']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: blog['photoPath'] == null
                      ? Center(
                          child: Icon(
                            isFood ? Icons.fastfood : Icons.home_work,
                            size: 48,
                            color: isFood ? Colors.amber : Colors.blue,
                          ),
                        )
                      : null,
                ),
              ),

              // Content section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog['title'] ?? 'Untitled Post',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        blog['content']?.length > 60
                            ? '${blog['content'].substring(0, 60)}...'
                            : blog['content'] ?? 'No description',
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isFood
                                  ? Colors.amber.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isFood ? 'FOOD' : 'RENTAL',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isFood ? Colors.amber : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            blog['createdAt'] != null
                                ? '${DateTime.parse(blog['createdAt']).difference(DateTime.now()).inDays.abs()}d ago'
                                : '',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Blocked badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "BLOCKED",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Action menu
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                 
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_vert, size: 20),
              ),
              onSelected: (value) {
                if (value == 'delete') onDelete();
                if (value == 'unblock') onUnblock();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'unblock',
                  child: Row(
                    children: [
                      Icon(Icons.lock_open, color: colors.primary),
                      const SizedBox(width: 8),
                      const Text("Request Unblock"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: colors.error),
                      const SizedBox(width: 8),
                      const Text("Delete Post"),
                    ],
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
