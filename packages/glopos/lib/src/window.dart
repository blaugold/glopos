import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'scene.dart';

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
  }) : super(key: key);

  /// The [WindowDelegate] which provides visual representations for this
  /// [Window]'s [SceneElement]s.
  final WindowDelegate<T> delegate;

  @override
  _WindowState<T> createState() => _WindowState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<WindowDelegate<T>>('delegate', delegate));
  }
}

class _WindowSceneElementState {
  _WindowSceneElementState({
    required this.listener,
  });

  final void Function() listener;

  bool show = true;

  int paintOrder = 0;

  late Widget widget;
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

    state.widget = _WindowPositioned(
      key: ValueKey(element),
      alignment: alignment,
      scenePosition: element.position,
      child: widget.delegate.buildRepresentation(context, element),
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

  List<Widget> get _widgets {
    _ensureOrderedElementStates();
    return _orderedElementStates!.map((element) => element.widget).toList();
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
    return _WindowLayout(children: _widgets);
  }
}

/// Layout which positions its children in the [Scene] coordinate system.
///
/// The [children] of this widget must use [_WindowPositioned] to position
/// them self.
class _WindowLayout extends MultiChildRenderObjectWidget {
  /// Creates a layout which positions its children in the [Scene] coordinate
  /// system.
  _WindowLayout({
    Key? key,
    required List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderWindowLayout();
}

/// Widget to position a [child] in the [Scene] coordinate system in a
/// [_WindowLayout].
class _WindowPositioned extends ParentDataWidget<_WindowLayoutParentData> {
  /// Creates a widget to position a [child] in the [Scene] coordinate system
  /// in a [_WindowLayout].
  const _WindowPositioned({
    Key? key,
    required this.scenePosition,
    required this.alignment,
    required Widget child,
  }) : super(key: key, child: child);

  /// The position of [child] in the [Scene] coordinate system.
  final Offset scenePosition;

  /// The alignment of [child] on [scenePosition].
  final Alignment alignment;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _WindowLayoutParentData;

    if (parentData._scenePosition != scenePosition ||
        parentData._alignment != alignment) {
      parentData
        .._scenePosition = scenePosition
        .._alignment = alignment
        .._isDirty = true;

      (renderObject.parent! as _RenderWindowLayout).markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _WindowLayout;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Offset>('scenePosition', scenePosition))
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment));
  }
}

/// The [ParentData] for children of [_WindowLayout].
class _WindowLayoutParentData extends ContainerBoxParentData<RenderBox> {
  bool _isDirty = true;
  bool _isVisible = true;
  Offset _scenePosition = Offset.zero;
  Alignment _alignment = Alignment.center;
}

/// [RenderBox] to position other [RenderBox]es in a [Scene] coordinate system.
class _RenderWindowLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin {
  @override
  final sizedByParent = true;

  @override
  void setupParentData(RenderObject child) {
    child.parentData = _WindowLayoutParentData();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    visitChildren((child) {
      (child.parentData! as _WindowLayoutParentData)._isDirty = true;
      child.layout(BoxConstraints.loose(Size.infinite));
    });
  }

  Matrix4 _calculateSceneToWindowTransform() {
    final sceneRenderObject = _findSceneRenderObject();
    return Matrix4.inverted(getTransformTo(sceneRenderObject));
  }

  void _updateChildren() {
    late final sceneToWindow = _calculateSceneToWindowTransform();

    visitChildren((child) {
      final parentData = child.parentData! as _WindowLayoutParentData;
      if (parentData._isDirty) {
        _updateChild(child as RenderBox, sceneToWindow);
      }
    });
  }

  void _updateChild(RenderBox child, Matrix4 sceneToWindow) {
    final parentData = child.parentData! as _WindowLayoutParentData;

    final localPosition =
        MatrixUtils.transformPoint(sceneToWindow, parentData._scenePosition);
    final alignmentOffset = parentData._alignment.alongSize(child.size);

    final offset = localPosition - alignmentOffset;
    final childRect = offset & child.size;
    final isVisible = !paintBounds.intersect(childRect).isEmpty;

    parentData
      ..offset = offset
      .._isVisible = isVisible
      .._isDirty = false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _updateChildren();

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _WindowLayoutParentData;
      if (childParentData._isVisible) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    _updateChildren();

    var child = lastChild;
    while (child != null) {
      final childParentData = child.parentData! as _WindowLayoutParentData;
      if (childParentData._isVisible) {
        final isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (result, transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    _updateChildren();
    super.applyPaintTransform(child, transform);
  }

  RenderScene _findSceneRenderObject() {
    var node = parent;
    while (node != null) {
      if (node is RenderScene) {
        return node;
      }
      node = node.parent;
    }

    throw FlutterError.fromParts([
      ErrorSummary('Could not find `Scene` in render tree'),
      ErrorHint(
        'Ensure that there is a `Scene` widget above the `WindowLayout` '
        'widget.',
      )
    ]);
  }
}
