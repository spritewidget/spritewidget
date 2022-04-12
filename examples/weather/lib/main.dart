// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
