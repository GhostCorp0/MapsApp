import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_app/googlemaps/live_location/marker_icon.dart';

class LiveLocationPolyline extends StatefulWidget {
  const LiveLocationPolyline({super.key});

  @override
  State<LiveLocationPolyline> createState() => _LiveLocationPolylineState();
}

class _LiveLocationPolylineState extends State<LiveLocationPolyline> {
  late GoogleMapController googleMapController;

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  double defaultLat = 28.383198339968967;
  double defaultLong = 77.05291104092355;

  double destinationLat = 28.391910970173377;
  double destinationLng = 77.04629669252137;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polyLineCoordinates = [];

  LatLng? originLatLng;
  LatLng? destinationLatLng;

  CameraPosition? initialPosition;

  BitmapDescriptor? liveLocationMarker;

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearching
          ? AppBar(
              backgroundColor: Colors.greenAccent,
              centerTitle: true,
              leading: BackButton(
                onPressed: () {
                  setState(() {
                    isSearching = false;
                  });
                },
              ),
              title: TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: "Search Place..."),
                onChanged: (String value) {},
              ),
            )
          : AppBar(
              centerTitle: true,
              backgroundColor: Colors.greenAccent,
              title: Text("Live Location Polyline"),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
      body: initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: initialPosition!,
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
              markers: markers,
              polylines: polylines,
            ),

      floatingActionButton: FloatingActionButton(onPressed:() {
        googleMapController.animateCamera(CameraUpdate.newLatLngZoom(originLatLng!,.16));
      },child: Icon(Icons.my_location_outlined),),
    );
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

 _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable the services',
      );
    }

    permission = await _geolocatorPlatform.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: Duration(seconds: 10),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: "Running in background",
          notificationText:
              "This app will continue to receive your location even when you aren't using it",
          enableWakeLock: true,
        ),
      );
    }

    await getBytesFromAsset("assets/images/ic_live_location.png", 100).then((value){
      setState(() {
        liveLocationMarker = value;
      });
    });

    _geolocatorPlatform
        .getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
          print(
            position == null
                ? "unknown"
                : '${position.latitude.toString()},${position.longitude.toString()}',
          );
          originLatLng = LatLng(position!.latitude, position!.longitude);
          initialPosition = CameraPosition(target: originLatLng!, zoom: 15);
          markers.removeWhere((element) => element.mapsId.value.compareTo("origin") ==0 );
          markers.add(
            Marker(markerId:MarkerId("origin"),icon: liveLocationMarker!, position: originLatLng!)
          );
          setState(() {});
        });
  }
}
