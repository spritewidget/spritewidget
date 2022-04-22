// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const double _kWeatherButtonSize = 56.0;
const double _kWeatherIconSize = 36.0;

// The WeatherButton is a round material design styled button with an
// image asset as its icon.
class WeatherButton extends StatelessWidget {
  const WeatherButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Color color;
    if (selected) {
      color = Theme.of(context).primaryColor;
    } else {
      color = const Color(0x33000000);
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Material(
        color: color,
        type: MaterialType.circle,
        elevation: 0.0,
        child: SizedBox(
          width: _kWeatherButtonSize,
          height: _kWeatherButtonSize,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Image.asset(icon,
                  width: _kWeatherIconSize, height: _kWeatherIconSize),
            ),
          ),
        ),
      ),
    );
  }
}
