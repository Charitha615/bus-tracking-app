import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import './DriverScreen.dart';
import './AdminScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String _selectedRole = 'user'; // Default role

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Retrieve user role from Firebase Database
        DataSnapshot snapshot =
        await _databaseRef.child('users').child(userCredential.user!.uid).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> userDetails = snapshot.value as Map<dynamic, dynamic>;
          String role = userDetails['role'] ?? 'user'; // Default to 'user' if role is missing

          // Navigate based on role
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => role == "admin" ? AdminScreen() : DriverScreen(userId: userCredential.user!.uid),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login failed")),
        );
      }
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Store user details with role in Firebase Database
        await _databaseRef.child('users').child(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'uid': userCredential.user!.uid,
          'role': _selectedRole, // Store user role
          'createdAt': DateTime.now().toIso8601String(),
        });

        // Navigate based on selected role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            _selectedRole == "admin" ? AdminScreen() : DriverScreen(userId: userCredential.user!.uid),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Account creation failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                decoration: InputDecoration(labelText: "Select Role"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: _createAccount,
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}