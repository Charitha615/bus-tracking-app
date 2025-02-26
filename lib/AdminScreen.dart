import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  late MapController _mapController;
  LatLng? _driverLocation;
  double _totalDistance = 0.0; // Total distance traveled by the driver
  Duration _trackingDuration = Duration.zero; // Total tracking duration
  String _driverName = "Loading..."; // Placeholder for driver name
  String _driverEmail = "Loading..."; // Placeholder for driver email
  String _driverUid = ""; // Driver UID

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchDriverLocation();
    _fetchDriverDetails();
  }

  void _fetchDriverLocation() {
    _databaseRef.child('locations').child('driver_location').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _driverLocation = LatLng(
            data['latitude'] as double,
            data['longitude'] as double,
          );
        });
        _mapController.move(_driverLocation!, 15.0);
      }
    });
  }

  void _fetchDriverDetails() {
    // Fetch the first driver's UID (you can modify this logic to fetch a specific driver)
    _databaseRef.child('users').orderByChild('role').equalTo('user').limitToFirst(1).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final driverData = data.values.first; // Get the first driver's data
        setState(() {
          _driverUid = driverData['uid'];
          _driverName = driverData['name'] ?? "Unknown Driver"; // Ensure 'name' exists in Firebase
          _driverEmail = driverData['email'];
          _totalDistance = driverData['totalDistance'] ?? 0.0;
          _trackingDuration = Duration(seconds: driverData['trackingDurationToday'] ?? 0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _driverLocation ?? LatLng(0.0, 0.0),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _driverLocation != null
                      ? [
                    Marker(
                      point: _driverLocation!,
                      child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
                    ),
                  ]
                      : [],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView( // Add scrollable view
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Driver Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Driver Name",
                    _driverName,
                    Icons.person,
                  ),
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Driver Email",
                    _driverEmail,
                    Icons.email,
                  ),
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Total Distance",
                    "${(_totalDistance / 1000).toStringAsFixed(2)} KM",
                    Icons.directions_car,
                  ),
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Tracking Duration",
                    "${_trackingDuration.inHours}h ${_trackingDuration.inMinutes.remainder(60)}m ${_trackingDuration.inSeconds.remainder(60)}s",
                    Icons.timer,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDetailCard(String title, String value, IconData icon) {
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
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.blueAccent),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}