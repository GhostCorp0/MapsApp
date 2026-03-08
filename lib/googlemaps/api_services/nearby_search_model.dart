class NearbySearchModel {
  List<PlaceResult>? results;
  String? status;

  NearbySearchModel({this.results, this.status});

  NearbySearchModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <PlaceResult>[];
      json['results'].forEach((v) {
        results!.add(PlaceResult.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class PlaceResult {
  String? name;
  String? placeId;
  String? vicinity;
  Geometry? geometry;

  PlaceResult({this.name, this.placeId, this.vicinity, this.geometry});

  PlaceResult.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    placeId = json['place_id'];
    vicinity = json['vicinity'];
    geometry = json['geometry'] != null
        ? Geometry.fromJson(json['geometry'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = name;
    data['place_id'] = placeId;
    data['vicinity'] = vicinity;
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    return data;
  }
}

class Geometry {
  Location? location;

  Geometry({this.location});

  Geometry.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toDouble();
    lng = json['lng']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}