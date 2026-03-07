import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_app/googlemaps/api_services/api_services.dart';
import 'package:maps_app/googlemaps/api_services/get_coordinates_from_placeid.dart';
import 'package:maps_app/googlemaps/api_services/get_places.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  LatLng? originLatLng;
  LatLng? destinationLatLng;
  bool isSearching = false;
  GetPlaces getPlaces = GetPlaces();
  bool isFocusOrigin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text("Search Location"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: originController,
                    decoration: InputDecoration(hintText: "Search Place..."),
                    onChanged: (String value) {
                      ApiServices().getPlaces(value.toString()).then((value) {
                        setState(() {
                          getPlaces = value;
                        });
                      });
                    },
                    onTap: () {
                      setState(() {
                        isFocusOrigin = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 15),
                Text("Or", style: TextStyle(fontSize: 20)),
                SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 45,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location_sharp),
                          Text("Current"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text("To", style: TextStyle(fontSize: 20)),
            SizedBox(height: 15),
            TextFormField(
              controller: destinationController,
              decoration: InputDecoration(hintText: "Search Place.."),
              onChanged: (String value) {
                ApiServices().getPlaces(value.toString()).then((value) {
                  setState(() {
                    getPlaces = value;
                  });
                });
              },
              onTap: () {
                isFocusOrigin = false;
              },
            ),
            SizedBox(height: 20),
            Visibility(
              visible: getPlaces.predictions == null ? false : true,
              child: Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        ApiServices()
                            .getCoordinatesFromPlaceId(
                              getPlaces.predictions?[index].placeId ?? "",
                            )
                            .then((value) {
                              if (isFocusOrigin) {
                                originLatLng = LatLng(
                                  value.result?.geometry?.location?.lat ?? 0.0,
                                  value.result?.geometry?.location?.lng ?? 0.0,
                                );
                                //  originController.text = value.result?.formattedAddress??"";
                                getPlaces.predictions = null;
                              } else {
                                // originController.text = value.result?.formattedAddress??"";
                                destinationLatLng = LatLng(
                                  value.result?.geometry?.location?.lat ?? 0.0,
                                  value.result?.geometry?.location?.lng ?? 0.0,
                                );
                                getPlaces.predictions = null;
                              }

                              setState(() {});
                            })
                            .onError((error, stackTrace) {
                              print(error.toString());
                            });
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(onPressed: () {
                if(originLatLng == null || destinationLatLng == null){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Please Enter Places"),backgroundColor: Colors.redAccent,));
                }else {
                  print("${originLatLng.toString()} | ${destinationLatLng.toString()}");
                }
              }, child: Text("Submit")),
            ),
          ],
        ),
      ),
    );
  }
}
