import 'package:flutter/material.dart';
import 'weather_demo.dart';

// Create a new MaterialApp with the WeatherDemo as its main Widget.
void main() => runApp(new WeatherDemoApp());

class WeatherDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Weather Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new WeatherDemo(),
    );
  }
}
