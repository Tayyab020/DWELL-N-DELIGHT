import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class LandlordProfilePage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final double price;
  final String authorId;

  const LandlordProfilePage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
    required this.authorId,
  });

  @override
  _LandlordProfilePageState createState() => _LandlordProfilePageState();
}

class _LandlordProfilePageState extends State<LandlordProfilePage> {
  Map<String, dynamic>? landlordData;
  bool isLoading = true;
  String errorMessage = '';
  String locationName = "Loading location...";
  String phoneNumber = "";
  List<double>? coordinates;

  @override
  void initState() {
    super.initState();
    fetchLandlordData();
  }

Future<void> _convertCoordinatesToAddress() async {
    if (coordinates == null || coordinates!.length < 2) {
      setState(() => locationName = "Location not specified");
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates![1], // latitude
        coordinates![0], // longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Get all available address components
        String area = place.subLocality ?? place.locality ?? "";
        String city = place.locality ?? "";
        String province = place.administrativeArea ?? "";
        String country = place.country ?? "";
        String street = place.street ?? "";
        String postalCode = place.postalCode ?? "";

        // Build address in hierarchical format
        List<String> addressParts = [];

        if (street.isNotEmpty) addressParts.add(street);
        if (area.isNotEmpty && area != city) addressParts.add(area);
        if (city.isNotEmpty) addressParts.add(city);
        if (province.isNotEmpty) addressParts.add(province);
        if (postalCode.isNotEmpty) addressParts.add(postalCode);
        if (country.isNotEmpty) addressParts.add(country);

        // Format with line breaks for better readability
        String formattedAddress = addressParts.join(", ");

        // Alternative format with new lines:
        // String formattedAddress = addressParts.join("\n");

        setState(() {
          locationName = formattedAddress.isNotEmpty
              ? formattedAddress
              : "Coordinates: ${coordinates![1].toStringAsFixed(6)}, "
                  "${coordinates![0].toStringAsFixed(6)}";
        });
      } else {
        setState(() {
          locationName =
              "Location available (${coordinates![1].toStringAsFixed(6)}, "
              "${coordinates![0].toStringAsFixed(6)})";
        });
      }
    } catch (e) {
      setState(() {
        locationName =
            "Location available (${coordinates![1].toStringAsFixed(6)}, "
            "${coordinates![0].toStringAsFixed(6)})";
      });
    }
  }
  Future<void> fetchLandlordData() async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? "";
      if (backendUrl.isEmpty) {
        throw Exception("Backend URL not configured");
      }

      final response = await http
          .get(
            Uri.parse('$backendUrl/users/${widget.authorId}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          landlordData = data;
          isLoading = false;
          phoneNumber = data['phone']?.toString() ?? '';

          // Handle coordinates
          if (data['location'] != null &&
              data['location']['coordinates'] != null) {
            coordinates = List<double>.from(data['location']['coordinates']);
            _convertCoordinatesToAddress();
          } else {
            locationName = "Location not specified";
          }
        });
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading profile: ${e.toString()}';
        locationName = 'Location unavailable';
      });
    }
  }

 Future<void> _makePhoneCall() async {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanedNumber.startsWith('0')) {
      cleanedNumber = '+92${cleanedNumber.substring(1)}';
    } else if (!cleanedNumber.startsWith('+')) {
      cleanedNumber = '+92$cleanedNumber';
    }

    try {
      await launchUrl(Uri.parse('tel:$cleanedNumber'));
    } catch (e) {
      try {
        await launch('tel:$cleanedNumber');
      } catch (e) {
        // Show manual dial option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Dial Number"),
            content: Text("Please dial $cleanedNumber"),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cleanedNumber));
                  Navigator.pop(context);
                },
                child: Text("Copy"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Landlord Profile",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE65100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchLandlordData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: landlordData?['profileImage'] != null
                              ? NetworkImage(landlordData!['profileImage'])
                              : const AssetImage('assets/icons/landlord.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          landlordData?['name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Contact: ${phoneNumber.isNotEmpty ? phoneNumber : 'Not provided'}",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Email: ${landlordData?['email'] ?? 'Not provided'}",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.orange),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                locationName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Posted Property",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  widget.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.home, size: 100),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Price: PKR ${widget.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: phoneNumber.isNotEmpty
                                  ? _makePhoneCall
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.call, color: Colors.white),
                              label: const Text("Call",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Opening Chat...")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.message,
                                  color: Colors.white),
                              label: const Text("Message",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
