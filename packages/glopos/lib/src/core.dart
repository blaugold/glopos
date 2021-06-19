import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// An element of a [Scene].
///
/// The visual representation of an element is determined by the
/// [WindowDelegate] of the [Window] in which it appears. This allows every
/// [Window] to show a different representation of the [Scene]. When the state
/// of a [SceneElement] changes and as a result [Window]s need to update the
/// elements representation, call [notifyListeners].
///
/// This class does not specify how a [SceneElement] is layed out within a
/// [Scene]. To implement your own [SceneElement] extend from one of the
/// subclasses which implement layout:
///
///  * [LayoutDelegateSceneElement]
///
/// See also:
///
///  * [Scene] for the [Widget] which establishes a coordinate system and
///    a scope for [SceneElement]s in it's subtree.
///  * [Window] for the [Widget] wich paints the [SceneElement]s of the [Scene]
///    above it.
///  * [WindowDelegate] for the object which provides the visual representation
///    of [SceneElement]s.
abstract class SceneElement extends ChangeNotifier with Diagnosticable {
  /// Constructor for subclasses.
  SceneElement({bool? enabled}) : _enabled = enabled ?? true;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('layerLink', _layerLink))
      ..add(DiagnosticsProperty('enabled', enabled));
  }
}

/// Delegate which determines the layout of a [LayoutDelegateSceneElement] in
/// the [Scene].
///
/// Implementations of this class layout their [SceneElement] by returning a
/// [Widget] from [buildPositioned] which is placed in a [Stack]. This [Stack]
/// is positioned at the [Scene] coordinate systems origin.
///
/// When the state of a delegate changes and as a result the [Widget]s returned
/// from [buildPositioned] and/or [buildContent] need to be rebuild, call
/// [notifyListeners].
///
/// See also:
///
///  * [PositionedBoxLayoutDelegate] for a layout delegate which lays out the
///    [SceneElement] at a specified position and size.
///  * [AlignedBoxLayoutDelegate] for a layout delegate which aligns the
///    [SceneElement] within the [Scene]s bounds, with a specified size.
abstract class SceneElementLayoutDelegate extends ChangeNotifier
    with Diagnosticable {
  /// Builds the [Widget] which positions the [SceneElement] in the [Scene]'s
  /// [Stack].
  ///
  /// The returned [Widget] must contain the given [content] [Widget] somewhere
  /// in it's subtree. The position and size of [content] determines the
  /// position and size of the [SceneElement] in the [Scene]. If [buildContent]
  /// returns `null`, [content] will take up all the available space. To
  /// determine the size of the [SceneElement] through a [Widget], implement
  /// [buildContent]. The result of [buildContent] will be contained in
  /// [content].
  Widget buildPositioned(BuildContext context, Widget content);

  /// Optionally builds the [Widget] whose size determines the size of the
  /// [SceneElement].
  Widget? buildContent(BuildContext context) => null;
}

/// A [SceneElementLayoutDelegate] which has a [position].
mixin PositionLayoutDelegate on SceneElementLayoutDelegate {
  /// The position of the [SceneElement] as an [Offset] from the origin of
  /// the [Scene] coordinates system.
  ///
  /// This [Offset] is not necessarily located at the top-left corner of the
  /// bounds of the [SceneElement]. An implementation of
  /// [SceneElementLayoutDelegate] could, for example, align [position] with the
  /// center of the [SceneElement].
  Offset get position => _position;
  Offset _position = Offset.zero;

  set position(Offset position) {
    if (_position != position) {
      _position = position;
      notifyListeners();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('position', position));
  }
}

/// A [SceneElementLayoutDelegate] which has a [size].
mixin SizeLayoutDelegate on SceneElementLayoutDelegate {
  /// The [Size] of the [SceneElement] in the [Scene] coordinate system.
  Size get size => _size;
  Size _size = Size.zero;

  set size(Size size) {
    if (_size != size) {
      _size = size;
      notifyListeners();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('size', size));
  }
}

/// A [SceneElementLayoutDelegate] which lays out the [SceneElement] at a
/// specified [position] in the [Scene] and with a specified [size].
///
/// The meaning of [position] can be changed through [alignment]. Per default
/// [position] is the [Offset] to the top-left corner of the bounds of the
/// [SceneElement]. By settings [alignment] to [Alignment.center], for example,
/// [position] will be the [Offset] to the center of element.
class PositionedBoxLayoutDelegate extends SceneElementLayoutDelegate
    with PositionLayoutDelegate, SizeLayoutDelegate {
  /// Creates a [SceneElementLayoutDelegate] which lays out the [SceneElement]
  /// at a specified [position] in the [Scene] and with a specified [size].
  PositionedBoxLayoutDelegate({
    Offset position = Offset.zero,
    AlignmentGeometry alignment = Alignment.topLeft,
    required Size size,
  }) : _alignment = alignment {
    this.position = position;
    this.size = size;
  }

  /// The alignment of [position] within [size].
  ///
  /// By settings [alignment] to [Alignment.center], for example, [position]
  /// will be the [Offset] to the center of element.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;

  set alignment(AlignmentGeometry alignment) {
    if (_alignment != alignment) {
      _alignment = alignment;
      notifyListeners();
    }
  }

  @override
  Widget buildPositioned(BuildContext context, Widget content) {
    final alignment = this.alignment.resolve(Directionality.of(context));
    final alignmentOffset = alignment.alongSize(size);
    final offset = position - alignmentOffset;

    return Positioned.fromRect(rect: offset & size, child: content);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('alignment', alignment));
  }
}

/// A [SceneElementLayoutDelegate] which aligns the [SceneElement] within the
/// [Scene]s bounds, with a specified size.
class AlignedBoxLayoutDelegate extends SceneElementLayoutDelegate
    with SizeLayoutDelegate {
  /// Creates a [SceneElementLayoutDelegate] which aligns the [SceneElement]
  /// within the [Scene]s bounds, with a specified size.
  AlignedBoxLayoutDelegate({
    AlignmentGeometry alignment = Alignment.center,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required Size size,
  })  : _alignment = alignment,
        _padding = padding {
    this.size = size;
  }

  /// The alignment of the [SceneElement] within the [Scene]'s bounds.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;

  set alignment(AlignmentGeometry alignment) {
    if (_alignment != alignment) {
      _alignment = alignment;
      notifyListeners();
    }
  }

  /// Padding to apply around the [SceneElement].
  ///
  /// The default is [EdgeInsets.zero].
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;

  set padding(EdgeInsetsGeometry padding) {
    if (_padding != padding) {
      _padding = padding;
      notifyListeners();
    }
  }

  @override
  Widget buildPositioned(BuildContext context, Widget content) => OverflowBox(
        maxHeight: double.infinity,
        maxWidth: double.infinity,
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: SizedBox.fromSize(
            size: size,
            child: content,
          ),
        ),
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('alignment', alignment))
      ..add(DiagnosticsProperty('padding', padding));
  }
}

/// A [SceneElement] which is layed out by a [SceneElementLayoutDelegate].
///
/// The [SceneElementLayoutDelegate] used by an instance of this class can
/// be replaced at runtime settings [layoutDelegate]. This will notify listeners
/// of [layoutDelegateChanges].
///
/// See also:
///
///  * [LayoutDelegateBuilder] for a [Widget] which rebuilds it's child when
///    a [LayoutDelegateSceneElement]'s [SceneElementLayoutDelegate] notifies
///    it's listeners or is replaced.
abstract class LayoutDelegateSceneElement<T extends SceneElementLayoutDelegate>
    extends SceneElement {
  /// Creates a [SceneElement] which is layed out by a
  /// [SceneElementLayoutDelegate].
  LayoutDelegateSceneElement({bool? enabled, required T layoutDelegate})
      : _layoutDelegate = ValueNotifier(layoutDelegate),
        super(enabled: enabled);

  /// A [ValueListenable] which notifies it's listeners when [layoutDelegate]
  /// changes.
  // ignore: diagnostic_describe_all_properties
  ValueListenable<T> get layoutDelegateChanges => _layoutDelegate;
  final ValueNotifier<T> _layoutDelegate;

  /// The [SceneElementLayoutDelegate] used by this element to lay itself out.
  ///
  /// When this property is set to a new value, [layoutDelegateChanges]
  /// notifies it's listeners.
  T get layoutDelegate => _layoutDelegate.value;

  set layoutDelegate(T layoutDelegate) =>
      _layoutDelegate.value = layoutDelegate;

  @override
  void dispose() {
    _layoutDelegate.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('layoutDelegate', layoutDelegate));
  }

  static Widget _buildSceneWidget(
    BuildContext context,
    LayoutDelegateSceneElement element,
  ) =>
      LayoutDelegateBuilder<SceneElementLayoutDelegate>(
        element: element,
        builder: (context, layoutDelegate, __) {
          final content = CompositedTransformTarget(
            link: element._layerLink,
            child: layoutDelegate.buildContent(context),
          );

          return layoutDelegate.buildPositioned(context, content);
        },
      );
}

/// A builder [Widget] which rebuilds it's child when it's
/// [LayoutDelegateSceneElement]'s [SceneElementLayoutDelegate] notifies it's
/// listeners or is replaced.
class LayoutDelegateBuilder<T extends SceneElementLayoutDelegate>
    extends StatelessWidget {
  /// Creates a builder [Widget] which rebuilds it's child when it's
  /// [LayoutDelegateSceneElement]'s [SceneElementLayoutDelegate] notifies it's
  /// listeners or is replaced.
  const LayoutDelegateBuilder({
    Key? key,
    required this.element,
    required this.builder,
    this.child,
  }) : super(key: key);

  /// The [LayoutDelegateSceneElement] whose [SceneElementLayoutDelegate]
  /// triggers rebuilds, when it notifies it's listeners or is replaced.
  final LayoutDelegateSceneElement<T> element;

  /// The builder which is called when the [LayoutDelegateSceneElement] notifies
  /// it's listeners or is replaced.
  // ignore: diagnostic_describe_all_properties
  final ValueWidgetBuilder<T> builder;

  /// Optional [Widget] which is passed to [builder] to prevent unnecessary
  /// rebuilds.
  final Widget? child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<T>(
        valueListenable: element.layoutDelegateChanges,
        builder: (context, layoutDelegate, child) => AnimatedBuilder(
          animation: layoutDelegate,
          builder: (context, child) => builder(context, layoutDelegate, child),
          child: child,
        ),
        child: child,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('element', element));
  }
}

/// Defines a coordinate system to position [SceneElement]s on and a scope
/// in which child [Window]s can find the [SceneElement]s to present.
///
/// The origin of the scene coordinate system is aligned with the top left
/// corner of the [Scene] widget. The size of a [Scene] is determined by it's
/// [child].
///
/// See also:
///  * [SceneElement] for the parent class of all [Scene.elements].
///  * [Window] for the [Widget] wich paints the [SceneElement]s of the [Scene]
///    above it.
///  * [WindowDelegate] for the object which provides the visual representation
///    of [SceneElement]s.
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
              if (element is LayoutDelegateSceneElement)
                LayoutDelegateSceneElement._buildSceneWidget(context, element),
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
        ),
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

/// A mixin for listening to [SceneElement]s from inside the [State] of a
/// [StatefulWidget].
///
/// Classes which use this mixin can override [didAddSceneElement],
/// [didChangeSceneElement] and [didRemoveSceneElement] to be notified of
/// the corresponding event.
mixin _SceneElementListenerMixin<T extends SceneElement,
    W extends StatefulWidget> on State<W> {
  /// The [SceneElement]s currently in the [Scene] above the [Widget].
  List<T> get sceneElements => _sceneElements;
  List<T> _sceneElements = [];

  final Map<T, void Function()> _listeners = {};

  /// Callback which is invoked when a new [element] has been added to
  /// [sceneElements].
  void didAddSceneElement(T element) {}

  /// Callback which is invoked when an [element] in [sceneElements] has
  /// changed.
  void didChangeSceneElement(T element) {}

  /// Callback which is invoked when an [element] has been removed from
  /// [sceneElements].
  void didRemoveSceneElement(T element) {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final oldElements = sceneElements;
    final elements = Scene.of(context).elements.whereType<T>().toList();

    if (oldElements == elements) {
      // No element has ben added or removed.
      return;
    }

    _sceneElements = elements;

    for (final element in elements) {
      // Element is new.
      if (!oldElements.contains(element)) {
        final listener =
            _listeners[element] = () => didChangeSceneElement(element);
        element.addListener(listener);
        didAddSceneElement(element);
      }
    }

    for (final oldElement in oldElements) {
      // Element has been removed.
      if (!elements.contains(oldElement)) {
        oldElement.removeListener(_listeners.remove(oldElement)!);
        didRemoveSceneElement(oldElement);
      }
    }
  }

  @override
  void dispose() {
    _listeners.forEach((element, void Function() listener) {
      element.removeListener(listener);
    });
    super.dispose();
  }
}

/// A delegate for [Window] to provide visual representations for
/// [SceneElement]s.
///
/// See also:
///
///  * [StatefulWindowDelegate] for the base class for delegates which need to
///    maintain state.
abstract class WindowDelegate<T extends SceneElement> with Diagnosticable {
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

  /// Returns an anchor that is positioned relatively to [element] and with
  /// which [windowElementAnchor] will be aligned to position the [Widget],
  /// representing [element], in the [Window].
  AlignmentGeometry sceneElementAnchor(T element) => Alignment.topLeft;

  /// Returns an anchor that is positioned relatively to the [Widget]
  /// representing [element] and which will be aligned with [sceneElementAnchor]
  /// to position the [Widget] in the [Window].
  AlignmentGeometry windowElementAnchor(T element) => Alignment.topLeft;

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
  Widget build(BuildContext context, T element);

  /// Returns whether the [SceneElement]s of the [Window] should be rebuild
  /// after the [oldDelegate] has been replaced with this instance.
  bool shouldRebuild(WindowDelegate<T> oldDelegate) => true;
}

/// A [WindowDelegate] which can maintain it's own state and request rebuilds
/// based on this state.
abstract class StatefulWindowDelegate<T extends SceneElement>
    extends WindowDelegate<T> {
  ValueChanged<T>? _rebuildElement;
  List<T>? _elements;

  /// The [SceneElement]s currently in the [Scene] above the [Window].
  List<T> get elements {
    if (kDebugMode) {
      _debugCheckIsRegistered();
    }

    return _elements!;
  }

  /// Callback which is invoked when a new [element] has been added to
  /// [elements].
  void didAddElement(T element) {}

  /// Callback which is invoked when an [element] in [elements] has
  /// changed.
  void didChangeElement(T element) {}

  /// Callback which is invoked when an [element] has been removed from
  /// [elements].
  void didRemoveElement(T element) {}

  /// Notifies [Window] that the visual representation of [element] needs to be
  /// be rebuild.
  void rebuildElement(T element) {
    if (kDebugMode) {
      _debugCheckIsRegistered();
      _debugCheckIsValidElement(element);
    }
    _rebuildElement!(element);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<T>('sceneElements', elements));
  }

  void _debugCheckIsRegistered() {
    if (_rebuildElement == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'StatefulWindowDelegate has not been provided to a Window.',
        ),
        ErrorHint(
          'Ensure that the delegate has been passed to a Window.',
        ),
      ]);
    }
  }

  void _debugCheckIsNotRegistered() {
    if (_rebuildElement != null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'StatefulWindowDelegate has already been provided to another Window.',
        ),
        ErrorHint(
          'Ensure that the delegate is not used with multiple Windows.',
        ),
      ]);
    }
  }

  void _debugCheckIsValidElement(T element) {
    if (!_elements!.contains(element)) {
      throw FlutterError.fromParts([
        ErrorSummary('The SceneElement is not available in the Window.'),
        ErrorHint(
          "Ensure that elements are removed from the delegate's state in "
          'didRemoveElement.',
        ),
      ]);
    }
  }
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
      ..add(DiagnosticsProperty('delegate', delegate))
      ..add(EnumProperty('clipBehavior', clipBehavior));
  }
}

class _WindowSceneElementState {
  bool show = true;
  int paintOrder = 0;
  Widget? widget;
  bool dirty = true;
}

class _WindowState<T extends SceneElement> extends State<Window<T>>
    with _SceneElementListenerMixin<T, Window<T>> {
  final _stackKey = GlobalKey();
  final _elementStates = Map<T, _WindowSceneElementState>.identity();
  List<_WindowSceneElementState>? _orderedElementStates;
  bool _elementNeedsRebuild = false;
  TextDirection? _textDirection;

  @override
  void initState() {
    super.initState();

    final delegate = widget.delegate;
    if (delegate is StatefulWindowDelegate<T>) {
      _registerStatefulDelegate(delegate);
    }
  }

  @override
  void didUpdateWidget(covariant Window<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final delegate = widget.delegate;
    final oldDelegate = oldWidget.delegate;
    if (delegate != oldDelegate) {
      if (oldDelegate is StatefulWindowDelegate<T>) {
        _unregisterStatefulDelegate(oldDelegate);
      }

      if (delegate is StatefulWindowDelegate<T>) {
        _registerStatefulDelegate(delegate);
      }

      if (delegate.shouldRebuild(oldDelegate)) {
        _markElementsNeedRebuild();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final oldTextDirection = _textDirection;
    _textDirection = Directionality.of(context);
    if (oldTextDirection != null && _textDirection != oldTextDirection) {
      _markElementsNeedRebuild();
    }
  }

  @override
  void dispose() {
    final delegate = widget.delegate;

    if (delegate is StatefulWindowDelegate<T>) {
      _unregisterStatefulDelegate(delegate);
    }

    super.dispose();
  }

  void _registerStatefulDelegate(StatefulWindowDelegate<T> delegate) {
    delegate
      .._debugCheckIsNotRegistered()
      .._rebuildElement = _markElementNeedsRebuild
      .._elements = sceneElements;

    sceneElements.forEach(delegate.didAddElement);
  }

  void _unregisterStatefulDelegate(StatefulWindowDelegate<T> delegate) {
    // The _rebuildElement function is replaced with a no-op, while
    // didRemoveElement is called for each element, to allow calls to
    // rebuildElement from didRemoveElement.
    delegate._rebuildElement = (element) {};
    sceneElements.forEach(delegate.didRemoveElement);

    delegate
      .._rebuildElement = null
      .._elements = null;
  }

  @override
  void didAddSceneElement(T element) {
    _elementStates[element] = _WindowSceneElementState();
    _markElementNeedsRebuild(element);
    _markElementOrderChanged();

    final delegate = widget.delegate;
    if (delegate is StatefulWindowDelegate<T>) {
      delegate
        .._elements = sceneElements
        ..didAddElement(element);
    }
  }

  @override
  void didChangeSceneElement(T element) {
    _markElementNeedsRebuild(element);

    final delegate = widget.delegate;
    if (delegate is StatefulWindowDelegate<T>) {
      delegate.didChangeElement(element);
    }
  }

  @override
  void didRemoveSceneElement(T element) {
    _elementStates.remove(element);
    _markElementOrderChanged();

    final delegate = widget.delegate;
    if (delegate is StatefulWindowDelegate<T>) {
      delegate
        .._elements = sceneElements
        ..didRemoveElement(element);
    }
  }

  void _markElementNeedsRebuild(T element) {
    _elementStates[element]!.dirty = true;

    if (_elementNeedsRebuild) {
      return;
    }

    setState(() {
      _elementNeedsRebuild = true;
    });
  }

  void _markElementsNeedRebuild() {
    for (final state in _elementStates.values) {
      state.dirty = true;
    }

    if (_elementNeedsRebuild) {
      return;
    }

    setState(() {
      _elementNeedsRebuild = true;
    });
  }

  void _rebuildElements() {
    if (_elementNeedsRebuild) {
      _elementStates.entries
          .where((element) => element.value.dirty)
          .forEach((entry) {
        _rebuildElement(entry);
        entry.value.dirty = false;
      });
      _elementNeedsRebuild = false;
    }
  }

  void _rebuildElement(MapEntry<T, _WindowSceneElementState> stateEntry) {
    final state = stateEntry.value;
    final element = stateEntry.key;

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

    final delegate = widget.delegate;
    final textDirection = Directionality.of(context);

    state.widget = OverflowBox(
      key: ValueKey(element),
      minHeight: 0,
      minWidth: 0,
      maxHeight: double.infinity,
      maxWidth: double.infinity,
      child: CompositedTransformFollower(
        link: element._layerLink,
        followerAnchor:
            delegate.windowElementAnchor(element).resolve(textDirection),
        targetAnchor:
            delegate.sceneElementAnchor(element).resolve(textDirection),
        // This builder ensures widget is rebuilt during hot reload.
        child: Builder(
          builder: (context) => widget.delegate.build(context, element),
        ),
      ),
    );
  }

  void _markElementOrderChanged() {
    if (_orderedElementStates == null) {
      return;
    }

    setState(() {
      _orderedElementStates = null;
    });
  }

  void _rebuildOrderedElementStates() {
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
      return sceneElements.indexOf(a) - sceneElements.indexOf(b);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    _rebuildElements();
    _rebuildOrderedElementStates();

    Widget child = Stack(
      key: _stackKey,
      children: _orderedElementStates!.map((state) => state.widget!).toList(),
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
