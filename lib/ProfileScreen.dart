import 'package:bus_tracking/DriverScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? userData;

  ProfileScreen({required this.userId, required this.userData});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _busRegController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    // Debug: Print the userData to verify it's being passed correctly
    print("User Data in ProfileScreen: ${widget.userData}");

    // Set the initial values for the text controllers
    _nameController.text = widget.userData?['name'] ?? '';
    _phoneController.text = widget.userData?['phone'] ?? '';
    _busRegController.text = widget.userData?['busReg'] ?? '';
  }

  Future<void> _updateProfile() async {
    // Update the user data in Firebase
    await _databaseRef.child('users').child(widget.userId).update({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'busReg': _busRegController.text,
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => DriverScreen(
                userId: widget.userId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _busRegController,
              decoration: InputDecoration(labelText: "Bus Registration"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
