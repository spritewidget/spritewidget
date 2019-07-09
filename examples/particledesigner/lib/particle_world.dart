import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class ParticleWorld extends NodeWithSize {
  ParticleSystem particleSystem;

  final ImageMap images;

  int _selectedTexture = 5;

  int get selectedTexture => _selectedTexture;

  set selectedTexture(int texture) {
    particleSystem.texture = new SpriteTexture(images['assets/particle-$texture.png']);
    _selectedTexture = texture;
  }


  ParticleWorld({this.images}) : super(const Size(1024.0, 1024.0)) {
    userInteractionEnabled = true;

    SpriteTexture texture = new SpriteTexture(images['assets/particle-$_selectedTexture.png']);

    particleSystem = new ParticleSystem(
      texture,
      autoRemoveOnFinish: false,
    );
    particleSystem.position = const Offset(512.0, 512.0);
    particleSystem.insertionOffset = Offset.zero;
    addChild(particleSystem);
  }

  @override bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent || event.type == PointerMoveEvent) {
      particleSystem.insertionOffset = convertPointToNodeSpace(event.boxPosition) - const Offset(512.0, 512.0);
    }

    if (event.type == PointerDownEvent) {
      particleSystem.reset();
    }

    return true;
  }
}