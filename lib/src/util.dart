// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

math.Random _random = math.Random();

// Random methods

/// Returns a random [double] in the range of 0.0 to 1.0.
double randomDouble() {
  return _random.nextDouble();
}

/// Returns a random [double] in the range of -1.0 to 1.0.
double randomSignedDouble() {
  return _random.nextDouble() * 2.0 - 1.0;
}

/// Returns a random [int] from 0 to max - 1.
int randomInt(int max) {
  return _random.nextInt(max);
}

/// Returns either [true] or [false] in a most random fashion.
bool randomBool() {
  return _random.nextDouble() < 0.5;
}

// atan2

class _Atan2Constants {
  _Atan2Constants() {
    for (int i = 0; i <= size; i++) {
      double f = i.toDouble() / size.toDouble();
      ppy[i] = math.atan(f) * stretch / math.pi;
      ppx[i] = stretch * 0.5 - ppy[i];
      pny[i] = -ppy[i];
      pnx[i] = ppy[i] - stretch * 0.5;
      npy[i] = stretch - ppy[i];
      npx[i] = ppy[i] + stretch * 0.5;
      nny[i] = ppy[i] - stretch;
      nnx[i] = -stretch * 0.5 - ppy[i];
    }
  }

  static const int size = 1024;
  static const double stretch = math.pi;

  static const int ezis = -size;

  final Float64List ppy = Float64List(size + 1);
  final Float64List ppx = Float64List(size + 1);
  final Float64List pny = Float64List(size + 1);
  final Float64List pnx = Float64List(size + 1);
  final Float64List npy = Float64List(size + 1);
  final Float64List npx = Float64List(size + 1);
  final Float64List nny = Float64List(size + 1);
  final Float64List nnx = Float64List(size + 1);
}

/// Provides convenience methods for calculations often carried out in graphics.
/// Some of the methods are returning approximations.
class GameMath {
  static final _Atan2Constants _atan2 = _Atan2Constants();

  /// Returns the angle of two vector components. The result is less accurate
  /// than the standard atan2 function in the math package.
  static double atan2(double y, double x) {
    if (x >= 0) {
      if (y >= 0) {
        if (x >= y) {
          return _atan2.ppy[(_Atan2Constants.size * y / x + 0.5).toInt()];
        } else {
          return _atan2.ppx[(_Atan2Constants.size * x / y + 0.5).toInt()];
        }
      } else {
        if (x >= -y) {
          return _atan2.pny[(_Atan2Constants.ezis * y / x + 0.5).toInt()];
        } else {
          return _atan2.pnx[(_Atan2Constants.ezis * x / y + 0.5).toInt()];
        }
      }
    } else {
      if (y >= 0) {
        if (-x >= y) {
          return _atan2.npy[(_Atan2Constants.ezis * y / x + 0.5).toInt()];
        } else {
          return _atan2.npx[(_Atan2Constants.ezis * x / y + 0.5).toInt()];
        }
      } else {
        if (x <= y) {
          return _atan2.nny[(_Atan2Constants.size * y / x + 0.5).toInt()];
        } else {
          return _atan2.nnx[(_Atan2Constants.size * x / y + 0.5).toInt()];
        }
      }
    }
  }

  /// Approximates the distance between two points. The returned value can be
  /// up to 6% wrong in the worst case.
  static double distanceBetweenPoints(Offset a, Offset b) {
    double dx = a.dx - b.dx;
    double dy = a.dy - b.dy;
    if (dx < 0.0) dx = -dx;
    if (dy < 0.0) dy = -dy;
    if (dx > dy) {
      return dx + dy / 2.0;
    } else {
      return dy + dx / 2.0;
    }
  }

  /// Interpolates a [double] between [a] and [b] according to the
  /// [filterFactor], which should be in the range of 0.0 to 1.0.
  static double filter(double a, double b, double filterFactor) {
    return (a * (1 - filterFactor)) + b * filterFactor;
  }

  /// Interpolates a [Point] between [a] and [b] according to the
  /// [filterFactor], which should be in the range of 0.0 to 1.0.
  static Offset filterPoint(Offset a, Offset b, double filterFactor) {
    return Offset(
        filter(a.dx, b.dx, filterFactor), filter(a.dy, b.dy, filterFactor));
  }

  /// Returns the intersection between two line segments defined by p0, p1 and
  /// q0, q1. If the lines are not intersecting null is returned.
  static Offset? lineIntersection(Offset p0, Offset p1, Offset q0, Offset q1) {
    double epsilon = 1e-10;

    Vector2 r = Vector2(p1.dx - p0.dx, p1.dy - p0.dy);
    Vector2 s = Vector2(q1.dx - q0.dx, q1.dy - q0.dy);
    Vector2 qp = Vector2(q0.dx - p0.dx, q0.dy - p0.dy);

    double rxs = cross2(r, s);

    if (rxs.abs() < epsilon) {
      // The lines are linear or collinear
      return null;
    }

    double t = cross2(qp, s) / rxs;
    double u = cross2(qp, r) / rxs;

    if ((0.0 <= t && t <= 1.0) && (0.0 <= u && u <= 1.0)) {
      return Offset(p0.dx + t * r.x, p0.dy + t * r.y);
    }

    // No intersection between the lines
    return null;
  }
}
