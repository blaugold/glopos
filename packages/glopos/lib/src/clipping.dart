import 'package:flutter/widgets.dart';

/// A [CustomClipper] that clips to the inner path of a [ShapeBorder].
class InnerShapeBorderClipper extends CustomClipper<Path> {
  /// Creates a [ShapeBorder] clipper.
  ///
  /// The [shape] argument must not be null.
  ///
  /// The [textDirection] argument must be provided non-null if [shape]
  /// has a text direction dependency (for example if it is expressed in terms
  /// of "start" and "end" instead of "left" and "right"). It may be null if
  /// the border will not need the text direction to paint itself.
  const InnerShapeBorderClipper({
    required this.shape,
    this.textDirection,
  });

  /// The shape border whose outer path this clipper clips to.
  final ShapeBorder shape;

  /// The text direction to use for getting the outer path for [shape].
  ///
  /// [ShapeBorder]s can depend on the text direction (e.g having a "dent"
  /// towards the start of the shape).
  final TextDirection? textDirection;

  /// Returns the outer path of [shape] as the clip.
  @override
  Path getClip(Size size) =>
      shape.getInnerPath(Offset.zero & size, textDirection: textDirection);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != InnerShapeBorderClipper) {
      return true;
    }
    final typedOldClipper = oldClipper as InnerShapeBorderClipper;

    return typedOldClipper.shape != shape ||
        typedOldClipper.textDirection != textDirection;
  }
}
