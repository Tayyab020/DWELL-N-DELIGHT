import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final List<Map<String, String>> notifications;

  const NotificationsPage({Key? key, required this.notifications})
      : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<Map<String, String>> notificationsList;

  @override
  void initState() {
    super.initState();
    // Make a copy of the list to modify
    notificationsList = List.from(widget.notifications);
  }

  void deleteNotification(int index) {
    setState(() {
      final removedNotification = notificationsList.removeAt(index);
      widget.notifications
          .removeWhere((item) => item['title'] == removedNotification['title']);
    });
  }

  @override
  void dispose() {
    Navigator.pop(context, widget.notifications); // ✅ Send updated list back
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade900,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(
                context, widget.notifications); // ✅ Return updated list
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: notificationsList.isEmpty
            ? const Center(
                child: Text("No notifications!",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              )
            : ListView.builder(
                itemCount: notificationsList.length,
                itemBuilder: (context, index) {
                  final notification = notificationsList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.notifications,
                          color: Colors.orange.shade900),
                      title: Text(notification['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(notification['body']!,
                          style: TextStyle(color: Colors.grey.shade600)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.orange.shade900),
                        onPressed: () => deleteNotification(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
