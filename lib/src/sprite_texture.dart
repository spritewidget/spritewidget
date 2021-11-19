// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

/// A texture represents a rectangular area of an image and is typically used to draw a sprite to the screen.
///
/// Normally you get a reference to a texture from a [SpriteSheet], but you can also create one from an [Image].
class SpriteTexture {

  /// Creates a new texture from an [Image] object.
  ///
  ///     var myTexture = new Texture(myImage);
  SpriteTexture(ui.Image image) :
    size = new Size(image.width.toDouble(), image.height.toDouble()),
    image = image,
    trimmed = false,
    rotated = false,
    frame = new Rect.fromLTRB(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
    spriteSourceSize = new Rect.fromLTRB(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
    pivot = new Offset(0.5, 0.5);


  SpriteTexture._fromSpriteFrame(this.image, this.name, this.size, this.rotated, this.trimmed, this.frame,
                           this.spriteSourceSize, this.pivot);

  /// The image that this texture is a part of.
  ///
  ///     var textureImage = myTexture.image;
  final ui.Image image;

  /// The logical size of the texture, before being trimmed by the texture packer.
  ///
  ///     var textureSize = myTexture.size;
  final Size size;

  /// The name of the image acts as a tag when acquiring a reference to it.
  ///
  ///     myTexture.name = "new_texture_name";
  String? name;

  /// The texture was rotated 90 degrees when being packed into a sprite sheet.
  ///
  ///     if (myTexture.rotated) drawRotated();
  final bool rotated;

  /// The texture was trimmed when being packed into a sprite sheet.
  ///
  ///     bool trimmed = myTexture.trimmed
  final bool trimmed;

  /// The frame of the trimmed texture inside the image.
  ///
  ///     Rect frame = myTexture.frame;
  final Rect frame;

  /// The offset and size of the trimmed texture inside the image.
  ///
  /// Position represents the offset from the logical [size], the size of the rect represents the size of the trimmed
  /// texture.
  ///
  ///     Rect spriteSourceSize = myTexture.spriteSourceSize;
  final Rect spriteSourceSize;

  /// The default pivot point for this texture. When creating a [Sprite] from the texture, this is the pivot point that
  /// will be used.
  ///
  ///     myTexture.pivot = new Point(0.5, 0.5);
  Offset pivot;

  /// Creates a new Texture from a part of the current texture.
  SpriteTexture textureFromRect(Rect rect, [String? name]) {
    assert(!rotated);
    Rect srcFrame = new Rect.fromLTWH(rect.left + frame.left, rect.top + frame.top, rect.size.width, rect.size.height);
    Rect dstFrame = new Rect.fromLTWH(0.0, 0.0, rect.size.width, rect.size.height);
    return new SpriteTexture._fromSpriteFrame(image, name, rect.size, false, false, srcFrame, dstFrame, new Offset(0.5, 0.5));
  }

  /// Draws the texture to a [Canvas] at a specified [position] and with the
  /// specified [paint].
  void drawTexture(Canvas canvas, Offset position, Paint paint) {
    // Get drawing position
    double x = position.dx;
    double y = position.dy;

    // Draw the texture
    if (rotated) {
      // Account for position
      bool translate = (x != 0 || y != 0);
      if (translate) {
        canvas.translate(x, y);
      }

      // Calculate the rotated frame and spriteSourceSize
      Size originalFrameSize = frame.size;
      Rect rotatedFrame = frame.topLeft & new Size(originalFrameSize.height, originalFrameSize.width);
      Offset rotatedSpriteSourcePoint = new Offset(
          -spriteSourceSize.top - (spriteSourceSize.bottom - spriteSourceSize.top),
          spriteSourceSize.left);
      Rect rotatedSpriteSourceSize = rotatedSpriteSourcePoint & new Size(originalFrameSize.height, originalFrameSize.width);

      // Draw the rotated sprite
      canvas.rotate(-math.pi/2.0);
      canvas.drawImageRect(image, rotatedFrame, rotatedSpriteSourceSize, paint);
      canvas.rotate(math.pi/2.0);

      // Translate back
      if (translate) {
        canvas.translate(-x, -y);
      }
    } else {
      // Draw the sprite
      Rect dstRect = new Rect.fromLTWH(x + spriteSourceSize.left, y + spriteSourceSize.top, spriteSourceSize.width, spriteSourceSize.height);
      canvas.drawImageRect(image, frame, dstRect, paint);
    }
  }
}
