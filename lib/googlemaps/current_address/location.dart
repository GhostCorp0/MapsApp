import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_app/googlemaps/api_services/api_services.dart';
import 'package:maps_app/googlemaps/api_services/get_places.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  TextEditingController searchPlaceController = TextEditingController();
  GetPlaces getPlaces = GetPlaces();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text("Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            TextField(
              controller: searchPlaceController,
              decoration: InputDecoration(hintText: "Search Place..."),
              onChanged: (String value) {
                print(value.toString());
                ApiServices().getPlaces(value.toString()).then((value){
                  setState(() {

                  });
                });
              },
            ),
            Visibility(
              visible: searchPlaceController.text.isEmpty?false:true,
              child: Expanded(
                child: ListView.builder(
                  itemCount: getPlaces.predictions?.length??0,
                  shrinkWrap:true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(getPlaces.predictions![index].description.toString()),
                      onTap:(){
                        ApiServices().getCoordinatesFromPlaceId(getPlaces.predictions?[index].placeId??"").then((value){
                          //move to google maps screen with latitude and longitude
                        }).onError((error,stackTrace){
                          print("Error: ${error.toString()}");
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            Visibility(
              visible: searchPlaceController.text.isEmpty ? true : false,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () async{

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, color: Colors.green),
                      SizedBox(width: 5),
                      Text("Current Location"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
