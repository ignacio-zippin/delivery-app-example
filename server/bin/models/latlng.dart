import 'dart:convert';

class Latlng {
  final double? lat;
  final double? lng;

  Latlng({
    this.lat,
    this.lng,
  });

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
