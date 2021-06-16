import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

final _backgroundColor = Colors.grey.shade900;
final _borderColor = Colors.grey.shade800;
final _textColor = Colors.grey.shade200;

class SpotlightDemo extends StatefulWidget {
  const SpotlightDemo({Key? key}) : super(key: key);

  @override
  _SpotlightDemoState createState() => _SpotlightDemoState();
}

class _SpotlightDemoState extends State<SpotlightDemo> {
  final spotlight = Spotlight();

  @override
  void dispose() {
    spotlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Spotlight'),
        ),
        backgroundColor: _backgroundColor,
        body: SizedBox.expand(
          child: BindSpotlightToMouse(
            spotlight: spotlight,
            child: Scene(
              elements: [spotlight],
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _Panel(title: Text('Language')),
                    _Panel(title: Text('Devices')),
                    _Panel(title: Text('System')),
                    _Panel(title: Text('Security')),
                    _Panel(title: Text('Printers')),
                    _Panel(title: Text('Network')),
                    _Panel(title: Text('Storage')),
                    _Panel(title: Text('Energy')),
                    _Panel(title: Text('Updates')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({
    Key? key,
    required this.title,
  }) : super(key: key);

  final Widget title;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 80,
        width: 260,
        child: SpotlitBox(
          backgroundColor: _backgroundColor,
          backgroundIllumination: .05,
          borderColor: _borderColor,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: _textColor,
              ),
              child: title,
            ),
          ),
        ),
      );
}
