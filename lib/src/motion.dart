// Copyright 2022 The SpriteWidget Authors. All rights reserved.
// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

/// Signature for callbacks used by the [MotionCallFunction].
typedef MotionCallback = void Function();

/// Motions are used to animate properties of nodes or any other type of
/// objects. The motions are powered by an [MotionController], typically
/// associated with a [Node]. The most commonly used motion is the
/// [MotionTween] which interpolates a property between two values over time.
///
/// Motions can be nested in different ways; played in sequence using the
/// [MotionSequence], or looped using the [MotionRepeat].
///
/// You should typically not override this class directly, instead override
/// [MotionInterval] or [MotionInstant] if you need to create a new action
/// class.
abstract class Motion {
  Object? _tag;
  bool _finished = false;
  bool _added = false;

  /// Allows to check if a motion is finished
  bool get finished => _finished;	

  /// Moves to the next time step in an motion, [dt] is the delta time since
  /// the last time step in seconds. Typically this method is called from the
  /// [MotionController].
  void step(double dt);

  /// Sets the motion to a specific point in time. The [t] value that is passed
  /// in is a normalized value 0.0 to 1.0 of the duration of the motion. Every
  /// motion will always recieve a callback with the end time point (1.0),
  /// unless it is cancelled.
  void update(double t) {}

  void _reset() {
    _finished = false;
  }

  /// The total time it will take to complete the motion, in seconds.
  double get duration => 0.0;
}

/// Signature for callbacks for setting properties, used by [MotionTween].
typedef SetterCallback<T> = void Function(T value);

/// The abstract class for an motion that changes properties over a time
/// interval, optionally using an easing curve.
abstract class MotionInterval extends Motion {
  /// Creates a new [MotionInterval], typically you will want to pass in a
  /// [duration] to specify how long time the motion will take to complete.
  MotionInterval([this._duration = 0.0, this.curve]);

  @override
  double get duration => _duration;
  double _duration;

  /// The animation curve used to ease the animation.
  ///
  ///     myMotion.curve = bounceOut;
  Curve? curve;

  bool _firstTick = true;
  double _elapsed = 0.0;

  @override
  void step(double dt) {
    if (_firstTick) {
      _firstTick = false;
    } else {
      _elapsed += dt;
    }

    double t;
    if (_duration == 0.0) {
      t = 1.0;
    } else {
      t = (_elapsed / _duration).clamp(0.0, 1.0);
    }

    if (curve == null) {
      update(t);
    } else {
      update(curve!.transform(t));
    }

    if (t >= 1.0) _finished = true;
  }
}

/// An motion that repeats another motion a fixed number of times.
class MotionRepeat extends MotionInterval {
  /// The number of times the [motion] is repeated.
  final int numRepeats;

  /// The motion that is repeated.
  final MotionInterval motion;
  int _lastFinishedRepeat = -1;

  /// Creates a new motion that is repeats the passed in motion a fixed number
  /// of times.
  ///
  ///     var myLoop = new MotionRepeat(myMotion);
  MotionRepeat({required this.motion, required this.numRepeats}) {
    _duration = motion.duration * numRepeats;
  }

  @override
  void update(double t) {
    int currentRepeat =
        math.min((t * numRepeats.toDouble()).toInt(), numRepeats - 1);
    for (int i = math.max(_lastFinishedRepeat, 0); i < currentRepeat; i++) {
      if (!motion._finished) motion.update(1.0);
      motion._reset();
    }
    _lastFinishedRepeat = currentRepeat;

    double ta = (t * numRepeats.toDouble()) % 1.0;
    motion.update(ta);

    if (t >= 1.0) {
      motion.update(1.0);
      motion._finished = true;
    }
  }
}

/// A motion that repeats a motion an indefinite number of times.
class MotionRepeatForever extends Motion {
  /// The motion that is repeated indefinitely.
  final MotionInterval motion;
  double _elapsedInMotion = 0.0;

  /// Creates a new motion with the motion that is passed in.
  ///
  ///     var myInifiniteLoop = MotionRepeatForever(motion: myMotion);
  MotionRepeatForever({required this.motion});

  @override
  void step(double dt) {
    _elapsedInMotion += dt;
    while (_elapsedInMotion > motion.duration) {
      _elapsedInMotion -= motion.duration;
      if (!motion._finished) motion.update(1.0);
      motion._reset();
    }
    _elapsedInMotion = math.max(_elapsedInMotion, 0.0);

    double t;
    if (motion._duration == 0.0) {
      t = 1.0;
    } else {
      t = (_elapsedInMotion / motion._duration).clamp(0.0, 1.0);
    }

    motion.update(t);
  }
}

/// A motion that plays a number of supplied motions in sequence. The duration
/// of the [MotionSequence] with be the sum of the durations of the motions
/// passed in to the constructor.
class MotionSequence extends MotionInterval {
  late Motion _a;
  late Motion _b;
  late double _split;

  /// Creates a new motion with the list of motions passed in.
  ///
  ///     var mySequence = MotionSequence(
  ///       motions: [myMotion0, myMotion1, myMotion2],
  ///     );
  MotionSequence({required List<Motion> motions}) {
    assert(motions.length >= 2);

    if (motions.length == 2) {
      // Base case
      _a = motions[0];
      _b = motions[1];
    } else {
      _a = motions[0];
      _b = MotionSequence(motions: motions.sublist(1));
    }

    // Calculate split and duration
    _duration = _a.duration + _b.duration;
    if (_duration > 0) {
      _split = _a.duration / _duration;
    } else {
      _split = 1.0;
    }
  }

  @override
  void update(double t) {
    if (t < _split) {
      // Play first motion
      double ta;
      if (_split > 0.0) {
        ta = (t / _split).clamp(0.0, 1.0);
      } else {
        ta = 1.0;
      }
      _updateWithCurve(_a, ta);
    } else if (t >= 1.0) {
      // Make sure everything is finished
      if (!_a._finished) _finish(_a);
      if (!_b._finished) _finish(_b);
    } else {
      // Play second motion, but first make sure the first has finished
      if (!_a._finished) _finish(_a);
      double tb;
      if (_split < 1.0) {
        tb = (1.0 - (1.0 - t) / (1.0 - _split)).clamp(0.0, 1.0);
      } else {
        tb = 1.0;
      }
      _updateWithCurve(_b, tb);
    }
  }

  void _updateWithCurve(Motion motion, double t) {
    if (motion is MotionInterval) {
      MotionInterval motionInterval = motion;
      if (motionInterval.curve == null) {
        motion.update(t);
      } else {
        motion.update(motionInterval.curve!.transform(t));
      }
    } else {
      motion.update(t);
    }

    if (t >= 1.0) {
      motion._finished = true;
    }
  }

  void _finish(Motion motion) {
    motion.update(1.0);
    motion._finished = true;
  }

  @override
  void _reset() {
    super._reset();
    _a._reset();
    _b._reset();
  }
}

/// A motion that plays the supplied motions in parallell. The duration of the
/// [MotionGroup] will be the maximum of the durations of the motions used to
/// compose this motion.
class MotionGroup extends MotionInterval {
  late final List<Motion> _motions;

  /// Creates a new motion with the list of motions passed in.
  ///
  ///     var myGroup = new MotionGroup([myMotion0, myMotion1, myMotion2]);
  MotionGroup({required List<Motion> motions}) : _motions = motions {
    for (Motion motion in _motions) {
      if (motion.duration > _duration) {
        _duration = motion.duration;
      }
    }
  }

  @override
  void update(double t) {
    if (t >= 1.0) {
      // Finish all unfinished motions
      for (Motion motion in _motions) {
        if (!motion._finished) {
          motion.update(1.0);
          motion._finished = true;
        }
      }
    } else {
      for (Motion motion in _motions) {
        if (motion.duration == 0.0) {
          // Fire all instant motions immediately
          if (!motion._finished) {
            motion.update(1.0);
            motion._finished = true;
          }
        } else {
          // Update child motions
          double ta = (t / (motion.duration / duration)).clamp(0.0, 1.0);
          if (ta < 1.0) {
            if (motion is MotionInterval) {
              MotionInterval motionInterval = motion;
              if (motionInterval.curve == null) {
                motion.update(ta);
              } else {
                motion.update(motionInterval.curve!.transform(ta));
              }
            } else {
              motion.update(ta);
            }
          } else if (!motion._finished) {
            motion.update(1.0);
            motion._finished = true;
          }
        }
      }
    }
  }

  @override
  void _reset() {
    for (Motion motion in _motions) {
      motion._reset();
    }
  }
}

/// A motion that doesn't perform any other task than taking time. This motion
/// is typically used in a sequence to space out other events.
class MotionDelay extends MotionInterval {
  /// Creates a new motion with the specified [delay]
  MotionDelay({required double delay}) : super(delay);
}

/// A motion that doesn't have a duration. If this class is overridden to
/// create custom instant motions, only the [fire] method should be overriden.
abstract class MotionInstant extends Motion {
  @override
  void step(double dt) {}

  @override
  void update(double t) {
    fire();
    _finished = true;
  }

  /// Called when the motion is executed. If you are implementing your own
  /// MotionInstant, override this method.
  void fire();
}

/// A motion that calls a custom function when it is fired.
class MotionCallFunction extends MotionInstant {
  final MotionCallback _callback;

  /// Creates a new callback motion with the supplied callback.
  ///
  ///     var myMotion = MotionCallFunction(
  ///       callback: () { print("Hello!";) },
  ///     );
  MotionCallFunction({
    required MotionCallback callback,
  }) : _callback = callback;

  @override
  void fire() {
    _callback();
  }
}

/// A motion that removes the supplied node from its parent when it's fired.
class MotionRemoveNode extends MotionInstant {
  final Node _node;

  /// Creates a new motion with the node to remove as its argument.
  ///
  ///     var myMotion = MotionRemoveNode(node: myNode);
  MotionRemoveNode({required Node node}) : _node = node;

  @override
  void fire() {
    _node.removeFromParent();
  }
}

/// A motion that tweens a property between two values, optionally using an
/// animation curve. This is one of the most common building blocks when
/// creating motions. The tween class can be used to animate properties of the
/// type [Point], [Size], [Rect], [double], or [Color].
class MotionTween<T> extends MotionInterval {
  /// Creates a new tween motion. The [setter] will be called to update the
  /// animated property from [start] to [end] over the [duration] time in
  /// seconds. Optionally an animation [curve] can be passed in for easing the
  /// animation.
  ///
  ///     // Animate myNode from its current position to 100.0, 100.0 during
  ///     // 1.0 second and a bounceOut easing
  ///     var myTween = MotionTween(
  ///       setter: (a) => myNode.position = a,
  ///       start: myNode.position,
  ///       end: new Point(100.0, 100.0,
  ///       duration: 1.0,
  ///       curve: Curves.bounceOut,
  ///     );
  ///     myNode.motions.run(myTween);
  MotionTween({
    required this.setter,
    required this.start,
    required this.end,
    required double duration,
    Curve? curve,
  }) : super(duration, curve) {
    _computeDelta();
  }

  /// The setter method used to set the property being animated.
  final SetterCallback<T> setter;

  /// The start value of the animation.
  final T start;

  /// The end value of the animation.
  final T end;

  late dynamic _delta;

  void _computeDelta() {
    if (start is Offset) {
      // Point
      double xStart = (start as Offset).dx;
      double yStart = (start as Offset).dy;
      double xEnd = (end as Offset).dx;
      double yEnd = (end as Offset).dy;
      _delta = Offset(xEnd - xStart, yEnd - yStart);
    } else if (start is Size) {
      // Size
      double wStart = (start as Size).width;
      double hStart = (start as Size).height;
      double wEnd = (end as Size).width;
      double hEnd = (end as Size).height;
      _delta = Size(wEnd - wStart, hEnd - hStart);
    } else if (start is Rect) {
      // Rect
      double lStart = (start as Rect).left;
      double tStart = (start as Rect).top;
      double rStart = (start as Rect).right;
      double bStart = (start as Rect).bottom;
      double lEnd = (end as Rect).left;
      double tEnd = (end as Rect).top;
      double rEnd = (end as Rect).right;
      double bEnd = (end as Rect).bottom;
      _delta = Rect.fromLTRB(
          lEnd - lStart, tEnd - tStart, rEnd - rStart, bEnd - bStart);
    } else if (start is double) {
      // Double
      _delta = (end as double) - (start as double);
    } else if (start is Color) {
      // Color
      int aDelta = (end as Color).alpha - (start as Color).alpha;
      int rDelta = (end as Color).red - (start as Color).red;
      int gDelta = (end as Color).green - (start as Color).green;
      int bDelta = (end as Color).blue - (start as Color).blue;
      _delta = _ColorDiff(aDelta, rDelta, gDelta, bDelta);
    } else {
      assert(false);
    }
  }

  @override
  void update(double t) {
    dynamic newVal;

    if (start is Offset) {
      // Point
      double xStart = (start as Offset).dx;
      double yStart = (start as Offset).dy;
      double xDelta = _delta.dx;
      double yDelta = _delta.dy;
      newVal = Offset(xStart + xDelta * t, yStart + yDelta * t);
    } else if (start is Size) {
      // Size
      double wStart = (start as Size).width;
      double hStart = (start as Size).height;
      double wDelta = _delta.width;
      double hDelta = _delta.height;
      newVal = Size(wStart + wDelta * t, hStart + hDelta * t);
    } else if (start is Rect) {
      // Rect
      double lStart = (start as Rect).left;
      double tStart = (start as Rect).top;
      double rStart = (start as Rect).right;
      double bStart = (start as Rect).bottom;
      double lDelta = _delta.left;
      double tDelta = _delta.top;
      double rDelta = _delta.right;
      double bDelta = _delta.bottom;
      newVal = Rect.fromLTRB(lStart + lDelta * t, tStart + tDelta * t,
          rStart + rDelta * t, bStart + bDelta * t);
    } else if (start is double) {
      // Doubles
      newVal = (start as double) + _delta * t;
    } else if (start is Color) {
      // Colors
      int aNew = ((start as Color).alpha + (_delta.alpha * t).toInt())
          .clamp(0, 255) as int;
      int rNew = ((start as Color).red + (_delta.red * t).toInt()).clamp(0, 255)
          as int;
      int gNew = ((start as Color).green + (_delta.green * t).toInt())
          .clamp(0, 255) as int;
      int bNew = ((start as Color).blue + (_delta.blue * t).toInt())
          .clamp(0, 255) as int;
      newVal = Color.fromARGB(aNew, rNew, gNew, bNew);
    } else {
      // Oopses
      assert(false);
    }

    setter(newVal);
  }
}

/// A class the controls the playback of motions. To play back an motion it is
/// passed to the [MotionController]'s [run] method. The [MotionController]
/// itself is typically a property of a [Node] and powered by the [SpriteBox].
class MotionController {
  final List<Motion> _motions = <Motion>[];

  /// Set to true to pause the MotionController. No of the actions associated
  /// with the controller will run while it's paused.
  bool paused = false;

  /// Creates a new [MotionController]. However, for most uses a reference to
  /// an [MotionController] is acquired through the [Node.motions] property.
  MotionController();

  /// Runs an [motion], can optionally be passed a [tag]. The [tag] can be used
  /// to reference the motion or a set of motions with the same tag.
  ///
  ///     myNode.motions.run(myMotion, tag: 'myMotionGroup');
  void run(Motion motion, {Object? tag}) {
    assert(!motion._added);

    motion._tag = tag;
    motion._added = true;
    motion.update(0.0);
    _motions.add(motion);
  }

  /// Stops an [Motion] and removes it from the controller.
  ///
  ///     myNode.motions.stop(myMotion);
  void stop(Motion motion) {
    if (_motions.remove(motion)) {
      motion._added = false;
      motion._reset();
    }
  }

  void _stopAtIndex(int i) {
    Motion motion = _motions[i];
    motion._added = false;
    motion._reset();
    _motions.removeAt(i);
  }

  /// Stops all motions with the specified tag and removes them from the
  /// controller.
  ///
  ///     myNode.motions.stopWithTag('myMotionGroup');
  void stopWithTag(Object tag) {
    for (int i = _motions.length - 1; i >= 0; i--) {
      Motion motion = _motions[i];
      if (motion._tag == tag) {
        _stopAtIndex(i);
      }
    }
  }

  /// Stops all motions currently being run by the controller and removes them.
  ///
  ///     myNode.motions.stopAll();
  void stopAll() {
    for (int i = _motions.length - 1; i >= 0; i--) {
      _stopAtIndex(i);
    }
  }

  /// Steps the motion forward by the specified time, typically there is no need
  /// to directly call this method.
  void step(double dt) {
    if (paused) {
      return;
    }

    for (int i = _motions.length - 1; i >= 0; i--) {
      Motion motion = _motions[i];
      motion.step(dt);

      if (motion._finished) {
        motion._added = false;
        _motions.removeAt(i);
      }
    }
  }
}

class _ColorDiff {
  final int alpha;
  final int red;
  final int green;
  final int blue;

  _ColorDiff(this.alpha, this.red, this.green, this.blue);
}
