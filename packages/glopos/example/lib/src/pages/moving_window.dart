import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

import '../shape.dart';

final _backgroundColor = Colors.grey.shade900;
const _windowSize = Size(300, 300);

class MovingWindowPage extends StatefulWidget {
  const MovingWindowPage({Key? key}) : super(key: key);

  @override
  _MovingWindowPageState createState() => _MovingWindowPageState();
}

class _MovingWindowPageState extends State<MovingWindowPage> {
  final _circle = Shape(
    color: Colors.green,
    shape: const CircleBorder(),
    layoutDelegate: AlignedBoxLayoutDelegate(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(20),
      size: const Size.square(150),
    ),
  );

  final _square = Shape(
    color: Colors.orange,
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(60),
    ),
    layoutDelegate: AlignedBoxLayoutDelegate(
      size: const Size.square(200),
    ),
  );

  final _windowPosition = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _circle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Moving Window'),
        ),
        backgroundColor: _backgroundColor,
        body: MouseRegion(
          onHover: (event) => _windowPosition.value =
              event.localPosition - _windowSize.center(Offset.zero),
          child: Scene(
            elements: [
              _circle,
              _square,
            ],
            child: Stack(
              children: [
                ValueListenableBuilder<Offset>(
                  valueListenable: _windowPosition,
                  builder: (context, position, child) => Positioned.fromRect(
                    rect: position & _windowSize,
                    child: child!,
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      _windowPosition.value += details.delta;
                    },
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Window(
                          delegate: ShapeDelegate(),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
