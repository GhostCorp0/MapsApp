class PlacesFromCoordinates {
  final List<Result>? results;
  final String? status;

  PlacesFromCoordinates({
    this.results,
    this.status,
  });

  factory PlacesFromCoordinates.fromJson(Map<String, dynamic> json) {
    return PlacesFromCoordinates(
      results: json['results'] != null
          ? (json['results'] as List)
          .map((e) => Result.fromJson(e))
          .toList()
          : [],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results?.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }
}

class Result {
  final String? formattedAddress;
  final String? placeId;
  final Geometry? geometry;

  Result({
    this.formattedAddress,
    this.placeId,
    this.geometry,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      formattedAddress: json['formatted_address'],
      placeId: json['place_id'],
      geometry:
      json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      'place_id': placeId,
      'geometry': geometry?.toJson(),
    };
  }
}

class Geometry {
  final Location? location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location:
      json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
    };
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}