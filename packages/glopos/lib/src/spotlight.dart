import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core.dart';

/// A [SceneElement] which represents a spotlight.
class Spotlight extends SceneElement {
  /// Creates a [SceneElement] which represents a spotlight.
  Spotlight({
    bool? enabled,
    Offset? position,
    double radius = 200,
    Color color = Colors.white,
  })  : _radius = radius,
        _color = color,
        super(
          enabled: enabled,
          position: position,
        );

  /// The radius of this spotlight.
  double get radius => _radius;
  double _radius;

  set radius(double radius) {
    if (radius != _radius) {
      _radius = radius;
      notifyListeners();
    }
  }

  /// The [Color] of this spotlight.
  Color get color => _color;
  Color _color;

  set color(Color color) {
    if (color != _color) {
      _color = color;
      notifyListeners();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('radius', radius))
      ..add(ColorProperty('color', color));
  }
}

/// [Widget] which binds the position of a [Spotlight] to the hover position
/// of the mouse.
///
/// The [spotlight] is enabled when the mouse enters the space occupied by
/// [child] and disabled when the mouse leaves the space.
class BindSpotlightToMouse extends StatelessWidget {
  /// Creates a [Widget] which binds the position of a [Spotlight] to the hover
  /// position of the mouse.
  const BindSpotlightToMouse({
    Key? key,
    required this.spotlight,
    required this.child,
  }) : super(key: key);

  /// The [Spotlight] to bind to the hover position of the mouse.
  final Spotlight spotlight;

  /// The [Widget] which defines the area in which the mouse is tracked.
  ///
  /// The [spotlight] is enabled while the mouse is within the area of this
  /// [Widget].
  final Widget child;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (event) => spotlight.position = event.localPosition,
        onEnter: (_) => spotlight.enabled = true,
        onExit: (_) => spotlight.enabled = false,
        child: child,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Spotlight>('spotlight', spotlight));
  }
}

/// [WindowDelegate] which implements the visual representation for
/// [Spotlight].
class SpotlightDelegate extends WindowDelegate<Spotlight> {
  /// Creates a [WindowDelegate] which implements the visual representation
  /// for [Spotlight].
  const SpotlightDelegate();

  @override
  Widget buildRepresentation(BuildContext context, Spotlight element) {
    final diameter = element.radius * 2;

    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            element.color,
            element.color.withOpacity(.25),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// A box whose border and background are illuminated by [Spotlight]s in the
/// [Scene] above this [Widget] in the tree.
class SpotlitBox extends StatelessWidget {
  /// Creates a box whose border and background are illuminated by [Spotlight]s
  /// in the [Scene] above this [Widget] in the tree.
  const SpotlitBox({
    Key? key,
    this.borderWidth = 2,
    this.borderColor,
    required this.backgroundColor,
    this.backgroundIllumination = 0,
    required this.child,
  })  : assert(borderWidth >= 0),
        assert(backgroundIllumination >= 0 && backgroundIllumination <= 1),
        super(key: key);

  /// The width of the border.
  final double borderWidth;

  /// The [Color] of the border, when it is not illuminated.
  final Color? borderColor;

  /// The [Color] of the background.
  final Color backgroundColor;

  /// The amount of light which is reflected by the background.
  final double backgroundIllumination;

  /// The content of this box.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    BoxBorder? border;
    if (borderColor != null) {
      border = Border.all(
        color: borderColor!,
        width: borderWidth,
      );
    }

    return Stack(
      children: [
        // Border area
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
            ),
          ),
        ),

        // Spotlight
        const Positioned.fill(
          child: Window(
            delegate: SpotlightDelegate(),
          ),
        ),

        // Content + Background
        Container(
          color: backgroundColor.withOpacity(1 - backgroundIllumination),
          margin: EdgeInsets.all(borderWidth),
          child: child,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('borderWidth', borderWidth))
      ..add(ColorProperty('borderColor', borderColor))
      ..add(ColorProperty('background', backgroundColor))
      ..add(DoubleProperty('backgroundIllumination', backgroundIllumination));
  }
}
