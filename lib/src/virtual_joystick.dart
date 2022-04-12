// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

/// Provides a virtual joystick that can easily be added to your sprite scene.
class VirtualJoystick extends NodeWithSize {
  /// Creates a new virtual joystick.
  VirtualJoystick() : super(new Size(160.0, 160.0)) {
    userInteractionEnabled = true;
    handleMultiplePointers = false;
    position = new Offset(160.0, -20.0);
    pivot = new Offset(0.5, 1.0);
    _center = new Offset(size.width / 2.0, size.height / 2.0);
    _handlePos = _center;

    _paintHandle = new Paint()..color = new Color(0xffffffff);
    _paintControl = new Paint()
      ..color = new Color(0xffffffff)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
  }

  /// Reads the current value of the joystick. A point with from (-1.0, -1.0)
  /// to (1.0, 1.0). If the joystick isn't moved it will return (0.0, 0.0).
  Offset get value => _value;
  Offset _value = Offset.zero;

  /// True if the user is currently touching the joystick.
  bool get isDown => _isDown;
  bool _isDown = false;

  Offset? _pointerDownAt;
  Offset? _center;
  Offset? _handlePos;

  late Paint _paintHandle;
  late Paint _paintControl;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent) {
      _pointerDownAt = event.boxPosition;
      motions!.stopAll();
      _isDown = true;
    } else if (event.type == PointerUpEvent ||
        event.type == PointerCancelEvent) {
      _pointerDownAt = null;
      _value = Offset.zero;
      MotionTween moveToCenter = new MotionTween((a) {
        _handlePos = a;
      }, _handlePos, _center, 0.4, Curves.elasticOut);
      motions!.run(moveToCenter);
      _isDown = false;
    } else if (event.type == PointerMoveEvent) {
      Offset movedDist = event.boxPosition - _pointerDownAt!;

      _value = new Offset((movedDist.dx / 80.0).clamp(-1.0, 1.0),
          (movedDist.dy / 80.0).clamp(-1.0, 1.0));

      _handlePos = _center! + new Offset(_value.dx * 40.0, _value.dy * 40.0);
    }
    return true;
  }

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);
    canvas.drawCircle(_handlePos!, 25.0, _paintHandle);
    canvas.drawCircle(_center!, 40.0, _paintControl);
  }
}
