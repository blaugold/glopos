import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

class MovingWindowPage extends StatefulWidget {
  const MovingWindowPage({Key? key}) : super(key: key);

  @override
  _MovingWindowPageState createState() => _MovingWindowPageState();
}

class _MovingWindowPageState extends State<MovingWindowPage> {
  final _spotlight = Spotlight(position: const Offset(200, 200));

  var _windowPosition = const Offset(200, 200);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Moving Window'),
        ),
        body: Scene(
          elements: [_spotlight],
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: _windowPosition & const Size(200, 200),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _windowPosition += details.delta;
                    });
                  },
                  child: const RepaintBoundary(
                    child: ClipRect(
                      child: Window(
                        delegate: SpotlightDelegate(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
