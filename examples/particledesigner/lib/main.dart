// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

import 'particle_designer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Particle Designer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImageMap _images;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    _images = ImageMap(rootBundle);
    _images.load([
      'assets/particle-0.png',
      'assets/particle-1.png',
      'assets/particle-2.png',
      'assets/particle-3.png',
      'assets/particle-4.png',
      'assets/particle-5.png',
    ]).then((List<ui.Image> images) {
      setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loaded
          ? ParticleDesigner(
              images: _images,
            )
          : null,
    );
  }
}
