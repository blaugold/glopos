import 'package:flutter/material.dart';

import 'moving_window.dart';
import 'spotlight_demo.dart';

final _backgroundColor = Colors.grey.shade900;

class DemoPageLink extends StatelessWidget {
  const DemoPageLink({
    Key? key,
    required this.title,
    required this.page,
  }) : super(key: key);

  final String title;

  final Widget Function(BuildContext) page;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: page,
            ),
          );
        },
      );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('glopos Demo'),
        ),
        backgroundColor: _backgroundColor,
        body: ListView(
          children: [
            DemoPageLink(
              title: 'Spotlight',
              page: (context) => const SpotlightDemo(),
            ),
            DemoPageLink(
              title: 'Moving Window',
              page: (context) => const MovingWindowDemo(),
            ),
          ],
        ),
      );
}
