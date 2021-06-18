import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

final _backgroundColor = Colors.grey.shade900;
final _borderColor = Colors.grey.shade800.withOpacity(.75);
final _textColor = Colors.grey.shade200;

final _spotlightStyleRed = SpotlightStyle(
  gradient: SpotlightStyle.createDefaultGradient(Colors.red),
);
final _spotlightStyleGreen = SpotlightStyle(
  gradient: SpotlightStyle.createDefaultGradient(Colors.green),
);
final _spotlightStyleBlue = SpotlightStyle(
  gradient: SpotlightStyle.createDefaultGradient(Colors.blue),
);
final _spotlightStyleOrange = SpotlightStyle(
  gradient: SpotlightStyle.createDefaultGradient(Colors.orange),
);
final _spotlightStylePink = SpotlightStyle(
  gradient: SpotlightStyle.createDefaultGradient(Colors.pink),
);

class SpotlightMenuPage extends StatefulWidget {
  const SpotlightMenuPage({Key? key}) : super(key: key);

  @override
  _SpotlightMenuPageState createState() => _SpotlightMenuPageState();
}

class _SpotlightMenuPageState extends State<SpotlightMenuPage> {
  final _spotlight = Spotlight();

  _MenuItemShape _shape = _MenuItemShape.circle;
  bool _showBorders = false;
  bool _showShadows = false;

  @override
  void dispose() {
    _spotlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Spotlight Menu'),
        ),
        backgroundColor: _backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Theme.of(context).colorScheme.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    DropdownButton<_MenuItemShape>(
                      value: _shape,
                      onChanged: (value) => setState(() {
                        _shape = value!;
                      }),
                      items: const [
                        DropdownMenuItem(
                          value: _MenuItemShape.circle,
                          child: Text('Circle'),
                        ),
                        DropdownMenuItem(
                          value: _MenuItemShape.rectangle,
                          child: Text('Rectangle'),
                        ),
                        DropdownMenuItem(
                          value: _MenuItemShape.roundedRectangle,
                          child: Text('Rounded rectangle'),
                        ),
                        DropdownMenuItem(
                          value: _MenuItemShape.continuosRoundedRectangle,
                          child: Text('Continuos rounded rectangle'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: CheckboxListTile(
                        value: _showBorders,
                        onChanged: (value) => setState(() {
                          _showBorders = value!;
                        }),
                        title: const Text('Show borders'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: CheckboxListTile(
                        value: _showShadows,
                        onChanged: (value) => setState(() {
                          _showShadows = value!;
                        }),
                        title: const Text('Show shadows'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BindElementToMouse(
                element: _spotlight,
                child: Scene(
                  elements: [_spotlight],
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 18,
                        clipBehavior: Clip.none,
                        children: [
                          MenuItem(
                            title: const Text('Language'),
                            spotlightStyle: _spotlightStyleRed,
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Devices'),
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('System'),
                            spotlightStyle: _spotlightStyleBlue,
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Security'),
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Printers'),
                            spotlightStyle: _spotlightStyleGreen,
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Network'),
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Storage'),
                            spotlightStyle: _spotlightStyleOrange,
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Energy'),
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                          MenuItem(
                            title: const Text('Updates'),
                            spotlightStyle: _spotlightStylePink,
                            shape: _shape,
                            showBorder: _showBorders,
                            showShadow: _showShadows,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

enum _MenuItemShape {
  circle,
  rectangle,
  roundedRectangle,
  continuosRoundedRectangle
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.title,
    required this.shape,
    this.showBorder = true,
    this.showShadow = false,
    this.spotlightStyle,
  }) : super(key: key);

  final Widget title;

  final _MenuItemShape shape;

  final bool showBorder;

  final bool showShadow;

  final SpotlightStyle? spotlightStyle;

  @override
  Widget build(BuildContext context) => AnimatedSpotlightDecoration(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        decoration: _buildDecoration(),
        backgroundIllumination: 0.05,
        spotlightStyle: spotlightStyle,
        clipBehavior: Clip.antiAliasWithSaveLayer,
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
      );

  Decoration _buildDecoration() {
    final side = BorderSide(
      color: showBorder ? _borderColor : _borderColor.withOpacity(0),
      width: 3,
    );

    final shadows = showShadow ? kElevationToShadow[12] : null;

    switch (shape) {
      case _MenuItemShape.circle:
        return ShapeDecoration(
          shape: CircleBorder(
            side: side,
          ),
          color: _backgroundColor,
          shadows: shadows,
        );
      case _MenuItemShape.rectangle:
        return ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: side,
          ),
          color: _backgroundColor,
          shadows: shadows,
        );
      case _MenuItemShape.roundedRectangle:
        return ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: side,
          ),
          color: _backgroundColor,
          shadows: shadows,
        );
      case _MenuItemShape.continuosRoundedRectangle:
        return ShapeDecoration(
          shape: ContinuousRectangleBorder(
            side: side,
            borderRadius: BorderRadius.circular(70),
          ),
          color: _backgroundColor,
          shadows: shadows,
        );
    }
  }
}
