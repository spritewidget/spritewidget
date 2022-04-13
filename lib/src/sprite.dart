// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

/// A Sprite is a [Node] that renders a bitmap image to the screen.
class Sprite extends NodeWithSize with SpritePaint {
  /// The texture that the sprite will render to screen.
  ///
  /// If the texture is null, the sprite will be rendered as a red square
  /// marking the bounds of the sprite.
  ///
  ///     mySprite.texture = myTexture;
  SpriteTexture texture;

  /// If true, constrains the proportions of the image by scaling it down, if
  /// its proportions doesn't match the [size].
  ///
  ///     mySprite.constrainProportions = true;
  bool constrainProportions = false;

  final Paint _cachedPaint = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;

  /// Creates a new sprite from the provided [texture].
  ///
  ///     var mySprite = new Sprite(myTexture)
  Sprite({required this.texture}) : super(Size.zero) {
    size = texture.size;
    pivot = texture.pivot;
  }

  /// Creates a new sprite from the provided [image].
  ///
  /// var mySprite = new Sprite.fromImage(myImage);
  Sprite.fromImage(ui.Image image)
      : texture = SpriteTexture(image),
        super(Size.zero) {
    size = texture.size;
    pivot = const Offset(0.5, 0.5);
  }

  @override
  void paint(Canvas canvas) {
    // Account for pivot point
    applyTransformForPivot(canvas);

    double w = texture.size.width;
    double h = texture.size.height;

    if (w <= 0 || h <= 0) return;

    double scaleX = size.width / w;
    double scaleY = size.height / h;

    if (constrainProportions) {
      // Constrain proportions, using the smallest scale and by centering the
      // image
      if (scaleX < scaleY) {
        canvas.translate(0.0, (size.height - scaleX * h) / 2.0);
        scaleY = scaleX;
      } else {
        canvas.translate((size.width - scaleY * w) / 2.0, 0.0);
        scaleX = scaleY;
      }
    }

    canvas.scale(scaleX, scaleY);

    // Setup paint object for opacity and transfer mode
    _updatePaint(_cachedPaint);

    // Do actual drawing of the sprite
    texture.drawTexture(canvas, Offset.zero, _cachedPaint);

    // Debug drawing
//      canvas.drawRect(Offset.zero & texture.size, new Paint()..color=const Color(0x33ff0000));
  }
}

/// Defines properties, such as [opacity] and [transferMode] that are shared
/// between [Node]s that render textures to screen.
abstract class SpritePaint {
  double _opacity = 1.0;

  /// The opacity of the sprite in the range 0.0 to 1.0.
  ///
  ///     mySprite.opacity = 0.5;
  double get opacity => _opacity;

  set opacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    _opacity = opacity;
  }

  /// The color to draw on top of the sprite, null if no color overlay is used.
  ///
  ///     // Color the sprite red
  ///     mySprite.colorOverlay = new Color(0x77ff0000);
  Color? colorOverlay;

  /// The transfer mode used when drawing the sprite to screen.
  ///
  ///     // Add the colors of the sprite with the colors of the background
  ///     mySprite.transferMode = TransferMode.plusMode;
  BlendMode? transferMode;

  void _updatePaint(Paint paint) {
    paint.color = Color.fromARGB((255.0 * _opacity).toInt(), 255, 255, 255);

    if (colorOverlay != null) {
      paint.colorFilter = ColorFilter.mode(colorOverlay!, BlendMode.srcATop);
    }

    if (transferMode != null) {
      paint.blendMode = transferMode!;
    }
  }
}
