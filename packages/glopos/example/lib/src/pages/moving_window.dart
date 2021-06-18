import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

final _backgroundColor = Colors.grey.shade900;

class MovingWindowPage extends StatefulWidget {
  const MovingWindowPage({Key? key}) : super(key: key);

  @override
  _MovingWindowPageState createState() => _MovingWindowPageState();
}

class _MovingWindowPageState extends State<MovingWindowPage> {
  final _spotlight = Spotlight(position: const Offset(200, 200));

  Offset? _windowPosition;

  @override
  void dispose() {
    _spotlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Moving Window'),
        ),
        backgroundColor: _backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              _spotlight.position = constraints.biggest.center(Offset.zero);
            });

            _windowPosition ??= constraints.biggest.center(Offset.zero);

            return Scene(
              elements: [_spotlight],
              child: Stack(
                children: [
                  Positioned.fromRect(
                    rect: _windowPosition! & const Size(200, 200),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _windowPosition = _windowPosition! + details.delta;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Window(
                          delegate: SpotlightDelegate(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      );
}
