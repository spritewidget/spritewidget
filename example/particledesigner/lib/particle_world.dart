// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class ParticleWorld extends NodeWithSize {
  late ParticleSystem particleSystem;

  final ImageMap images;

  int _selectedTexture = 5;

  int get selectedTexture => _selectedTexture;

  set selectedTexture(int texture) {
    particleSystem.texture =
        SpriteTexture(images['assets/particle-$texture.png']!);
    _selectedTexture = texture;
  }

  ParticleWorld({required this.images}) : super(const Size(1024.0, 1024.0)) {
    userInteractionEnabled = true;

    SpriteTexture texture =
        SpriteTexture(images['assets/particle-$_selectedTexture.png']!);

    particleSystem = ParticleSystem(
      texture: texture,
      autoRemoveOnFinish: false,
    );
    particleSystem.position = const Offset(512.0, 512.0);
    particleSystem.insertionOffset = Offset.zero;
    addChild(particleSystem);
  }

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerEventType.down ||
        event.type == PointerEventType.move) {
      particleSystem.insertionOffset =
          convertPointToNodeSpace(event.boxPosition) -
              const Offset(512.0, 512.0);
    }

    if (event.type == PointerEventType.down) {
      particleSystem.reset();
    }

    return true;
  }
}
