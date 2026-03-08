import 'package:flutter/material.dart';
import 'package:maps_app/googlemaps/current_address/google_maps_screen.dart';
import 'package:maps_app/googlemaps/current_address/location.dart';
import 'package:maps_app/googlemaps/live_location/live_location_polyline.dart';
import 'package:maps_app/googlemaps/polylines/polyline_screen.dart';
import 'package:maps_app/googlemaps/polylines/search_location.dart';
import 'package:maps_app/googlemaps/smooth_route/smooth_route.dart';
import 'package:maps_app/openstreetmap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.greenAccent),
      ),
      home: SmoothRoute(),
    );
  }
}