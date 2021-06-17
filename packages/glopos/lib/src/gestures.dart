import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'core.dart';

/// [Widget] which binds the position of a [SceneElement] to the hover position
/// of the mouse.
///
/// The [element] is enabled when the mouse enters the space occupied by
/// [child] and disabled when the mouse leaves the space.
class BindElementToMouse extends StatelessWidget {
  /// Creates a [Widget] which binds the position of a [SceneElement] to the
  /// hover position of the mouse.
  const BindElementToMouse({
    Key? key,
    required this.element,
    required this.child,
  }) : super(key: key);

  /// The [SceneElement] to bind to the hover position of the mouse.
  final SceneElement element;

  /// The [Widget] which defines the area in which the mouse is tracked.
  ///
  /// The [element] is enabled while the mouse is within the area of this
  /// [Widget].
  final Widget child;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (event) => element.position = event.localPosition,
        onEnter: (_) => element.enabled = true,
        onExit: (_) => element.enabled = false,
        child: child,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SceneElement>('element', element));
  }
}
