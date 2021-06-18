import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'clipping.dart';
import 'core.dart';

/// A style which defines how a [Spotlight] looks.
@immutable
class SpotlightStyle with Diagnosticable {
  /// Creates a style which defines how a [Spotlight] looks.
  const SpotlightStyle({
    this.radius,
    this.gradient,
  });

  /// The default [SpotlightStyle] used by [Spotlight] when non is provided.
  static SpotlightStyle defaultStyle = SpotlightStyle(
    radius: 100,
    gradient: createDefaultGradient(Colors.white),
  );

  /// Returns a [RadialGradient] which works well as as radial light source
  /// with [color].
  static RadialGradient createDefaultGradient(Color color) =>
      RadialGradient(colors: [
        color,
        color.withOpacity(.25),
        color.withOpacity(0),
      ]);

  /// The radius of the [Spotlight].
  final double? radius;

  /// The [Gradient] to color the [Spotlight] with.
  final Gradient? gradient;

  /// Makes a copy of this style with the given values replacing existing
  /// values.
  SpotlightStyle copyWith({
    double? radius,
    Gradient? gradient,
  }) =>
      SpotlightStyle(
        radius: radius ?? this.radius,
        gradient: gradient ?? this.gradient,
      );

  /// Merges [other] into this instance by overwriting values in this instance
  /// with values from [other].
  SpotlightStyle merge(SpotlightStyle? other) => copyWith(
        radius: other?.radius,
        gradient: other?.gradient,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotlightStyle &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          gradient == other.gradient;

  @override
  int get hashCode => radius.hashCode ^ gradient.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('radius', radius))
      ..add(DiagnosticsProperty('gradient', gradient));
  }

  /// Linearly interpolates between two [SpotlightStyle]s.
  static SpotlightStyle? lerp(SpotlightStyle? a, SpotlightStyle? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    if (t == 0.0) {
      return a;
    }
    if (t == 1.0) {
      return b;
    }
    return SpotlightStyle(
      radius: lerpDouble(a.radius, b.radius, t),
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
    );
  }
}

/// A linear interpolation between a beginning and a ending [SpotlightStyle].
class SpotlightStyleTween extends Tween<SpotlightStyle> {
  /// Creates a linear interpolation between a beginning and a ending
  /// [SpotlightStyle].
  SpotlightStyleTween({
    SpotlightStyle? begin,
    SpotlightStyle? end,
  }) : super(begin: begin, end: end);

  @override
  SpotlightStyle lerp(double t) => SpotlightStyle.lerp(begin, end, t)!;
}

/// A [SceneElement] which represents a spotlight.
class Spotlight extends SceneElement {
  /// Creates a [SceneElement] which represents a spotlight.
  Spotlight({
    bool? enabled,
    Offset? position,
    SpotlightStyle? style,
  })  : _style = style ?? SpotlightStyle.defaultStyle,
        super(enabled: enabled, position: position);

  /// The [SpotlightStyle] of this spotlight.
  SpotlightStyle get style => _style;
  SpotlightStyle _style;

  set style(SpotlightStyle radius) {
    if (radius != _style) {
      _style = radius;
      notifyListeners();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('style', style));
  }
}

/// [WindowDelegate] which implements the visual representation for
/// [Spotlight].
class SpotlightDelegate extends WindowDelegate<Spotlight> {
  /// Creates a [WindowDelegate] which implements the visual representation
  /// for [Spotlight].
  const SpotlightDelegate({this.style});

  /// A [SpotlightStyle] which overrides [Spotlight.style].
  final SpotlightStyle? style;

  @override
  bool shouldRebuild(covariant SpotlightDelegate oldDelegate) =>
      style != oldDelegate.style;

  @override
  Widget buildRepresentation(BuildContext context, Spotlight element) {
    final style = element.style.merge(this.style);
    final diameter = style.radius! * 2;

    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.gradient,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('style', style));
  }
}

/// Widget which paints a [Spotlight] decoration.
///
/// See also:
///
///  * [AnimatedSpotlightDecoration] for an implicitly animated version of
///    this [Widget].
class SpotlightDecoration extends StatelessWidget {
  /// Creates a widget which paints a [Spotlight] decoration.
  const SpotlightDecoration({
    Key? key,
    required this.decoration,
    this.backgroundIllumination,
    this.clipBehavior = Clip.hardEdge,
    this.spotlightStyle,
    required this.child,
  })  : assert(decoration is BoxDecoration || decoration is ShapeDecoration),
        assert(backgroundIllumination == null ||
            backgroundIllumination >= 0 && backgroundIllumination <= 1),
        super(key: key);

  /// Description of the decoration to paint.
  ///
  /// The provided value must either be a [BoxDecoration] or a
  /// [ShapeDecoration].
  final Decoration decoration;

  /// The amount of light which is reflected by the background.
  final double? backgroundIllumination;

  /// The type of cliping this widget uses.
  final Clip clipBehavior;

  /// A [SpotlightStyle] which overrides [Spotlight.style].
  final SpotlightStyle? spotlightStyle;

  /// The [Widget] to decorate.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var decoration = this.decoration;
    if (decoration is BoxDecoration) {
      if (decoration.isSimpleRectangle) {
        return Stack(
          children: [
            // Border area
            Positioned.fill(
              child: DecoratedBox(
                decoration: decoration,
              ),
            ),

            // Spotlight
            Positioned.fill(
              child: Window(
                clipBehavior: clipBehavior,
                delegate: SpotlightDelegate(
                  style: spotlightStyle,
                ),
              ),
            ),

            // Content + Background
            Container(
              color: decoration.color
                  ?.withOpacity(1 - (backgroundIllumination ?? 0)),
              margin: decoration.padding,
              child: child,
            ),
          ],
        );
      } else {
        decoration = ShapeDecoration.fromBoxDecoration(decoration);
      }
    }

    if (decoration is ShapeDecoration) {
      // When painting the border with ContinuousRectangleBorder there is some
      // incongruity with the clip shape. This padding around the border
      // corrects for that. Not sure what is going on here exactly.
      var borderPadding = EdgeInsets.zero;
      if (decoration.shape is ContinuousRectangleBorder) {
        borderPadding = const EdgeInsets.all(1);
      }

      return Stack(
        children: [
          // Background or Border
          Positioned.fill(
            child: Padding(
              padding: borderPadding,
              child: DecoratedBox(
                decoration: decoration,
              ),
            ),
          ),

          // Spotlight
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeBorderClipper(
                shape: decoration.shape,
                textDirection: Directionality.of(context),
              ),
              clipBehavior: clipBehavior,
              child: Window(
                clipBehavior: Clip.none,
                delegate: SpotlightDelegate(
                  style: spotlightStyle,
                ),
              ),
            ),
          ),

          // // Content + Background
          ClipPath(
            clipper: InnerShapeBorderClipper(
              shape: decoration.shape,
              textDirection: Directionality.of(context),
            ),
            clipBehavior: clipBehavior,
            child: Container(
              padding: decoration.padding,
              color: decoration.color
                  ?.withOpacity(1 - (backgroundIllumination ?? 0)),
              child: child,
            ),
          ),
        ],
      );
    }

    throw UnsupportedError(
      'Decoration of type ${decoration.runtimeType} is not supported',
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('decoration', decoration))
      ..add(DoubleProperty('backgroundIllumination', backgroundIllumination))
      ..add(DiagnosticsProperty('clipBehavior', clipBehavior))
      ..add(DiagnosticsProperty('spotlightStyle', spotlightStyle));
  }
}

extension on BoxDecoration {
  /// Wether this decoration describes a rectangle without rounded borders.
  bool get isSimpleRectangle =>
      shape == BoxShape.rectangle &&
      (borderRadius == null || borderRadius == BorderRadius.zero);
}

/// An implicitly animated [Widget] which paints a [Spotlight] decoration.
///
/// See also:
///
///  * [SpotlightDecoration] for a non-animated version of this [Widget].
class AnimatedSpotlightDecoration extends ImplicitlyAnimatedWidget {
  /// Creates an implicitly animated [Widget] which paints a [Spotlight]
  /// decoration.
  const AnimatedSpotlightDecoration({
    Key? key,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
    required this.decoration,
    this.backgroundIllumination = 0,
    this.clipBehavior = Clip.hardEdge,
    this.spotlightStyle,
    required this.child,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  /// Description of the decoration to paint.
  ///
  /// The provided value must either be a [BoxDecoration] or a
  /// [ShapeDecoration].
  final Decoration decoration;

  /// The amount of light which is reflected by the background.
  final double backgroundIllumination;

  /// The type of cliping this widget uses.
  final Clip clipBehavior;

  /// A [SpotlightStyle] which overrides [Spotlight.style].
  final SpotlightStyle? spotlightStyle;

  /// The [Widget] to decorate.
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedSpotlightDecorationState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('decoration', decoration))
      ..add(DoubleProperty('backgroundIllumination', backgroundIllumination))
      ..add(EnumProperty('clipBehavior', clipBehavior))
      ..add(DiagnosticsProperty('spotlightStyle', spotlightStyle));
  }
}

class _AnimatedSpotlightDecorationState
    extends AnimatedWidgetBaseState<AnimatedSpotlightDecoration> {
  Tween<Decoration>? _decorationTween;
  Tween<double>? _backgroundIlluminationTween;
  Tween<SpotlightStyle>? _spotlightStyleTween;

  @override
  Widget build(BuildContext context) => SpotlightDecoration(
        decoration: _decorationTween!.evaluate(animation),
        backgroundIllumination:
            _backgroundIlluminationTween?.evaluate(animation),
        clipBehavior: widget.clipBehavior,
        spotlightStyle: _spotlightStyleTween?.evaluate(animation),
        child: widget.child,
      );

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _decorationTween = visitor(
      _decorationTween,
      widget.decoration,
      (dynamic value) => DecorationTween(begin: value as Decoration?),
    ) as Tween<Decoration>?;

    _backgroundIlluminationTween = visitor(
      _backgroundIlluminationTween,
      widget.backgroundIllumination,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;

    _spotlightStyleTween = visitor(
      _spotlightStyleTween,
      widget.spotlightStyle,
      (dynamic value) => SpotlightStyleTween(begin: value as SpotlightStyle?),
    ) as Tween<SpotlightStyle>?;
  }
}
