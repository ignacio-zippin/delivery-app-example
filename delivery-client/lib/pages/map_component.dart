import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_yama_plugins/pages/example_k_values.dart';
import 'package:flutter_yama_plugins/pages/loading_component.dart';
import 'package:flutter_yama_plugins/pages/location_manager.dart';
import 'package:flutter_yama_plugins/pages/permission_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:s_sockets/s_sockets.dart';
// import 'package:flutter_yama_plugins/pages/permission_manager.dart';

// ignore: must_be_immutable
class TrackingMapComponent extends StatefulWidget {
  final Function(LatLng? currentPosition)? getPosition; // Para repartidor
  final bool isLoading;
  LatLng? initialCenter;
  LatLng? packagePosition;
  double nearDistanceInKm;
  Widget? myPosition;
  Function()? onTrackingStart;
  Function()? onTrackingGetPackage;
  Function()? onTrackingNear;
  Function()? onTrackingArrive;

  TrackingMapComponent({
    this.getPosition,
    this.isLoading = false,
    this.initialCenter,
    this.packagePosition,
    this.nearDistanceInKm = 0.1,
    this.myPosition,
    this.onTrackingStart,
    this.onTrackingGetPackage,
    this.onTrackingNear,
    this.onTrackingArrive,
    Key? key,
  }) : super(key: key);

  @override
  State<TrackingMapComponent> createState() => _TrackingMapComponentState();
}

class _TrackingMapComponentState extends State<TrackingMapComponent> {
  bool loadingPosition = false;
  StreamSubscription<Position>? positionStream;
  late MapController mapController;
  LocationSettings locationSettings = const LocationSettings(
    // accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  LatLng currentPosition = kOther;
  LatLng redPosition = kOther;
  double totalDistance = 0;
  bool isNear = false;
  bool hasPackage = false;

  @override
  void initState() {
    loadingPosition = widget.isLoading;
    mapController = MapController();
    locationInit();
    initTracking();
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    loadingPosition = widget.isLoading;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  initTracking() {
    // widget.onTrackingStart?.call();
    debugPrint("Comenzó tracking");
    // getLocationStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  _getCenterPoint(widget.packagePosition, currentPosition),
              initialZoom: 16.4,
              interactionOptions: const InteractionOptions(
                enableScrollWheel: false,
              ),
              keepAlive: true,
              maxZoom: 25,
              minZoom: 10,
              onTap: (_, __) {
                debugPrint("Tap on Map");
              },
              onPositionChanged: (MapPosition map, bool b) {
                widget.getPosition ?? (currentPosition);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: kMapTemplate,
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.flutter_yama_plugins',
                // errorImage: Placeholder de error de carga template,
              ),
              PolygonLayer(
                polygonCulling: false,
                polygons: [
                  Polygon(
                    points: kPolilinePoints,
                    color: const Color(0xFF26387A).withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: const Color(0xFF26387A),
                    isFilled: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.packagePosition ?? kDefault,
                    width: 30,
                    height: 30,
                    child: ClipRRect(
                      borderRadius: BorderRadiusDirectional.circular(1000),
                      child: Image.asset(kSiltiumIcon),
                    ),
                  ),
                  Marker(
                    point: currentPosition,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadiusDirectional.circular(1000),
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Marker(
                    point: kUser,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadiusDirectional.circular(1000),
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(1000),
                border: Border.all(color: Colors.black),
              ),
              child: widget.myPosition ??
                  IconButton(
                    icon: const Icon(Icons.gps_fixed_sharp),
                    onPressed: () async {
                      await getCurrentLocationButtonMap();
                      mapController.move(
                        currentPosition,
                        16.4,
                      );
                    },
                    iconSize: 40,
                    color: Colors.black,
                  ),
            ),
          ),
          loadingComponent(
            loadingPosition,
          ),
        ],
      ),
    );
  }

  // Funciones

  LatLng _getCenterPoint(LatLng? point1, LatLng? point2) {
    if (point1 != null && point2 != null) {
      LatLngBounds bounds = LatLngBounds(point1, point2);
      return bounds.center;
    } else {
      return const LatLng(-24.789239, -65.410283);
    }
  }

  Future<void> getCurrentLocationButtonMap() async {
    setState(() {
      loadingPosition = true;
    });
    LatLng? location = await LocationManager().getCurrentLocation();
    if (location != null) {
      String lat = NumberFormat("###.000000").format(location.latitude);
      String long = NumberFormat("###.000000").format(location.longitude);
      currentPosition = LatLng(double.parse(lat), double.parse(long));
      widget.initialCenter =
          _getCenterPoint(widget.packagePosition, currentPosition);
      getPosition();
    }
    setState(() {
      loadingPosition = false;
    });
  }

  //* Para repartidor: stream/suscripcion a los cambios de posicion
  void getPosition() async {
    bool response = await PermissionManager().getLocationServiceStatus();
    if (response) {
      positionStream = getLocationStreamPackageLocation();

      // Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      //   (Position? position) {
      //     if (position != null) {
      //       setState(
      //         () {
      //           currentPosition = LatLng(position.latitude, position.longitude);
      //           widget.initialCenter =
      //               _getCenterPoint(widget.packagePosition, currentPosition);
      //         },
      //       );
      //       // Preguntas del usuario
      //       _hasPackage();
      //       _distance();
      //       //TODO: LLamada a Socket
      //       SSockets().emit(
      //         'updateLocationDelivery',
      //         '{"lat": ${currentPosition.latitude}, "lng": ${currentPosition.longitude}}',
      //       );
      //     }
      //   },
      //   onError: (e) {
      //     positionStream?.cancel();
      //   },
      // );
    }
  }

  getLocationStream() {
    //! Simulacion de tracking
    Timer.periodic(const Duration(milliseconds: 2), (timer) {
      _simulation(timer);
      _hasPackage();
      _distance();
    });
    //!
  }

  _hasPackage() {
    double redLat = double.parse(currentPosition.latitude.toStringAsFixed(6));
    if (widget.packagePosition != null &&
        redLat <= widget.packagePosition!.latitude &&
        !hasPackage) {
      hasPackage = true;
      debugPrint("Tracking tiene el pedido");
      widget.onTrackingGetPackage?.call();
    }
  }

  // CALCULAR DISTANCIA
  _distance() {
    totalDistance = calculateDistance(
      // redPosition.latitude,
      // redPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
      kUser.latitude,
      kUser.longitude,
    );
    if (totalDistance <= widget.nearDistanceInKm && !isNear) {
      isNear = true;
      // widget.onTrackingNear?.call();
      debugPrint("${totalDistance.toString()} Km.");
      debugPrint("Tracking esta cerca");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    //* Se obtiene la constante de conversion de grados a radianes
    //* 1 degree (deg) = 0.017453292519943295 radians (rad)
    // var rad = 0.017453292519943295;
    //* OR rad = deg * (π/180)
    double rad = pi / 180;

    //* Con el valor anterior, se convierte LatLng (en decimal) a Radianes y se obtiene la distancia entre dos puntos
    double a = 0.5 -
        cos((lat2 - lat1) * rad) / 2 +
        cos(lat1 * rad) * cos(lat2 * rad) * (1 - cos((lon2 - lon1) * rad)) / 2;

    // Resultado segun la curvatura de la Tierra
    return 12742 * asin(sqrt(a));
    // 2 * (6371) -> Radius of the earth in km * 2 = 12742, asin = arc sin(arco seno) & sqrt = raiz cuadrada
  }

  // SIMULACION TRACKING
  _simulation(Timer timer) {
    //! Hay que tener cuidado con los valores de LatLng que se reciben, que tengan cierto limite,
    //! sino nunca va a ser igual uno con otro y nunca se van a detener o mostrar el mensaje.
    //! Redondeo
    double redLat = double.parse(redPosition.latitude.toStringAsFixed(6));
    double redLong = double.parse(redPosition.longitude.toStringAsFixed(6));
    redPosition = LatLng(redLat, redLong);

    if (redPosition.latitude > currentPosition.latitude) {
      if (redPosition.longitude > currentPosition.longitude) {
        _subtractLatitude();
        _subtractLongitude();
      } else if (redPosition.longitude < currentPosition.longitude) {
        _subtractLatitude();
        _addLongitude();
      } else {
        _subtractLatitude();
      }
    } else if (redPosition.latitude < currentPosition.latitude) {
      if (redPosition.longitude > currentPosition.longitude) {
        _addLatitude();
        _subtractLongitude();
      } else if (redPosition.longitude < currentPosition.longitude) {
        _addLatitude();
        _addLongitude();
      } else {
        _addLatitude();
      }
    } else {
      if (redPosition.longitude > currentPosition.longitude) {
        _subtractLongitude();
      } else if (redPosition.longitude < currentPosition.longitude) {
        _addLongitude();
      } else {
        // widget.onTrackingArrive?.call();
        debugPrint("Tracking llegó");
        timer.cancel();
      }
    }
  }

  double add = 0.000001;

  _addLatitude() {
    setState(() {
      redPosition = LatLng(
        redPosition.latitude + add,
        redPosition.longitude,
      );
    });
  }

  _subtractLatitude() {
    setState(() {
      redPosition = LatLng(
        redPosition.latitude - add,
        redPosition.longitude,
      );
    });
  }

  _addLongitude() {
    setState(() {
      redPosition = LatLng(
        redPosition.latitude,
        redPosition.longitude + add,
      );
    });
  }

  _subtractLongitude() {
    setState(() {
      redPosition = LatLng(
        redPosition.latitude,
        redPosition.longitude - add,
      );
    });
  }

// LOCATION PACKAGE
//Alternativa a Geolocator

  Location location = Location();

  locationInit() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    // ignore: unused_local_variable
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
  }

  getLocationStreamPackageLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
        SSockets().emit(
          'updateLocationDelivery',
          '{"lat": ${currentLocation.latitude}, "lng": ${currentLocation.longitude}}',
        );
      }
    });
  }
}
