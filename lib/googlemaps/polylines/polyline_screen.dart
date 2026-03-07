import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants.dart';

class PolylineScreen extends StatefulWidget {
  const PolylineScreen({super.key});

  @override
  State<PolylineScreen> createState() => _PolylineScreenState();
}

class _PolylineScreenState extends State<PolylineScreen> {
  double defaultLat = 28.383198339968967;
  double defaultLong = 77.05291104092355;

  double destinationLat = 28.391910970173377;
  double destinationLng = 77.04629669252137;
  Completer<GoogleMapController> googleMapController = Completer();
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<LatLng> polyLineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints(apiKey:Constants.apiKey);


  @override
  void initState() {
    markers.add(
      Marker(
        markerId: MarkerId("origin"),
        position: LatLng(defaultLat, defaultLong),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId("destination"),
        position: LatLng(destinationLat, destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(90),
      ),
    );
    _getPolyLine();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(defaultLat, defaultLong),
        zoom: 15,
      ),
      myLocationEnabled: true,
      tiltGesturesEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      zoomControlsEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        googleMapController.complete(controller);
      },
      markers: markers,
      polylines: polylines,
    );
  }

 /* _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(defaultLat, defaultLong),
        destination: PointLatLng(destinationLat, destinationLng),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polyLineCoordinates.clear();

      for (var point in result.points) {
        polyLineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }

      setState(() {
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: polyLineCoordinates,
            color: Colors.blue,
            width: 6,
          ),
        );
      });
    }
  }*/

  void _getPolyLine() {
    polyLineCoordinates = [
      LatLng(28.394352862346192, 77.04529499009605),
      LatLng(28.394251958175882, 77.04531028295827),
      LatLng(28.394177961114504, 77.04541733866834),
      LatLng(28.394177961114504, 77.04541733866834),
      LatLng(28.39410396174886, 77.0457690944828),
      LatLng(28.393982876774523, 77.04577673973326),
      LatLng(28.39394251506266, 77.045784386073),
      LatLng(28.393686891892365, 77.04573850154414),
      LatLng(28.393538901125, 77.04553968178294),
      LatLng(28.393494480943655, 77.04510351533962),
      LatLng(28.393380700964144, 77.04477585104975),
      LatLng(28.393183479611032, 77.04476722746021),
      LatLng(28.39283454823573, 77.04500866097023),
      LatLng(28.392804203024152, 77.04547428550623),
      LatLng(28.392796611893825, 77.04598302395719),
      LatLng(28.392910384916522, 77.04655212436325),
      LatLng(28.392872449055847, 77.04700050496756),
    ];

    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: polyLineCoordinates,
          color: Colors.blue,
          width: 6,
        ),
      );
    });
  }
}
