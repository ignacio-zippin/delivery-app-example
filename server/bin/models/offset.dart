import 'dart:convert';

class LatLong {
  final double? lat;
  final double? long;

  LatLong({
    this.lat,
    this.long,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
    };
  }

  factory LatLong.fromMap(Map<String, dynamic> map) {
    return LatLong(
      lat: map['lat'],
      long: map['long'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LatLong.fromJson(String source) =>
      LatLong.fromMap(json.decode(source));
}
