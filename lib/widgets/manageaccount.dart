import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/editprofile.dart';
import 'package:flutter_appp123/reset-pswd/reset_pswd.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40), // Moves all content slightly lower
            _buildSettingOption(
              icon: Icons.person,
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: "John Doe",
                      // Replace with actual user data
                      contact: "1234567890",
                      // Replace with actual user data
                      email:
                          "johndoe@example.com", // Replace with actual user data
                    ),
                  ),
                );
              },
            ),
            _buildSettingOption(
              icon: Icons.email,
              title: "Change Email",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: "John Doe",
                      // Replace with actual user data
                      contact: "1234567890",
                      // Replace with actual user data
                      email:
                          "johndoe@example.com", // Replace with actual user data
                    ),
                  ),
                );
              },
            ),
            _buildSettingOption(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPass()),
                ); // Implement password change logic
              },
            ),
            _buildSettingOption(
              icon: Icons.delete,
              title: "Delete Account",
              isDestructive: true,
              onTap: () {
                _showDeleteConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isDestructive ? Colors.red.shade100 : Colors.orange.shade100,
          child: Icon(icon,
              color: isDestructive ? Colors.red : Colors.orange.shade900),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.grey[800],
          ),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: onTap,
      ),
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text(
            "Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteAccount(context); // Proceed to delete account
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void _deleteAccount(BuildContext context) {
  // Implement actual account deletion logic (API call, database removal, etc.)

  // Show a success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Account deleted successfully.")),
  );

  // Navigate back to login or home page
  Navigator.pushReplacementNamed(context, '/login'); // Adjust route as needed
}
