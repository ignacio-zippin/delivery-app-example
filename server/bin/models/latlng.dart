import 'dart:convert';

class Latlng {
  double? lat;
  double? lng;

  Latlng({
    this.lat,
    this.lng,
  });

  setLatitude(double lat) {
    this.lat = lat;
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory Latlng.fromMap(Map<String, dynamic> map) {
    return Latlng(
      lat: map['lat'],
      lng: map['lng'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Latlng.fromJson(String source) => Latlng.fromMap(json.decode(source));
}
