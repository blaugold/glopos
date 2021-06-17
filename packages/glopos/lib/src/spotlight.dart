import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'clipping.dart';
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

/// A box whose border and background are illuminated by [Spotlight]s.
class SpotlitBox extends StatelessWidget {
  /// Creates a box whose border and background are illuminated by [Spotlight]s
  /// in the [Scene] above this [Widget] in the tree.
  const SpotlitBox({
    Key? key,
    this.borderWidth = 2,
    this.borderColor,
    required this.backgroundColor,
    this.backgroundIllumination = 0,
    this.clipBehavior = Clip.hardEdge,
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

  /// The type of cliping this widget uses.
  final Clip clipBehavior;

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
        Positioned.fill(
          child: Window(
            clipBehavior: clipBehavior,
            delegate: const SpotlightDelegate(),
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
      ..add(DoubleProperty('backgroundIllumination', backgroundIllumination))
      ..add(DiagnosticsProperty('clipBehavior', clipBehavior));
  }
}

/// A widget whose shape is defined by a [ShapeBorder], It's border and
/// background are illuminated by [Spotlight]s.
class SpotlitShape extends StatelessWidget {
  /// Creates a widget whose shape is defined by a [ShapeBorder], It's border
  /// and background are illuminated by [Spotlight]s.
  const SpotlitShape({
    Key? key,
    required this.border,
    required this.backgroundColor,
    this.backgroundIllumination = 0,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  })  : assert(backgroundIllumination >= 0 && backgroundIllumination <= 1),
        super(key: key);

  /// The shape of the border.
  final ShapeBorder border;

  /// The [Color] of the background.
  final Color backgroundColor;

  /// The amount of light which is reflected by the background.
  final double backgroundIllumination;

  /// The type of cliping this widget uses.
  final Clip clipBehavior;

  /// The content of this box.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          // Background or Border
          Positioned.fill(
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: border,
                color: backgroundColor,
              ),
            ),
          ),

          // Spotlight
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeBorderClipper(shape: border),
              clipBehavior: clipBehavior,
              child: const Window(
                clipBehavior: Clip.none,
                delegate: SpotlightDelegate(),
              ),
            ),
          ),

          // // Content + Background
          ClipPath(
            clipper: InnerShapeBorderClipper(shape: border),
            clipBehavior: clipBehavior,
            child: Container(
              color: backgroundColor.withOpacity(1 - backgroundIllumination),
              child: child,
            ),
          ),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ShapeBorder>('border', border))
      ..add(ColorProperty('background', backgroundColor))
      ..add(DoubleProperty('backgroundIllumination', backgroundIllumination))
      ..add(DiagnosticsProperty('clipBehavior', clipBehavior));
  }
}
