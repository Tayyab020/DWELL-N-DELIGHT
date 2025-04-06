import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CloudinaryService {
  static Future<String?> uploadImageToCloudinary(File imageFile) async {
    final cloudinaryUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/flutrcloud/image/upload");
    final request = http.MultipartRequest("POST", cloudinaryUrl);

    // Add fields
    request.fields['upload_preset'] =
        "flutter_uploads"; // No authentication required
    request.files
        .add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      return jsonData["secure_url"]; // ✅ Returns the Cloudinary image URL
    } else {
      print("Upload failed: ${response.reasonPhrase}");
      return null;
    }
  }
}
