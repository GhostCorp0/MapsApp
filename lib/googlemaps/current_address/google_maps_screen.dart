import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_app/googlemaps/api_services/api_services.dart';
import 'package:maps_app/googlemaps/api_services/places_from_coordinates.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  double defaultLat = 28.383198339968967;
  double defaultLong = 77.05291104092355;
  PlacesFromCoordinates placesFromCoordinates = PlacesFromCoordinates();
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
              setState(() {
                defaultLat = position.target.latitude;
                defaultLong = position.target.longitude;
              });
            },
            onCameraIdle:(){
             ApiServices().placeFromCoordinates(defaultLat,defaultLong).then((value) {
               setState(() {
                 defaultLat = value.results != null &&
                     value.results!.isNotEmpty
                     ? value.results![0].geometry?.location?.lat??0.0:0.0;
                 defaultLong = value.results != null &&
                     value.results!.isNotEmpty
                     ? value.results![0].geometry?.location?.lng??0.0:0.0;
                 placesFromCoordinates = value;
               });
             });
            },
          ),
          const Center(child: Icon(Icons.location_on,size: 50,color: Colors.redAccent),)
        ],
      ),
      bottomSheet:Container(
        color: Colors.green[200],
        padding: EdgeInsets.only(top:20,bottom:30,left:20,right:20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Icon(Icons.location_on),
            ),
            Expanded(child: Text(placesFromCoordinates.results != null &&
                placesFromCoordinates.results!.isNotEmpty
                ? placesFromCoordinates.results![0].formattedAddress ?? "Loading..."
                : "Loading...",style: TextStyle(fontWeight:FontWeight.w500,fontSize: 20)))
          ],
        ),
      ),
    );
  }
}