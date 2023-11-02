import 'dart:async';
import 'dart:developer';

import 'package:socket_io/socket_io.dart';

import 'models/latlng.dart';

//Final
// void main(List<String> args) {
//   var io = Server();
//   io.on('connection', (client) {
//     print('Client connected $client');

//     client.join('deliveryRoom');

//     client.on('updateLocationDelivery', (data) {
//       log(data);

//       final location = Latlng.fromJson(data);

//       io.to('deliveryRoom').emit('updateLocationUser', location.toJson());
//     });
//   });
//   io.listen(3000);
// }

//User Test
void main(List<String> args) {
  var io = Server();
  late Latlng location /* = Latlng(lat: -24.781477, lng: -65.407442) */;
  io.on('connection', (client) {
    print('Client connected $client');

    io.on('setInitialPosition', (data) {
      location = Latlng.fromJson(data);
    });

    client.join('deliveryRoom');

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      location.lat = location.lat! - 0.000150;
      location.lng = location.lng! - 0.0000165;
      io.to('deliveryRoom').emit('updateLocationUser', location.toJson());
    });

    // client.on('updateLocationDelivery', (data) {
    //   log(data);

    //   final location = Latlng.fromJson(data);

    //   io.to('deliveryRoom').emit('updateLocationUser', location.toJson());
    // });
  });
  io.listen(3000);
}
