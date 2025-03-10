import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  NotificationsScreen({required this.userId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    DataSnapshot snapshot = await _databaseRef.child('notifications').child(widget.userId).get();
    if (snapshot.exists) {
      // Convert the snapshot value to a Map
      Map<dynamic, dynamic> notificationsMap = snapshot.value as Map<dynamic, dynamic>;

      // Convert the Map to a List of Maps
      setState(() {
        _notifications = notificationsMap.values.toList().cast<Map<dynamic, dynamic>>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: _notifications.isEmpty
          ? Center(child: Text("No notifications available"))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_notifications[index]['message']),
            subtitle: Text(_notifications[index]['timestamp']),
          );
        },
      ),
    );
  }
}