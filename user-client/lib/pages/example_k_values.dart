import 'package:latlong2/latlong.dart';

// k_values
// Plaza LatLng
LatLng kDefault = const LatLng(-24.789239, -65.410283);

LatLng kDefaultInitPoint = const LatLng(-24.787569, -65.408084);
LatLng kSiltium = const LatLng(-24.784349, -65.407748);
LatLng kOther = const LatLng(-24.781477, -65.407442);

List<LatLng> kPolilinePoints = [
  const LatLng(-24.783938, -65.407677),
  const LatLng(-24.784007, -65.406451),
  const LatLng(-24.785293, -65.406565),
  const LatLng(-24.785187, -65.407807),
  const LatLng(-24.783938, -65.407677),
];

//Default map template
const kMapTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const kMapTemplate2 =
    "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png";
String kMapTemplate3 =
    "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png";

// k_icons

const String kSiltiumIcon = 'images/siltium.png';
