import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_yama_plugins/pages/example_k_values.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationManager {
  static final LocationManager _instance = LocationManager._constructor();

  factory LocationManager() {
    return _instance;
  }

  LocationManager._constructor();

  Geolocator location = Geolocator();

  LatLng? currentLocation;

  Future<LatLng?> getCurrentLocation() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return kDefault;
    }

    LocationPermission permission = await checkPermission();
    switch (permission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        try {
          Position position = await Geolocator.getCurrentPosition();
          currentLocation = LatLng(position.latitude, position.longitude);
          return currentLocation;
        } catch (e) {
          return null;
        }
      case LocationPermission.denied:
        openAppSettings();
        return null;
      case LocationPermission.deniedForever:
        openAppSettings();
        return null;
      default:
        Fluttertoast.showToast(
          msg: "Error location manager",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
    }
  }

  Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }
}
