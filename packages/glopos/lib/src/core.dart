import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
        _position = ValueNotifier(position ?? Offset.zero);

  // ignore: diagnostic_describe_all_properties
  final _layerLink = LayerLink();

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
  ///
  /// Listeners of this element are not notified when [position] changes. To
  /// listen to changes of [position] use [addPositionListener].
  Offset get position => _position.value;
  final ValueNotifier<Offset> _position;

  set position(Offset position) {
    if (position != _position.value) {
      _position.value = position;
    }
  }

  /// Adds [listener] which is notified when [position] changes.
  void addPositionListener(VoidCallback listener) {
    _position.addListener(listener);
  }

  /// Removes [listener] which was registered through [addPositionListener].
  void removePositionListener(VoidCallback listener) {
    _position.removeListener(listener);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            for (final element in elements)
              ValueListenableBuilder<Offset>(
                valueListenable: element._position,
                builder: (context, position, _) => Positioned.fromRect(
                  rect: position & Size.zero,
                  child: CompositedTransformTarget(
                    link: element._layerLink,
                  ),
                ),
              ),
            child,
          ],
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

/// Delegate for [Window] to provide visual representations for [SceneElement]s.
abstract class WindowDelegate<T extends SceneElement> {
  /// Const constructor for subclasses.
  const WindowDelegate();

  /// Returns whether [element] should be shown in the [Window].
  ///
  /// The default implementation uses [SceneElement.enabled] to determine
  /// whether to show a [SceneElement].
  ///
  /// If this method returns `false` the other methods won't be called for that
  /// [SceneElement].
  bool showElement(T element) => element.enabled;

  /// Returns the alignment of the [Widget] returned from [buildRepresentation]
  /// with [SceneElement.position].
  AlignmentGeometry alignment(T element) => Alignment.center;

  /// Returns a number which is used to determine the order in which multiple
  /// [SceneElement]s inside of a [Window] are painted.
  ///
  /// [SceneElement]s with a smaller paint order appear behind [SceneElement]s
  /// with a greater paint order. [SceneElement]s with the same paint order
  /// are painted in the order in which they appear in [Scene.elements].
  int paintOrder(T element) => 0;

  /// Returns a [Widget] which gives [element] a visual representation in the
  /// [Window].
  ///
  /// This method is called when an [element] needs a visual representation for
  /// the first time and whenever the [element] notifies its listeners that it
  /// has changed.
  Widget buildRepresentation(BuildContext context, T element);
}

/// A window into a [Scene] from a location in the widget tree.
class Window<T extends SceneElement> extends StatefulWidget {
  /// Creates a window into a [Scene] from a location in the widget tree.
  const Window({
    Key? key,
    required this.delegate,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  /// The [WindowDelegate] which provides visual representations for this
  /// [Window]'s [SceneElement]s.
  final WindowDelegate<T> delegate;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  _WindowState<T> createState() => _WindowState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<WindowDelegate<T>>('delegate', delegate))
      ..add(EnumProperty<Clip>('clipBehavior', clipBehavior));
  }
}

class _WindowSceneElementState {
  _WindowSceneElementState({
    required this.listener,
  });

  final void Function() listener;

  bool show = true;

  int paintOrder = 0;

  Widget? widget;
}

class _WindowState<T extends SceneElement> extends State<Window<T>> {
  late List<T> _elementsInScene;
  final _elementStates = Map<T, _WindowSceneElementState>.identity();
  List<_WindowSceneElementState>? _orderedElementStates;
  bool _elementChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final oldElements = _elementStates.keys.toList();
    final currentElements =
        _elementsInScene = Scene.of(context).elements.whereType<T>().toList();

    for (final currentElement in currentElements) {
      // Element is not new.
      if (oldElements.contains(currentElement)) {
        continue;
      }

      _addElement(currentElement);
    }

    for (final oldElement in oldElements) {
      // Element has not been removed.
      if (currentElements.contains(oldElement)) {
        continue;
      }

      _removeElement(oldElement);
    }
  }

  @override
  void didUpdateWidget(covariant Window<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.delegate != oldWidget.delegate) {
      _elementStates.keys.forEach(_updateElementState);
    }
  }

  @override
  void dispose() {
    _elementStates.keys.forEach(_removeElementListener);
    super.dispose();
  }

  void _addElement(T element) {
    void updateElementState() => _updateElementState(element);
    _installElementListener(element, updateElementState);
    updateElementState();
    _markElementOrderChanged();
  }

  void _removeElement(T element) {
    _removeElementListener(element);
    _elementStates.remove(element);
    _markElementOrderChanged();
  }

  void _installElementListener(T element, void Function() listener) {
    _elementStates[element] = _WindowSceneElementState(listener: listener);
    element.addListener(listener);
  }

  void _removeElementListener(T element) {
    final state = _elementStates[element]!;
    element.removeListener(state.listener);
  }

  void _updateElementState(T element) {
    final state = _elementStates[element]!;

    final show = widget.delegate.showElement(element);
    if (state.show != show) {
      state.show = show;
      _markElementOrderChanged();
    }

    if (!state.show) {
      return;
    }

    final paintOrder = widget.delegate.paintOrder(element);
    if (state.paintOrder != paintOrder) {
      state.paintOrder = paintOrder;
      _markElementOrderChanged();
    }

    final alignment =
        widget.delegate.alignment(element).resolve(Directionality.of(context));

    state.widget = OverflowBox(
      key: ValueKey(element),
      minHeight: 0,
      minWidth: 0,
      maxHeight: double.infinity,
      maxWidth: double.infinity,
      child: CompositedTransformFollower(
        link: element._layerLink,
        followerAnchor: alignment,
        child: widget.delegate.buildRepresentation(context, element),
      ),
    );

    _markElementStateChanged();
  }

  void _markElementStateChanged() {
    if (_elementChanged) {
      return;
    }

    setState(() {
      _elementChanged = true;
    });
  }

  void _markElementOrderChanged() {
    if (_orderedElementStates == null) {
      return;
    }

    setState(() {
      _orderedElementStates = null;
    });
  }

  List<Widget> get _children {
    _ensureOrderedElementStates();
    return _orderedElementStates!.map((element) => element.widget!).toList();
  }

  void _ensureOrderedElementStates() {
    if (_orderedElementStates != null) {
      return;
    }

    final elementEntries = _elementStates.entries
        .where((element) => element.value.show)
        .toList()
          ..sort((a, b) => _compareElementForPaintOrder(a.key, b.key));

    _orderedElementStates =
        elementEntries.map((element) => element.value).toList();
  }

  int _compareElementForPaintOrder(T a, T b) {
    final result =
        widget.delegate.paintOrder(a) - widget.delegate.paintOrder(b);

    // If the elements have the same paint order, fallback to the
    // order of elements in the scene.
    if (result == 0) {
      return _elementsInScene.indexOf(a) - _elementsInScene.indexOf(b);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    _elementChanged = false;

    Widget child = Stack(
      children: _children,
    );

    if (widget.clipBehavior != Clip.none) {
      child = ClipRect(
        clipBehavior: widget.clipBehavior,
        child: child,
      );
    }

    return child;
  }
}
