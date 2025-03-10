import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HelpScreen extends StatefulWidget {
  final String userId;

  HelpScreen({required this.userId});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendHelpRequest() async {
    if (_formKey.currentState!.validate()) {
      await _databaseRef.child('helpRequests').push().set({
        'userId': widget.userId,
        'message': _messageController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Help request sent successfully!")),
      );

      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: "Message"),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendHelpRequest,
                child: Text("Send Help Request"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}