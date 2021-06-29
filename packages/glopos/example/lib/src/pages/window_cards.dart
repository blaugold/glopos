/// This example demonstrates that [SceneElement]s can have a different
/// appearance in each [Window] through which they are viewed.
library window_cards;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glopos/glopos.dart';

import '../components/example_scaffold.dart';
import '../shape.dart';

class WindowCardsPage extends StatefulWidget {
  const WindowCardsPage({Key? key}) : super(key: key);

  @override
  _WindowCardsPageState createState() => _WindowCardsPageState();
}

class _WindowCardsPageState extends State<WindowCardsPage> {
  final _shape = Shape(
    shape: const CircleBorder(),
    layoutDelegate: PositionedBoxLayoutDelegate(
      alignment: Alignment.center,
      size: const Size.square(150),
    ),
  );

  @override
  void dispose() {
    _shape.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExampleScaffold(
        id: 'window_cards',
        title: 'Window Cards',
        body: BindElementToMouse(
          element: _shape,
          child: Scene(
            elements: [_shape],
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _WindowCard(
                    delegate: ShapeDelegate(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade800,
                      shadow: false,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 600,
                    width: 600,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fromRect(
                          rect: const Offset(50, 50) & const Size(200, 200),
                          child: const _WindowCard(
                            delegate: ShapeDelegate(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Positioned.fromRect(
                          rect: const Offset(300, 50) & const Size(200, 200),
                          child: const _WindowCard(
                            delegate: ShapeDelegate(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Positioned.fromRect(
                          rect: const Offset(150, 300) & const Size(200, 200),
                          child: const _WindowCard(
                            delegate: ShapeDelegate(
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Positioned.fromRect(
                          rect: const Offset(400, 200) & const Size(200, 400),
                          child: _WindowCard(
                            delegate: ShapeDelegate(
                              color: Colors.orange,
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final ShapeDelegate delegate;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 16,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: Window(
          clipBehavior: Clip.none,
          delegate: delegate,
        ),
      );
}
