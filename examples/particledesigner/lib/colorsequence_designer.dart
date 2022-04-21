// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:spritewidget/spritewidget.dart';

class ColorSequenceWell extends StatelessWidget {
  final ColorSequence colorSequence;
  final VoidCallback onTap;

  static const String _baseEncodedImage =
      'iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAIAAADZF8uwAAAAGUlEQVQYV2M4gwH+YwCGIasIUwhT25BVBADtzYNYrHvv4gAAAABJRU5ErkJggg==';
  final Uint8List _chessTexture = base64.decode(_baseEncodedImage);

  ColorSequenceWell({
    required this.colorSequence,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LinearGradient gradient = LinearGradient(
      colors: colorSequence.colors,
      stops: colorSequence.stops,
    );

    return SizedBox(
      height: 30.0,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
              decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(_chessTexture),
              repeat: ImageRepeat.repeat,
            ),
          )),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

typedef ColorSequenceDesignerCallback = void Function(ColorSequence value);

class ColorSequenceDesigner extends StatefulWidget {
  final ColorSequence colorSequence;
  final ColorSequenceDesignerCallback onChanged;

  const ColorSequenceDesigner({
    required this.colorSequence,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ColorSequenceDesignerState createState() => _ColorSequenceDesignerState();
}

class _ColorSequenceDesignerState extends State<ColorSequenceDesigner> {
  static const int _numMaxStops = 4;

  late ColorSequence _colorSequence;

  final List<Color?> _colors = <Color?>[];
  final List<double?> _stops = <double?>[];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < _numMaxStops; i++) {
      _colors.add(null);
      _stops.add(null);
    }

    int numColors = widget.colorSequence.colors.length;
    for (int i = 0; i < numColors; i++) {
      _colors[i] = widget.colorSequence.colors[i];
      _stops[i] = widget.colorSequence.stops[i];
    }

    _updateColorSequence();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];

    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ColorSequenceWell(
          colorSequence: _colorSequence,
          onTap: () {},
        ),
      ),
    );

    for (int i = 0; i < _numMaxStops; i++) {
      int stopNum = i;

      children.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Checkbox(
              value: _colors[stopNum] != null,
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    _addColorStop(stopNum);
                  } else {
                    _removeColorStop(stopNum);
                  }
                });
              },
            ),
            Expanded(
              child: Slider(
                value: _stops[stopNum] ?? 0.0,
                onChanged: (double value) {
                  setState(() {
                    _updateStop(stopNum, value);
                  });
                },
                max: _stops[stopNum] != null ? 1.0 : 0.0,
              ),
            ),
            Container(
              width: 50.0,
              height: 30.0,
              color: _colors[stopNum] ?? Colors.grey,
              child: GestureDetector(
                onTap: () {
                  _pickColor(stopNum);
                },
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  void _updateStop(int stop, double value) {
    for (int i = 0; i < stop; i++) {
      if (_stops[i] != null && _stops[i]! > value) _stops[i] = value;
    }

    _stops[stop] = value;

    for (int i = stop + 1; i < _numMaxStops; i++) {
      if (_stops[i] != null && _stops[i]! < value) _stops[i] = value;
    }

    _updateColorSequence();
  }

  void _addColorStop(int stopNum) {
    int firstStop = _numMaxStops - 1;
    int lastStop = 0;
    for (int i = 0; i < _numMaxStops; i++) {
      if (_colors[i] != null && i < firstStop) firstStop = i;
      if (_colors[i] != null && i > lastStop) lastStop = i;
    }

    if (stopNum < firstStop) {
      _stops[stopNum] = 0.0;
    } else if (stopNum > lastStop) {
      _stops[stopNum] = 1.0;
    } else {
      int prevStop = 0;
      for (int i = stopNum - 1; i >= 0; i--) {
        if (_stops[i] != null) {
          prevStop = i;
          break;
        }
      }

      int nextStop = _numMaxStops - 1;
      for (int i = stopNum + 1; i < _numMaxStops; i++) {
        if (_stops[i] != null) {
          nextStop = i;
          break;
        }
      }
      _stops[stopNum] = (_stops[prevStop]! + _stops[nextStop]!) / 2.0;
    }

    _colors[stopNum] = Colors.black;

    _updateColorSequence();
  }

  void _removeColorStop(int stopNum) {
    int numStops = 0;
    for (int i = 0; i < _numMaxStops; i++) {
      if (_stops[i] != null) numStops += 1;
    }

    if (numStops <= 1) return;

    _stops[stopNum] = null;
    _colors[stopNum] = null;

    _updateColorSequence();
  }

  void _pickColor(int stopNum) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Color stop'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _colors[stopNum]!,
              onColorChanged: (Color c) {
                setState(() {
                  _colors[stopNum] = c;
                  _updateColorSequence();
                });
              },
              // enableLabel: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('DONE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _updateColorSequence();
  }

  void _updateColorSequence() {
    List<Color> colors = <Color>[];
    List<double> stops = <double>[];

    for (int i = 0; i < _numMaxStops; i++) {
      if (_colors[i] != null) {
        colors.add(_colors[i]!);
        stops.add(_stops[i]!);
      }
    }

    _colorSequence = ColorSequence(colors: colors, stops: stops);

    return widget.onChanged(_colorSequence);
  }
}
