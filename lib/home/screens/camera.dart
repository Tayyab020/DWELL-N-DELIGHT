import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/full_screen_loader.dart'; // Adjust the import as needed

class CreatePost extends StatefulWidget {
    final VoidCallback? onPostCreated; // Add this callback

  const CreatePost({super.key, this.onPostCreated});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  // State variables
  String _type = 'food';
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  // Constants
  static const _postTypes = {
    'food': 'Food',
    'rental': 'Rental',
  };

  final _formKey = GlobalKey<FormState>();
  final _buttonTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _priceController.clear();
    setState(() {
      _type = 'food';
      _selectedFile = null;
    });
  }

  Future<void> _pickImageOrVideo(ImageSource source,
      {bool isVideo = false}) async {
    try {
      final pickedFile = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() => _selectedFile = File(pickedFile.path));
      }
    } catch (e) {
      _showToast("Error picking file: ${e.toString()}");
    }
  }

  Future<void> _createBlog() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _getCurrentUser();
      if (user == null) return;

      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) {
        _showToast("Backend URL not configured");
        return;
      }

      final response = await _sendPostRequest(backendUrl, user['_id']);
      _handleResponse(response);
    } catch (e) {
      _showToast("Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _priceController.text.isEmpty) {
      _showToast("Please fill all required fields");
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson == null) {
      _showToast("User not found. Please log in again.");
      return null;
    }

    return jsonDecode(userJson);
  }

  Future<http.StreamedResponse> _sendPostRequest(
      String url, String userId) async {
    final request = http.MultipartRequest('POST', Uri.parse('$url/blog'));

    request.fields.addAll({
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'price': _priceController.text.trim(),
      'type': _type,
      'author': userId,
    });

    if (_selectedFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('photoPath', _selectedFile!.path));
    }

    return await request.send();
  }

  void _handleResponse(http.StreamedResponse response) async {
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showToast("✅ Post created successfully!");
      _clearForm();
       if (widget.onPostCreated != null) {
        widget.onPostCreated!(); // Trigger the callback
      }
    } else {
      _showToast("❌ Failed to create post: $responseBody");
    }
  }
  // void _clearForm() {
  //   _formKey.currentState?.reset();
  //   setState(() {
  //     _type = 'food';
  //     _selectedFile = null;
  //   });
  // }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildMediaPicker() {
    return Card(
      elevation: 2,
      color: Colors.white, // White background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Media',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white, // White background

              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaButton(
                      icon: Icons.image,
                      label: 'Gallery',
                      onPressed: () => _pickImageOrVideo(ImageSource.gallery),
                      iconColor: Colors.orange.shade800,
                      borderColor: Colors.orange.shade800,
                    ),
                    _buildMediaButton(
                      icon: Icons.video_library,
                      label: 'Video',
                      onPressed: () =>
                          _pickImageOrVideo(ImageSource.gallery, isVideo: true),
                      iconColor: Colors.orange.shade800,
                      borderColor: Colors.orange.shade800,
                    ),
                    _buildMediaButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onPressed: () => _pickImageOrVideo(ImageSource.camera),
                      iconColor: Colors.orange.shade800,
                      borderColor: Colors.orange.shade800,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color iconColor = Colors.black,
    Color borderColor = Colors.grey,
    Color backgroundColor = Colors.white, // Add background color parameter
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: iconColor),
      label: Text(label, style: TextStyle(color: iconColor)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedFile == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected Media',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _selectedFile!.path.endsWith('.mp4')
                  ? Row(
                      children: [
                        const Icon(Icons.videocam, size: 40),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedFile!.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedFile!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create New Post'),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.orange.shade900,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration('Title'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 4,
                    decoration: _inputDecoration('Content'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Content is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Price'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Price is required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: _inputDecoration('Post Type'),
                    items: _postTypes.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                  const SizedBox(height: 24),
                  _buildMediaPicker(),
                  _buildMediaPreview(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearForm,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Colors.orange.shade800,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.deepOrange,
                          ),
                          child: const Text(
                            'CLEAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createBlog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'PUBLISH',
                                  style: _buttonTextStyle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const FullScreenLoader(),
      ],
    );
  }
}
