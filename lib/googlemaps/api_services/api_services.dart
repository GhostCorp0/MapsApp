import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maps_app/googlemaps/api_services/get_coordinates_from_placeid.dart';
import 'package:maps_app/googlemaps/api_services/get_places.dart';
import 'package:maps_app/googlemaps/api_services/places_from_coordinates.dart';

import '../constants.dart';

class ApiServices {
  
  Future<PlacesFromCoordinates> placeFromCoordinates(double lat,double lng) async {
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constants.apiKey}");
    var response = await http.get(url);

    if(response.statusCode == 200){
      return PlacesFromCoordinates.fromJson(jsonDecode(response.body));
    }else {
      throw Exception("API ERROR : placeFromCoordinates");
    }
  }

  Future<GetPlaces> getPlaces(String placeName) async {
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${Constants.apiKey}");
    var response = await http.get(url);

    if(response.statusCode == 200){
      return GetPlaces.fromJson(jsonDecode(response.body));
    }else {
      throw Exception("API ERROR : placeFromCoordinates");
    }
  }

  Future<GetCoordinatesFromPlaceId> getCoordinatesFromPlaceId(String placeId) async {
    Uri url = Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?placeId=$placeId&key=${Constants.apiKey}");
    var response = await http.get(url);

    if(response.statusCode == 200){
      return GetCoordinatesFromPlaceId.fromJson(jsonDecode(response.body));
    }else {
      throw Exception("API ERROR : placeFromCoordinates");
    }
  }
  
}