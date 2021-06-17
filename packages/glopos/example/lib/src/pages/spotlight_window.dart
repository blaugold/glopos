import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

final _backgroundColor = Colors.grey.shade900;
final _borderColor = Colors.grey.shade800;
final _textColor = Colors.grey.shade200;

class SpotlightMenuPage extends StatefulWidget {
  const SpotlightMenuPage({Key? key}) : super(key: key);

  @override
  _SpotlightMenuPageState createState() => _SpotlightMenuPageState();
}

class _SpotlightMenuPageState extends State<SpotlightMenuPage> {
  final spotlight = Spotlight();

  @override
  void dispose() {
    spotlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Spotlight Menu'),
        ),
        backgroundColor: _backgroundColor,
        body: SizedBox.expand(
          child: BindElementToMouse(
            element: spotlight,
            child: Scene(
              elements: [spotlight],
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    MenuItem(title: Text('Language')),
                    MenuItem(title: Text('Devices')),
                    MenuItem(title: Text('System')),
                    MenuItem(title: Text('Security')),
                    MenuItem(title: Text('Printers')),
                    MenuItem(title: Text('Network')),
                    MenuItem(title: Text('Storage')),
                    MenuItem(title: Text('Energy')),
                    MenuItem(title: Text('Updates')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class MenuItem extends StatelessWidget {
  const MenuItem({
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
