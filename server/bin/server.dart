import 'dart:developer';

import 'package:socket_io/socket_io.dart';

import 'models/latlng.dart';

void main(List<String> args) {
  var io = Server();
  io.on('connection', (client) {
    print('Client connected $client');

    client.join('deliveryRoom');

    client.on('updateLocationDelivery', (data) {
      log(data);

      final location = Latlng.fromJson(data);

      io.to('deliveryRoom').emit('updateLocationUser', location.toJson());
    });
  });
  io.listen(3000);
}
