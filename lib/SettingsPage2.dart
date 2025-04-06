import 'package:flutter/material.dart';
import 'package:flutter_appp123/home/screens/helpandsupport.dart';
import 'package:flutter_appp123/signout.dart';
import 'package:flutter_appp123/widgets/manageaccount.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Toggle for theme
  bool isNotificationsEnabled = true; // Toggle for notifications

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            )),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Profile Section
          ListTile(
            leading: Icon(Icons.person, color: Colors.orange.shade900),
            title: Text("Account"),
            subtitle: Text("Manage your account settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettingsPage()),
              );
            },
          ),

          Divider(),

          // Dark Mode Toggle
          SwitchListTile(
            activeColor: Colors.orange.shade900,
            title: Text("Dark Mode"),
            subtitle: Text("Enable dark theme"),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
              });
            },
          ),
          Divider(),

          // Notifications Toggle
          SwitchListTile(
            activeColor: Colors.orange.shade900,
            title: Text("Notifications"),
            subtitle: Text("Receive notifications"),
            value: isNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                isNotificationsEnabled = value;
              });
            },
          ),
          Divider(),

          // Help & Support
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.orange.shade900),
            title: Text("Help & Support"),
            subtitle: Text("Get support or FAQs"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpAndSupportPage()),
              ); // Implement help section navigation
            },
          ),
          Divider(),

          // Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.orange.shade900),
            title:
                Text("Logout", style: TextStyle(color: Colors.orange.shade900)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignOutScreen()),
              ); // Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}
