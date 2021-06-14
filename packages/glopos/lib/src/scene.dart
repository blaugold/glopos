import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'window.dart';

/// An element of a [Scene].
///
/// This class is meant to be extended by concrete scene elements.
///
/// The visual representation of an element is determined by the
/// [WindowDelegate] of the [Window] in which it appears. This allows every
/// [Window] to show a different representation of the [Scene].
///
/// [Window]s rebuild the visual representation of a [SceneElement] when the
/// element notifies it's listeners through [notifyListeners].
abstract class SceneElement extends ChangeNotifier with Diagnosticable {
  /// Constructor for subclasses.
  SceneElement({
    bool? enabled,
    Offset? position,
  })  : _enabled = enabled ?? true,
        _position = position ?? Offset.zero;

  /// Wether this element is enabled.
  ///
  /// How to interpret this option is up to the [WindowDelegate]. The default
  /// implementation of [WindowDelegate.showElement] uses this option to
  /// determine whether to show this element in the [Window].
  bool get enabled => _enabled;
  bool _enabled = true;

  set enabled(bool enabled) {
    if (enabled != _enabled) {
      _enabled = enabled;
      notifyListeners();
    }
  }

  /// The position of this element in the [Scene] coordinate system.
  Offset get position => _position;
  Offset _position;

  set position(Offset position) {
    if (position != _position) {
      _position = position;
      notifyListeners();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('enabled', enabled))
      ..add(DiagnosticsProperty<Offset>('position', position));
  }
}

/// Defines a coordinate system to position [SceneElement]s on and a scope
/// in which child [Window]s can find the [SceneElement]s to present.
///
/// The origin of the scene coordinate system is aligned with the top left
/// corner of the [Scene] widget. The size of a [Scene] is determined by it's
/// [child].
class Scene extends StatelessWidget {
  /// Creates a new [Scene], which defines a coordinate system to position
  /// [SceneElement]s on and a scope in which child [Window]s can find the
  /// [SceneElement]s to present.
  const Scene({
    Key? key,
    required this.elements,
    required this.child,
  }) : super(key: key);

  /// The [SceneElement]s of this scene.
  final List<SceneElement> elements;

  /// The widget whose subtree contains the [Window]s which display this scene's
  /// [elements].
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) => _SceneMarker(
        scene: this,
        child: _Scene(
          child: child,
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<SceneElement>('elements', elements));
  }

  /// Returns the nearest [Scene] above the given [context].
  static Scene of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_SceneMarker>()?.scene;

    if (result == null) {
      throw FlutterError.fromParts([
        ErrorSummary('Could not find an ancestor `Scene` widget'),
        ErrorHint(
          'Ensure there is a `Scene` widget above every `Window` widget',
        )
      ]);
    }

    return result;
  }
}

class _SceneMarker extends InheritedWidget {
  const _SceneMarker({
    Key? key,
    required this.scene,
    required Widget child,
  }) : super(key: key, child: child);

  // ignore: diagnostic_describe_all_properties
  final Scene scene;

  @override
  bool updateShouldNotify(_SceneMarker oldWidget) =>
      !const DeepCollectionEquality()
          .equals(scene.elements, oldWidget.scene.elements);
}

/// Marker [RenderObject] to identify [Scene] position in render tree.
class RenderScene extends RenderProxyBox {}

class _Scene extends SingleChildRenderObjectWidget {
  const _Scene({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => RenderScene();
}
