// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

enum _KeyDirection {
  left,
  right,
  up,
  down,
}

/// Provides a virtual joystick that can easily be added to your sprite scene.
class VirtualJoystick extends NodeWithSize {
  /// Creates a new virtual joystick.
  VirtualJoystick() : super(const Size(160.0, 160.0)) {
    userInteractionEnabled = true;
    handleMultiplePointers = false;
    position = const Offset(160.0, -20.0);
    pivot = const Offset(0.5, 1.0);
    _center = Offset(size.width / 2.0, size.height / 2.0);
    _handlePos = _center;

    _paintHandle = Paint()..color = const Color(0xffffffff);
    _paintControl = Paint()
      ..color = const Color(0xffffffff)
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

  final _pressedKeys = <_KeyDirection, bool>{
    _KeyDirection.up: false,
    _KeyDirection.down: false,
    _KeyDirection.left: false,
    _KeyDirection.right: false,
  };

  bool get arrowUp => _pressedKeys[_KeyDirection.up]!;

  bool get arrowDown => _pressedKeys[_KeyDirection.down]!;

  bool get arrowLeft => _pressedKeys[_KeyDirection.left]!;

  bool get arrowRight => _pressedKeys[_KeyDirection.right]!;

  bool get arrowKeyPressed => arrowUp || arrowDown || arrowLeft || arrowRight;

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (arrowKeyPressed) {
      return true;
    }

    if (event.type == PointerEventType.down) {
      _pointerDownAt = event.boxPosition;
      motions.stopAll();
      _isDown = true;
    } else if (event.type == PointerEventType.up ||
        event.type == PointerEventType.cancel) {
      _pointerDownAt = null;
      _value = Offset.zero;
      MotionTween moveToCenter = MotionTween(
        (a) {
          _handlePos = a;
        },
        _handlePos,
        _center,
        0.4,
        Curves.elasticOut,
      );
      motions.run(moveToCenter);
      _isDown = false;
    } else if (event.type == PointerEventType.move && _isDown) {
      Offset movedDist = event.boxPosition - _pointerDownAt!;

      _value = Offset((movedDist.dx / 80.0).clamp(-1.0, 1.0),
          (movedDist.dy / 80.0).clamp(-1.0, 1.0));

      _handlePos = _center! + Offset(_value.dx * 40.0, _value.dy * 40.0);
    }
    return true;
  }

  @override
  bool handleKeyboardEvent(KeyEvent event) {
    // Ignore anything but arrow keys.
    if (!_isArrowKey(event.logicalKey)) {
      return false;
    }
    _isDown = false;
    _pointerDownAt = null;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _arrowKeyDown(_KeyDirection.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _arrowKeyDown(_KeyDirection.right);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _arrowKeyDown(_KeyDirection.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _arrowKeyDown(_KeyDirection.down);
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _arrowKeyUp(_KeyDirection.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _arrowKeyUp(_KeyDirection.right);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _arrowKeyUp(_KeyDirection.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _arrowKeyUp(_KeyDirection.down);
      }
    }

    // No need to consume the event, it can be passed on to other nodes too.
    return false;
  }

  void _arrowKeyDown(_KeyDirection direction) {
    if (_pressedKeys[direction]!) {
      return;
    }
    _pressedKeys[direction] = true;
    _updateJoystickFromKeys();
  }

  void _arrowKeyUp(_KeyDirection direction) {
    if (!_pressedKeys[direction]!) {
      return;
    }
    _pressedKeys[direction] = false;
    _updateJoystickFromKeys();
  }

  void _updateJoystickFromKeys() {
    var direction = _directionFromPressedKeys();
    _value = direction;

    motions.stopAll();

    MotionTween handleTween = MotionTween(
      (a) => _handlePos = a,
      _handlePos,
      _center! + Offset(_value.dx * 40, _value.dy * 40),
      0.4,
      Curves.elasticOut,
    );
    motions.run(handleTween);
  }

  Offset _directionFromPressedKeys() {
    var dx = 0.0;
    var dy = 0.0;
    if (_pressedKeys[_KeyDirection.up]!) {
      dy -= 1;
    }
    if (_pressedKeys[_KeyDirection.down]!) {
      dy += 1;
    }
    if (_pressedKeys[_KeyDirection.left]!) {
      dx -= 1;
    }
    if (_pressedKeys[_KeyDirection.right]!) {
      dx += 1;
    }

    return Offset(dx, dy);
  }

  bool _isArrowKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown;
  }

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);
    canvas.drawCircle(_handlePos!, 25.0, _paintHandle);
    canvas.drawCircle(_center!, 40.0, _paintControl);
  }
}
