import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glopos/glopos.dart';

class WindowCardsPage extends StatefulWidget {
  const WindowCardsPage({Key? key}) : super(key: key);

  @override
  _WindowCardsPageState createState() => _WindowCardsPageState();
}

class _WindowCardsPageState extends State<WindowCardsPage> {
  final _element = WindowCardsElement();

  @override
  void dispose() {
    _element.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Window Cards'),
        ),
        backgroundColor: Colors.white,
        body: BindElementToMouse(
          element: _element,
          child: Scene(
            elements: [_element],
            child: Stack(
              children: [
                Positioned.fromRect(
                  rect: const Offset(50, 50) & const Size(200, 200),
                  child: WindowCard(
                    delegate: WindowCardsDelegate(
                      color: Colors.blue,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: const Offset(300, 50) & const Size(200, 200),
                  child: WindowCard(
                    delegate: WindowCardsDelegate(
                      color: Colors.red,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: const Offset(150, 300) & const Size(200, 200),
                  child: WindowCard(
                    delegate: WindowCardsDelegate(
                      color: Colors.green,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: const Offset(400, 200) & const Size(200, 400),
                  child: WindowCard(
                    delegate: WindowCardsDelegate(
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
      );
}

class WindowCard extends StatelessWidget {
  const WindowCard({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  final WindowCardsDelegate delegate;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 16,
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: Window(
          clipBehavior: Clip.none,
          delegate: delegate,
        ),
      );
}

class WindowCardsElement extends SceneElement {}

class WindowCardsDelegate extends WindowDelegate<WindowCardsElement> {
  WindowCardsDelegate({
    required this.color,
    this.shape = const CircleBorder(),
  });

  final Color color;

  final ShapeBorder shape;

  @override
  Widget buildRepresentation(
    BuildContext context,
    WindowCardsElement element,
  ) =>
      Material(
        shape: shape,
        color: color,
        elevation: 8,
        child: const SizedBox(
          width: 125,
          height: 125,
        ),
      );
}
