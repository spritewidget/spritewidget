import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late NodeWithSize rootNode;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void reassemble() {
    init();
    super.reassemble();
  }

  void init() {
    rootNode = NodeWithSize(const Size(1024, 1024));
    final box = Box(const Size(200, 200));
    box.position = const Offset(512, 512);
    box.pivot = const Offset(0.5, 0.5);
    rootNode.addChild(box);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Spritewidget example app'),
        ),
        body: Center(
          child: SpriteWidget(rootNode: rootNode),
        ),
      ),
    );
  }
}

class Box extends NodeWithSize {
  Box(Size size) : super(size);

  @override
  void paint(Canvas canvas) {
    applyTransformForPivot(canvas);

    canvas.drawRect(
      Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..color = const Color(0xffff0000),
    );
  }

  @override
  void update(double dt) {
    rotation += dt;
    super.update(dt);
  }
}
