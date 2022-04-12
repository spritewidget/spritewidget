// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

Offset _cardinalSplineAt(
    Offset p0, Offset p1, Offset p2, Offset p3, double tension, double t) {
  double t2 = t * t;
  double t3 = t2 * t;

  double s = (1.0 - tension) / 2.0;

  double b1 = s * ((-t3 + (2.0 * t2)) - t);
  double b2 = s * (-t3 + t2) + (2.0 * t3 - 3.0 * t2 + 1.0);
  double b3 = s * (t3 - 2.0 * t2 + t) + (-2.0 * t3 + 3.0 * t2);
  double b4 = s * (t3 - t2);

  double x = p0.dx * b1 + p1.dx * b2 + p2.dx * b3 + p3.dx * b4;
  double y = p0.dy * b1 + p1.dy * b2 + p2.dy * b3 + p3.dy * b4;

  return new Offset(x, y);
}

/// Signature for callbacks used by the [MotionSpline] to set a [Point] value.
typedef void PointSetterCallback(Offset value);

/// The spline motion is used to animate a point along a spline definied by
/// a set of points.
class MotionSpline extends MotionInterval {
  /// Creates a new spline motion with a set of points. The [setter] is a
  /// callback for setting the positions, [points] define the spline, and
  /// [duration] is the time for the motion to complete. Optionally a [curve]
  /// can be used for easing.
  MotionSpline(this.setter, this.points, double duration, [Curve? curve])
      : super(duration, curve) {
    _dt = 1.0 / (points.length - 1.0);
  }

  /// The callback used to update a point when the motion is run.
  final PointSetterCallback setter;

  /// A list of points that define the spline.
  final List<Offset> points;

  /// The tension of the spline, defines the roundness of the curve.
  double tension = 0.5;

  late double _dt;

  @override
  void update(double t) {
    int p;
    double lt;

    if (t < 0.0) t = 0.0;

    if (t >= 1.0) {
      p = points.length - 1;
      lt = 1.0;
    } else {
      p = (t / _dt).floor();
      lt = (t - _dt * p) / _dt;
    }

    Offset p0 = points[(p - 1).clamp(0, points.length - 1)];
    Offset p1 = points[(p + 0).clamp(0, points.length - 1)];
    Offset p2 = points[(p + 1).clamp(0, points.length - 1)];
    Offset p3 = points[(p + 2).clamp(0, points.length - 1)];

    Offset newPos = _cardinalSplineAt(p0, p1, p2, p3, tension, lt);

    setter(newPos);
  }
}
