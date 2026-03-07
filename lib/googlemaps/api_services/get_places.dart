class GetPlaces {
  List<Prediction>? predictions;
  String? status;

  GetPlaces({this.predictions, this.status});

  GetPlaces.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = <Prediction>[];
      json['predictions'].forEach((v) {
        predictions!.add(Prediction.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (predictions != null) {
      data['predictions'] = predictions!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Prediction {
  String? description;
  String? placeId;
  StructuredFormatting? structuredFormatting;

  Prediction({this.description, this.placeId, this.structuredFormatting});

  Prediction.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
    structuredFormatting = json['structured_formatting'] != null
        ? StructuredFormatting.fromJson(json['structured_formatting'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['description'] = description;
    data['place_id'] = placeId;
    if (structuredFormatting != null) {
      data['structured_formatting'] = structuredFormatting!.toJson();
    }
    return data;
  }
}

class StructuredFormatting {
  String? mainText;
  String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    secondaryText = json['secondary_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['main_text'] = mainText;
    data['secondary_text'] = secondaryText;
    return data;
  }
}