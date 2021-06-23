/// This examples demonstrates how to align a [SceneElement] within the [Scene]
/// and that [Window]s work within the context of scrolling.
library scrolling_windows;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glopos/glopos.dart';

import '../shape.dart';
import 'example_scaffold.dart';

final _colors = [
  Colors.orange,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.indigo,
  Colors.blue,
  Colors.teal,
  Colors.green,
];

class ScrollingWindowPage extends StatefulWidget {
  const ScrollingWindowPage({Key? key}) : super(key: key);

  @override
  _ScrollingWindowPageState createState() => _ScrollingWindowPageState();
}

class _ScrollingWindowPageState extends State<ScrollingWindowPage> {
  var _scrollDirection = Axis.vertical;

  final _circle = Shape(
    layoutDelegate: AlignedBoxLayoutDelegate(
      size: const Size.square(600),
    ),
    shape: const CircleBorder(),
    shadow: false,
  );

  @override
  void dispose() {
    _circle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleScaffold(
        id: 'scrolling_windows',
        title: 'Scrolling Windows',
        parameters: [
          DropdownButton<Axis>(
            onChanged: (value) => setState(() => _scrollDirection = value!),
            value: _scrollDirection,
            items: const [
              DropdownMenuItem(
                value: Axis.vertical,
                child: Text('Vertical'),
              ),
              DropdownMenuItem(
                value: Axis.horizontal,
                child: Text('Horizontal'),
              ),
            ],
          ),
        ],
        body: Scene(
          elements: [_circle],
          child: ListView.builder(
            scrollDirection: _scrollDirection,
            itemBuilder: (context, index) {
              final color = _colors[index % _colors.length];
              final child = _ScrollingWindow(
                index: index,
                color: color,
              );

              // [_ScrollingWindow]s are positioned depending on their index to
              // create visual movement when scrolling through them.
              final alignment = sin(index * (360 / 60));
              return Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Container(
                    padding: _scrollDirection == Axis.vertical
                        ? const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10)
                        : const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                    alignment: _scrollDirection == Axis.vertical
                        ? Alignment(alignment, 0)
                        : Alignment(0, alignment),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _ScrollingWindow extends StatelessWidget {
  const _ScrollingWindow({
    Key? key,
    required this.index,
    required this.color,
  }) : super(key: key);

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 100,
        width: 350,
        child: Material(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background
              Container(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade300
                    : Colors.grey.shade900,
              ),
              // Global content of the window.
              Window(
                delegate: ShapeDelegate(
                  color: color,
                ),
              ),
              // Label
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
      );
}
