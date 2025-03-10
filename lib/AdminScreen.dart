import 'package:bus_tracking/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<Map<dynamic, dynamic>> _helpRequests = [];
  final TextEditingController _replyController = TextEditingController();
  late MapController _mapController;
  LatLng? _driverLocation;
  double _totalDistance = 0.0; // Total distance traveled by the driver
  Duration _trackingDuration = Duration.zero; // Total tracking duration
  String _driverName = "Loading...";
  String _driverBusRegNum = "Loading...";
  String _driverContactNum = "Loading...";
  String _driverEmail = "Loading...";
  String _driverUid = ""; // Driver UID

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchDriverLocation();
    _fetchDriverDetails();
    _fetchHelpRequests();
  }

  Future<void> _fetchHelpRequests() async {
    DataSnapshot snapshot = await _databaseRef.child('helpRequests').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> helpRequestsMap =
          snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _helpRequests = helpRequestsMap.entries.map((entry) {
          // Include the key in the data
          return {
            'key': entry.key, // Add the key to the map
            ...entry.value, // Spread the existing data
          };
        }).toList();
      });
    }
  }

  Future<void> _sendReply(String userId, String helpRequestId) async {
    if (_replyController.text.isNotEmpty) {
      // Create a new notification under the user's ID
      await _databaseRef.child('notifications').child(userId).push().set({
        'message': _replyController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Clear the reply text field
      _replyController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply sent successfully!")),
      );
    } else {
      // Show an error if the reply is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply cannot be empty!")),
      );
    }
  }

  void _fetchDriverLocation() {
    _databaseRef
        .child('locations')
        .child('driver_location')
        .onValue
        .listen((event) {
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _fetchDriverDetails() {
    // Fetch the first driver's UID (you can modify this logic to fetch a specific driver)
    _databaseRef
        .child('users')
        .orderByChild('role')
        .equalTo('user')
        .limitToFirst(1)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final driverData = data.values.first; // Get the first driver's data
        setState(() {
          _driverUid = driverData['uid'];
          _driverName = driverData['name'] ?? "Unknown Driver";
          _driverBusRegNum = driverData['busReg'] ?? "Unknown Driver";
          _driverContactNum = driverData['phone'] ?? "Unknown Driver";
          _driverEmail = driverData['email'];
          _totalDistance = driverData['totalDistance'] ?? 0.0;
          _trackingDuration =
              Duration(seconds: driverData['trackingDurationToday'] ?? 0);
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
            flex: 1,
            child: ListView.builder(
              itemCount: _helpRequests.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_helpRequests[index]['message']),
                  subtitle: Text(_helpRequests[index]['timestamp']),
                  trailing: IconButton(
                    icon: Icon(Icons.reply),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Reply to Help Request"),
                            content: TextField(
                              controller: _replyController,
                              decoration: InputDecoration(labelText: "Reply"),
                              maxLines: 5,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  print(
                                      "Send button pressed"); // Debugging line
                                  _sendReply(
                                    _helpRequests[index]['userId'],
                                    _helpRequests[index]
                                        ['key'], // Use the key here
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text("Send"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _driverLocation ?? LatLng(0.0, 0.0),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _driverLocation != null
                      ? [
                          Marker(
                            point: _driverLocation!,
                            child: Icon(Icons.location_pin,
                                color: Colors.blue, size: 40),
                          ),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              // Add scrollable view
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
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Driver Contact Number",
                    _driverContactNum,
                    Icons.person,
                  ),
                  SizedBox(height: 10),
                  _buildDriverDetailCard(
                    "Bus Reg Number",
                    _driverBusRegNum,
                    Icons.person,
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: _logout,
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
