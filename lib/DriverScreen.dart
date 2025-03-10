import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileScreen.dart';
import 'HelpScreen.dart';
import 'NotificationsScreen.dart';

class DriverScreen extends StatefulWidget {
  final String userId; // Pass the user ID from the LoginScreen

  DriverScreen({required this.userId});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  bool _isSharingLocation = false;
  LatLng? _currentLocation;
  late StreamSubscription<Position> _positionStream;
  double _totalDistance = 0.0; // Total distance traveled in meters
  Duration _trackingDurationToday = Duration.zero; // Total tracking time today
  DateTime? _trackingStartTime; // Time when tracking started today
  Timer? _timer; // Timer to update the UI every second
  Map<String, dynamic>? _userData; // Store user data

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startTimer();
    _fetchUserData(); // Fetch user data from Firebase
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // Update the UI every second
    });
  }

  Future<void> _fetchUserData() async {
    // Fetch user data from Firebase
    DataSnapshot snapshot = await _databaseRef.child('users').child(widget.userId).get();
    if (snapshot.exists) {
      setState(() {
        _userData = snapshot.value as Map<String, dynamic>;
        _totalDistance = _userData?['totalDistance'] ?? 0.0;
        _trackingDurationToday = Duration(seconds: _userData?['trackingDurationToday'] ?? 0);
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permissions are permanently denied.")),
      );
      return;
    }
  }

  void _startSharingLocation() {
    setState(() {
      _isSharingLocation = true;
      _trackingStartTime = DateTime.now(); // Record the start time
    });

    _positionStream = Geolocator.getPositionStream().listen((position) {
      if (_currentLocation != null) {
        // Calculate distance between previous and current location
        double distance = Geolocator.distanceBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance; // Update total distance
      }

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _updateLocationInRealtimeDatabase(position);
    });
  }

  void _stopSharingLocation() {
    setState(() {
      _isSharingLocation = false;
      _trackingDurationToday += DateTime.now().difference(_trackingStartTime!); // Update tracking duration
      _trackingStartTime = null; // Reset start time
    });

    _positionStream.cancel();
    _databaseRef.child('locations').child('driver_location').remove();

    // Save total distance and tracking duration to Firebase
    _updateUserDataInDatabase();
  }

  void _updateLocationInRealtimeDatabase(Position position) {
    _databaseRef.child('locations').child('driver_location').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _updateUserDataInDatabase() {
    _databaseRef.child('users').child(widget.userId).update({
      'totalDistance': _totalDistance,
      'trackingDurationToday': _trackingDurationToday.inSeconds,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Dashboard"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen(userId: widget.userId)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(userId: widget.userId, userData: _userData)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpScreen(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildLocationCard(),
              SizedBox(height: 20),
              _buildActionButtons(),
              SizedBox(height: 20),
              _buildDashboardCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Current Location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _currentLocation != null
                ? "Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}"
                : "Location not available",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _isSharingLocation ? null : _startSharingLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text("Start Location"),
        ),
        ElevatedButton(
          onPressed: _isSharingLocation ? _stopSharingLocation : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text("End Location"),
        ),
      ],
    );
  }

  Widget _buildDashboardCards() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          "Total Distance",
          "${(_totalDistance / 1000).toStringAsFixed(2)} KM",
          Icons.directions_walk,
        ),
        _buildDashboardCard(
          "Tracking Today",
          _isSharingLocation ? "ON" : "OFF",
          Icons.timer,
          subtitle: _trackingStartTime != null
              ? "Time: ${_getFormattedTime(DateTime.now())}\nDuration: ${_getFormattedDuration(_trackingDurationToday + DateTime.now().difference(_trackingStartTime!))}"
              : "Time: ${_getFormattedTime(DateTime.now())}\nDuration: ${_getFormattedDuration(_trackingDurationToday)}",
        ),
      ],
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, {String? subtitle}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFormattedTime(DateTime time) {
    return "${time.hour}:${time.minute}:${time.second}";
  }

  String _getFormattedDuration(Duration duration) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s";
  }
}

// Add ProfileScreen, HelpScreen, and NotificationsScreen classes here