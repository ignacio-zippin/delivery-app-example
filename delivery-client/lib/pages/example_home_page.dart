import 'package:flutter/material.dart';
import 'package:flutter_yama_plugins/pages/map_component.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'example_k_values.dart';

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  String buttonText = "Comenzó el Tracking";
  bool isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.black,
          title: const Text("Maps Plugin Test"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'MAPS PLUGIN TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TrackingMapComponent(
                    initialCenter: kDefaultInitPoint,
                    packagePosition: kSiltium,
                    nearDistanceInKm: 0.25,
                    onTrackingStart: _onTrackingStart,
                    onTrackingGetPackage: _onTrackingGetPackage,
                    onTrackingNear: _onTrackingNear,
                    onTrackingArrive: _onTrackingArrive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onTrackingStart() {
    Fluttertoast.showToast(msg: "El repartidor ya está en camino!");
  }

  _onTrackingGetPackage() {
    Fluttertoast.showToast(msg: "El repartidor ya retiró tu paquete!");
    setState(() {
      buttonText = "Tracking tiene el paquete";
    });
  }

  _onTrackingNear() {
    Fluttertoast.showToast(msg: "El repartidor está cerca!");
    setState(() {
      buttonText = "Tracking esta cerca";
    });
  }

  _onTrackingArrive() {
    Fluttertoast.showToast(msg: "El repartidor ya llegó con tu paquete!");
    setState(() {
      buttonText = "Tracking llegó";
    });
  }
}
