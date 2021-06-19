import 'package:flutter/material.dart';
import 'package:glopos/glopos.dart';

class Shape<T extends SizeLayoutDelegate>
    extends LayoutDelegateSceneElement<T> {
  Shape({
    required T layoutDelegate,
    required this.color,
    required this.shape,
    this.shadow = true,
  }) : super(layoutDelegate: layoutDelegate);

  final Color color;

  final ShapeBorder shape;

  final bool shadow;
}

class ShapeDelegate extends WindowDelegate<Shape> {
  const ShapeDelegate({
    this.color,
    this.shape,
    this.shadow,
  });

  final Color? color;

  final ShapeBorder? shape;

  final bool? shadow;

  @override
  bool shouldRebuild(covariant ShapeDelegate oldDelegate) =>
      color != oldDelegate.color ||
      shape != oldDelegate.shape ||
      shadow != oldDelegate.shadow;

  @override
  Widget build(
    BuildContext context,
    Shape element,
  ) =>
      GestureDetector(
        onPanUpdate: (details) {
          final Object layoutDelegate = element.layoutDelegate;
          if (layoutDelegate is PositionLayoutDelegate) {
            layoutDelegate.position += details.delta;
          }
        },
        child: Material(
          shape: shape ?? element.shape,
          color: color ?? element.color,
          elevation: shadow ?? element.shadow ? 8 : 0,
          child: LayoutDelegateBuilder<SizeLayoutDelegate>(
            element: element,
            builder: (context, layoutDelegate, _) => SizedBox.fromSize(
              size: layoutDelegate.size,
            ),
          ),
        ),
      );
}
