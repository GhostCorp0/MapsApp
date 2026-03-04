import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  double defaultLat = 28.383198339968967;
  double defaultLong = 77.05291104092355;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text("Current Address"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:CameraPosition(
              target: LatLng(defaultLat,defaultLong),
              zoom:16.476
            ),
            onCameraMove:(CameraPosition position) {
              print("lat${position.target.latitude} || long ${position.target.longitude}");
            },
          ),

          const Center(child: Icon(Icons.location_on,size: 50,color: Colors.redAccent),)
        ],
      ),
    );
  }
}