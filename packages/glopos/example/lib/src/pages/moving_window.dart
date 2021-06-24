/// This example demonstrates moving a [Window] over a static [Scene],
/// revealing different [SceneElement]s depending on it's position.
library moving_window;

import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

import '../shape.dart';
import 'example_scaffold.dart';

/// Background color of the overall example page.
final _backgroundColor = Colors.grey.shade900;

/// Size of the moving window.
const _windowSize = Size(300, 300);

class MovingWindowPage extends StatefulWidget {
  const MovingWindowPage({Key? key}) : super(key: key);

  @override
  _MovingWindowPageState createState() => _MovingWindowPageState();
}

class _MovingWindowPageState extends State<MovingWindowPage> {
  /// Green circle which is fixed at the top-left corner of the page.
  final _circle = Shape(
    color: Colors.green,
    shape: const CircleBorder(),
    layoutDelegate: AlignedBoxLayoutDelegate(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(20),
      size: const Size.square(150),
    ),
  );

  /// Orange square which is centerd in the page.
  final _square = Shape(
    color: Colors.orange,
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(60),
    ),
    layoutDelegate: AlignedBoxLayoutDelegate(
      size: const Size.square(200),
    ),
  );

  /// The moving window's current position, as an [Offset] to the center of it.
  final _windowPosition = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _circle.dispose();
    _square.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleScaffold(
        id: 'moving_window',
        title: 'Moving Window',
        backgroundColor: _backgroundColor,
        body: MouseRegion(
          // On devices with a mouse the window is positioned at the hover
          // position of the mouse.
          onHover: (event) => _windowPosition.value =
              event.localPosition - _windowSize.center(Offset.zero),
          child: Scene(
            elements: [_circle, _square],
            // The [Stack] is used to position the [_MovingWindow] within the
            // page.
            child: Stack(
              children: [
                ValueListenableBuilder<Offset>(
                  valueListenable: _windowPosition,
                  builder: (context, position, child) => Positioned.fromRect(
                    rect: position & _windowSize,
                    child: child!,
                  ),
                  child: _MovingWindow(position: _windowPosition),
                )
              ],
            ),
          ),
        ),
      );
}

class _MovingWindow extends StatelessWidget {
  const _MovingWindow({
    Key? key,
    required this.position,
  }) : super(key: key);

  final ValueNotifier<Offset> position;

  @override
  Widget build(BuildContext context) => GestureDetector(
        // Panning within the bounds of the window moves it.
        onPanUpdate: (details) => position.value += details.delta,
        // The [ShapeDelegate] moves shapes when they are dragged, but we want
        // to move the window regardless of where the user clicks.
        // [AbsorbPointer] hides the [Shape] from hit tested.
        child: AbsorbPointer(
          child: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: const Window(
              delegate: ShapeDelegate(),
            ),
          ),
        ),
      );
}
