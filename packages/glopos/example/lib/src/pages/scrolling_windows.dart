import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glopos/glopos.dart';

import '../shape.dart';

class ScrollingWindowPage extends StatefulWidget {
  const ScrollingWindowPage({Key? key}) : super(key: key);

  @override
  _ScrollingWindowPageState createState() => _ScrollingWindowPageState();
}

class _ScrollingWindowPageState extends State<ScrollingWindowPage> {
  final _scrollDirection = Axis.vertical;

  final _circle = Shape(
    layoutDelegate: AlignedBoxLayoutDelegate(
      size: const Size.square(600),
    ),
    color: Colors.black,
    shape: const CircleBorder(),
    shadow: false,
  );

  @override
  void dispose() {
    _circle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scrolling Windows'),
        ),
        body: Scene(
          elements: [_circle],
          child: ListView.builder(
            scrollDirection: _scrollDirection,
            itemBuilder: (context, index) => _ScrollingWindow(
              index: index,
              style: _ScrollingWindowStyle.generate(index: index),
              alignmentAxis: _scrollDirection,
            ),
          ),
        ),
      );
}

class _ScrollingWindowStyle {
  _ScrollingWindowStyle({
    required this.alignment,
    required this.color,
  });

  factory _ScrollingWindowStyle.generate({
    required int index,
  }) =>
      _ScrollingWindowStyle(
        alignment: sin(index * (360 / 60)),
        color: _colors[index % _colors.length],
      );

  static final _colors = [
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
  ];

  final double alignment;
  final Color color;
}

class _ScrollingWindow extends StatelessWidget {
  const _ScrollingWindow({
    Key? key,
    required this.style,
    required this.index,
    required this.alignmentAxis,
  }) : super(key: key);

  final _ScrollingWindowStyle style;
  final int index;
  final Axis alignmentAxis;

  @override
  Widget build(BuildContext context) => Container(
        padding: alignmentAxis == Axis.vertical
            ? const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
            : const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        alignment: alignmentAxis == Axis.vertical
            ? Alignment(style.alignment, 0)
            : Alignment(0, style.alignment),
        child: SizedBox(
          height: 100,
          width: 350,
          child: Material(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Container(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade300
                      : Colors.grey.shade900,
                ),
                Window(
                  delegate: ShapeDelegate(
                    color: style.color,
                  ),
                ),
                Align(
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
