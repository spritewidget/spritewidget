// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A sprite toolkit built on top of Flutter.
library spritewidget;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui show Image, Vertices;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

part 'src/color_sequence.dart';
part 'src/constraint.dart';
part 'src/effect_line.dart';
part 'src/image_map.dart';
part 'src/label.dart';
part 'src/layer.dart';
part 'src/motion.dart';
part 'src/motion_spline.dart';
part 'src/nine_slice_sprite.dart';
part 'src/node.dart';
part 'src/node3d.dart';
part 'src/node_with_size.dart';
part 'src/particle_system.dart';
part 'src/sprite.dart';
part 'src/sprite_box.dart';
part 'src/sprite_texture.dart';
part 'src/sprite_widget.dart';
part 'src/spritesheet.dart';
part 'src/textured_line.dart';
part 'src/util.dart';
part 'src/virtual_joystick.dart';
part 'src/lib_gdx_frame.dart';
part 'src/lib_gdx_loader.dart';