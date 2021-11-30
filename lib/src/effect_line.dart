// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of spritewidget;

/// Used by [EffectLine] to determine how the width of the line is calculated.
enum EffectLineWidthMode {
  /// Linear interpolation between minWidth at the start and maxWidth at the
  /// end of the line.
  linear,

  /// Creates a barrel shaped line, with minWidth at the end points of the line
  /// and maxWidth at the middle.
  barrel,
}

/// Used by [EffectLine] to determine how the texture of the line is animated.
enum EffectLineAnimationMode {
  /// The texture of the line isn't animated.
  none,

  /// The texture of the line is scrolling.
  scroll,

  /// The texture of the line is set to a random position at every frame. This
  /// mode is useful for creating flashing or electricity styled effects.
  random,
}

/// The EffectLine class is using the [TexturedLine] class to draw animated
/// lines. These can be used to draw things such as smoke trails, electricity
/// effects, or other animated types of lines.
class EffectLine extends Node {
  /// Creates a new EffectLine with the specified parameters. Only the
  /// [texture] parameter is required, all other parameters are optional.
  EffectLine(
      {required this.texture,
      this.transferMode: BlendMode.dstOver,
      List<Offset>? points,
      this.widthMode: EffectLineWidthMode.linear,
      this.minWidth: 10.0,
      this.maxWidth: 10.0,
      this.widthGrowthSpeed: 0.0,
      this.animationMode: EffectLineAnimationMode.none,
      this.scrollSpeed: 0.1,
      double scrollStart: 0.0,
      this.fadeDuration: 0.0,
      this.fadeAfterDelay: 0.0,
      this.textureLoopLength: 0.0,
      this.simplify: true,
      ColorSequence? colorSequence}) {
    if (points == null)
      this.points = <Offset>[];
    else
      this.points = points;

    if (colorSequence == null) {
      _colorSequence = new ColorSequence.fromStartAndEndColor(
          const Color(0xffffffff), const Color(0xffffffff));
    } else
      _colorSequence = colorSequence;

    _offset = scrollStart;

    _painter = new TexturedLinePainter(points!, _colors, _widths, texture);
    _painter?.textureLoopLength = textureLoopLength;
  }

  /// The texture used to draw the line.
  final SpriteTexture texture;

  /// The transfer mode used to draw the line, default is
  /// [TransferMode.dstOver].
  final BlendMode transferMode;

  /// Mode used to calculate the width of the line.
  final EffectLineWidthMode widthMode;

  /// The width of the line at its thinnest point.
  final double minWidth;

  /// The width of the line at its thickest point.
  final double maxWidth;

  /// The speed at which the line is growing, defined in points per second.
  final double widthGrowthSpeed;

  /// The mode used to animate the texture of the line.
  final EffectLineAnimationMode animationMode;

  /// The speed of which the texture of the line is scrolling. This property
  /// is only used if the [animationMode] is set to
  /// [EffectLineAnimationMode.scroll].
  final double scrollSpeed;

  /// Color gradient used to draw the line, from start to finish.
  ColorSequence get colorSequence => _colorSequence;

  late ColorSequence _colorSequence;

  /// List of points that make up the line. Typically, you will only want to
  /// set this at the beginning. Then use [addPoint] to add additional points
  /// to the line.
  List<Offset> get points => _points;

  set points(List<Offset> points) {
    _points = points;
    _pointAges = <double>[];
    for (int i = 0; i < _points.length; i++) {
      _pointAges.add(0.0);
    }
  }

  late List<Offset> _points;

  List<double> _pointAges = List<double>.empty(growable: true);
  List<Color> _colors = List<Color>.empty(growable: true);
  List<double> _widths = List<double>.empty(growable: true);

  /// The time it takes for an added point to fade out. It's total life time is
  /// [fadeDuration] + [fadeAfterDelay].
  final double fadeDuration;

  /// The time it takes until an added point starts to fade out.
  final double fadeAfterDelay;

  /// The length, in points, that the texture is stretched to. If the
  /// textureLoopLength is shorter than the line, the texture will be looped.
  final double textureLoopLength;

  /// True if the line should be simplified by removing points that are close
  /// to other points. This makes drawing faster, but can result in a slight
  /// jittering effect when points are added.
  final bool simplify;

  TexturedLinePainter? _painter;
  double _offset = 0.0;

  @override
  void update(double dt) {
    // Update scrolling position
    if (animationMode == EffectLineAnimationMode.scroll) {
      _offset += dt * scrollSpeed;
      _offset %= 1.0;
    } else if (animationMode == EffectLineAnimationMode.random) {
      _offset = randomDouble();
    }

    // Update age of line points and remove if neccesasry
    for (int i = _points.length - 1; i >= 0; i--) {
      _pointAges[i] += dt;
    }

    // Check if the first/oldest point should be removed
    while (
        _points.length > 0 && _pointAges[0] > (fadeDuration + fadeAfterDelay)) {
      // Update scroll if it isn't the last and only point that is about to removed
      if (_points.length > 1) {
        double dist = GameMath.distanceBetweenPoints(_points[0], _points[1]);
        _offset = (_offset - (dist / textureLoopLength)) % 1.0;
        if (_offset < 0.0) _offset += 1;
      }

      // Remove the point
      _pointAges.removeAt(0);
      _points.removeAt(0);
    }
  }

  @override
  void paint(Canvas canvas) {
    if (points.length < 2) return;

    _painter?.points = points;

    // Calculate colors
    List<double> stops = _painter?.calculatedTextureStops ?? [];

    List<Color> colors = <Color>[];
    for (int i = 0; i < stops.length; i++) {
      double stop = stops[i];
      Color color = _colorSequence.colorAtPosition(stop);

      double age = _pointAges[i];
      if (age > fadeAfterDelay) {
        double fade = 1.0 - (age - fadeAfterDelay) / fadeDuration;
        int alpha = (color.alpha * fade).toInt().clamp(0, 255);
        color = new Color.fromARGB(alpha, color.red, color.green, color.blue);
      }
      colors.add(color);
    }
    _painter?.colors = colors;

    // Calculate widths
    List<double> widths = <double>[];
    for (int i = 0; i < stops.length; i++) {
      double stop = stops[i];
      double growth = math.max(widthGrowthSpeed * _pointAges[i], 0.0);
      if (widthMode == EffectLineWidthMode.linear) {
        double width = minWidth + (maxWidth - minWidth) * stop + growth;
        widths.add(width);
      } else if (widthMode == EffectLineWidthMode.barrel) {
        double width = minWidth +
            math.sin(stop * math.pi) * (maxWidth - minWidth) +
            growth;
        widths.add(width);
      }
    }
    _painter?.widths = widths;

    _painter?.textureStopOffset = _offset;

    _painter?.paint(canvas);
  }

  /// Adds a new point to the end of the line.
  void addPoint(Offset point) {
    // Skip duplicate points
    if (points.length > 0 &&
        point.dx == points[points.length - 1].dx &&
        point.dy == points[points.length - 1].dy) return;

    if (simplify &&
        points.length >= 2 &&
        GameMath.distanceBetweenPoints(point, points[points.length - 2]) <
            10.0) {
      // Check if we should remove last point before adding the new one

      // Calculate the square distance from the middle point to the line of the
      // new point and the second to last point
      double dist2 = _distToSeqment2(
          points[points.length - 1], point, points[points.length - 2]);

      // If the point is on the line, remove it
      if (dist2 < 1.0) {
        _points.removeAt(_points.length - 1);
      }
    }

    // Add point and point's age
    _points.add(point);
    _pointAges.add(0.0);
  }

  double _sqr(double x) => x * x;

  double _dist2(Offset v, Offset w) => _sqr(v.dx - w.dx) + _sqr(v.dy - w.dy);

  double _distToSeqment2(Offset p, Offset v, Offset w) {
    double l2 = _dist2(v, w);
    if (l2 == 0.0) return _dist2(p, v);
    double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    if (t < 0) return _dist2(p, v);
    if (t > 1) return _dist2(p, w);
    return _dist2(
        p, new Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy)));
  }
}
