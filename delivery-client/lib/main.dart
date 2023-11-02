import 'package:flutter/material.dart';
import 'package:flutter_yama_plugins/pages/example_home_page.dart';
import 'package:s_sockets/s_sockets.dart';

void main() {
  SSockets().init('http://localhost:3000');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   useMaterial3: true,
      // ),
      //
      // theme: ThemeData.dark(
      //   useMaterial3: true,
      // ),
      //
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // home: const MyHomePage(),
      home: const ExampleHomePage(),
    );
  }
}
