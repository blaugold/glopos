// ignore_for_file: lines_longer_than_80_chars, diagnostic_describe_all_properties, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/glopos.dart';

void main() {
  group('WindowDelegate', () {
    test('default implementation of showElement returns element.enabled', () {
      final element = TestElement();
      final delegate = DefaultDelegate();

      expect(delegate.showElement(element), isTrue);
      element.enabled = false;
      expect(delegate.showElement(element), isFalse);
    });

    test(
      'default implementation of sceneElementAnchor returns Alignment.topLeft',
      () {
        final element = TestElement();
        final delegate = DefaultDelegate();

        expect(delegate.sceneElementAnchor(element), Alignment.topLeft);
      },
    );

    test(
      'default implementation of windowElementAnchor returns Alignment.topLeft',
      () {
        final element = TestElement();
        final delegate = DefaultDelegate();

        expect(delegate.windowElementAnchor(element), Alignment.topLeft);
      },
    );

    test('default implementation of paintOrder returns 0', () {
      final element = TestElement();
      final delegate = DefaultDelegate();

      expect(delegate.paintOrder(element), 0);
    });

    test('default implementation of shouldRebuild returns true', () {
      final delegate = DefaultDelegate();
      expect(delegate.shouldRebuild(delegate), true);
    });
  });

  group('Window', () {
    testWidgets(
      'throw error when Window is used without Scene',
      (tester) async {
        await tester.pumpWidget(const Directionality(
          textDirection: TextDirection.ltr,
          child: Window(
            delegate: TestDelegate(),
          ),
        ));

        expect(
          tester.takeException(),
          isA<FlutterError>().having(
            (e) => e.message,
            'message',
            'Could not find an ancestor `Scene` widget\n'
                'Ensure there is a `Scene` widget above every `Window` widget',
          ),
        );
      },
    );

    testWidgets(
      'rebuild elements when delegate changes',
      (tester) async {
        final delegate =
            ValueNotifier<WindowDelegate<TestElement>>(NoopDelegate());
        final element = TestElement();

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<WindowDelegate<TestElement>?>(
            valueListenable: delegate,
            builder: (context, delegate, _) => Scene(
              elements: [element],
              child: Window(
                delegate: delegate!,
              ),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsNothing);

        delegate.value = const TestDelegate();
        await tester.pump();

        expect(findTestElementWidget(), findsOneWidget);
      },
    );

    testWidgets(
      'skip rebuild of elements if shouldRebuild returns false',
      (tester) async {
        final delegate =
            ValueNotifier<WindowDelegate<TestElement>>(NoopDelegate());
        final element = TestElement();

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<WindowDelegate<TestElement>?>(
            valueListenable: delegate,
            builder: (context, delegate, _) => Scene(
              elements: [element],
              child: Window(
                delegate: delegate!,
              ),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsNothing);

        delegate.value = const TestDelegate(shouldRebuild: false);
        await tester.pump();

        expect(findTestElementWidget(), findsNothing);
      },
    );

    group('StatefulWindowDelegate', () {
      testWidgets(
        'call didAddElement for initial elements',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(
            onElementAdded: expectAsync1((addedElement) {
              expect(addedElement, element);
            }),
          );

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: Scene(
              elements: [element],
              child: Window(
                delegate: delegate,
              ),
            ),
          ));
        },
      );

      testWidgets(
        'call didAddElement when element is added to Scene',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(
            onElementAdded: expectAsync1((addedElement) {
              expect(addedElement, element);
            }),
          );
          final elements = ValueNotifier(<TestElement>[]);

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<List<TestElement>>(
              valueListenable: elements,
              builder: (context, elements, _) => Scene(
                elements: elements,
                child: Window(
                  delegate: delegate,
                ),
              ),
            ),
          ));

          elements.value = [element];
          await tester.pump();
        },
      );

      testWidgets(
        'call didChangeElement when element notifies listeners',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(
            onElementChanged: expectAsync1((addedElement) {
              expect(addedElement, element);
            }),
          );

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: Scene(
              elements: [element],
              child: Window(
                delegate: delegate,
              ),
            ),
          ));

          element.enabled = false;
        },
      );

      testWidgets(
        'call didRemoveElement for elements when Window is destroyed',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(
            onElementRemoved: expectAsync1((addedElement) {
              expect(addedElement, element);
            }),
          );
          final sceneExists = ValueNotifier(true);

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<bool>(
              valueListenable: sceneExists,
              builder: (context, value, _) => !value
                  ? Container()
                  : Scene(
                      elements: [element],
                      child: Window(
                        delegate: delegate,
                      ),
                    ),
            ),
          ));

          sceneExists.value = false;
        },
      );

      testWidgets(
        'call didRemoveElement when element is removed to Scene',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(
            onElementRemoved: expectAsync1((addedElement) {
              expect(addedElement, element);
            }),
          );
          final elements = ValueNotifier(<TestElement>[element]);

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<List<TestElement>>(
              valueListenable: elements,
              builder: (context, elements, _) => Scene(
                elements: elements,
                child: Window(
                  delegate: delegate,
                ),
              ),
            ),
          ));

          elements.value = [];
          await tester.pump();
        },
      );

      testWidgets(
        'rebuild element when delegate calls rebuildElement',
        (tester) async {
          final element = TestElement();
          final delegate = TestStatefulWindowDelegate(hideElements: true);

          await tester.pumpWidget(Directionality(
            textDirection: TextDirection.ltr,
            child: Scene(
              elements: [element],
              child: Window(
                delegate: delegate,
              ),
            ),
          ));

          expect(findTestElementWidget(), findsNothing);

          delegate
            ..hideElements = false
            ..rebuildElement(element);

          await tester.pump();

          expect(findTestElementWidget(), findsOneWidget);
        },
      );
    });

    testWidgets(
      'update element when element notifies listeners',
      (tester) async {
        final element = TestElement();

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [element],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsOneWidget);

        element.enabled = false;
        await tester.pump();

        expect(findTestElementWidget(), findsNothing);
      },
    );

    testWidgets(
      'add new element when Scene.elements changes',
      (tester) async {
        final element = ValueNotifier<SceneElement?>(null);

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<SceneElement?>(
            valueListenable: element,
            builder: (context, element, child) => Scene(
              elements: [if (element != null) element],
              child: child!,
            ),
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsNothing);

        element.value = TestElement();
        await tester.pump();

        expect(findTestElementWidget(), findsOneWidget);
      },
    );

    testWidgets(
      'remove removed element when Scene.elements changes',
      (tester) async {
        final element = ValueNotifier<SceneElement?>(TestElement());

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<SceneElement?>(
            valueListenable: element,
            builder: (context, element, child) => Scene(
              elements: [if (element != null) element],
              child: child!,
            ),
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsOneWidget);

        element.value = null;
        await tester.pump();

        expect(findTestElementWidget(), findsNothing);
      },
    );

    testWidgets(
      'filter out elements whose type is incompatible with delegate',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [TestElement(), IncompatibleElement()],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsOneWidget);
      },
    );

    testWidgets(
      'do not show elements for which showElement returns false',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [
              TestElement(),
              TestElement(enabled: false),
            ],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        expect(findTestElementWidget(), findsOneWidget);
      },
    );

    testWidgets(
      'stack elements in order of Scene.elements',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [
              TestElement(
                color: Colors.orange,
                position: const Offset(150, 150),
              ),
              TestElement(
                color: Colors.blue,
                position: const Offset(100, 100),
              ),
            ],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        await expectLater(
          find.byType(Scene),
          matchesGoldenFile('goldens/stack_in_scene_order.png'),
        );
      },
    );

    testWidgets(
      'stack elements in paintOrder',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [
              TestElement(
                paintOrder: 1,
                color: Colors.orange,
                position: const Offset(150, 150),
              ),
              TestElement(
                color: Colors.blue,
                position: const Offset(100, 100),
              ),
            ],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        await expectLater(
          find.byType(Scene),
          matchesGoldenFile('goldens/stack_in_paint_order.png'),
        );
      },
    );

    testWidgets(
      'position elements',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            key: const Key('root'),
            margin: const EdgeInsets.all(50),
            color: Colors.grey,
            child: Scene(
              elements: [
                TestElement(
                  color: Colors.blue,
                  windowElementAnchor: Alignment.topLeft,
                  position: Offset.zero,
                ),
                TestElement(
                  color: Colors.red,
                  windowElementAnchor: Alignment.topLeft,
                  position: const Offset(100, 0),
                ),
                TestElement(
                  color: Colors.green,
                  windowElementAnchor: Alignment.topLeft,
                  position: const Offset(0, 100),
                ),
                TestElement(
                  color: Colors.amber,
                  windowElementAnchor: Alignment.topLeft,
                  position: const Offset(100, 100),
                ),
              ],
              child: const Window(
                delegate: TestDelegate(),
              ),
            ),
          ),
        ));

        await expectLater(
          find.byKey(const Key('root')),
          matchesGoldenFile('goldens/position_elements.png'),
        );
      },
    );

    testWidgets(
      'align elements',
      (tester) async {
        const position = Offset(200, 200);

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [
              TestElement(
                color: Colors.blue,
                position: position,
                windowElementAnchor: Alignment.topLeft,
              ),
              TestElement(
                color: Colors.red,
                position: position,
                windowElementAnchor: Alignment.topRight,
              ),
              TestElement(
                color: Colors.green,
                position: position,
                windowElementAnchor: Alignment.bottomLeft,
              ),
              TestElement(
                color: Colors.amber,
                position: position,
                windowElementAnchor: Alignment.bottomRight,
              ),
              TestElement(
                color: Colors.orange,
                position: position,
                windowElementAnchor: Alignment.center,
              ),
              TestElement(
                color: Colors.purple,
                position: position,
                windowElementAnchor: Alignment.bottomRight * 3,
              ),
            ],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        await expectLater(
          find.byType(Scene),
          matchesGoldenFile('goldens/align_elements.png'),
        );
      },
    );

    testWidgets(
      'position and alignment are updated when element changes',
      (tester) async {
        final position = TestElement(
          color: Colors.red,
          position: const Offset(200, 200),
        );
        final alignment = TestElement(
          color: Colors.blue,
          position: const Offset(250, 250),
        );
        final paintOrder = TestElement(
          color: Colors.green,
          position: const Offset(300, 300),
        );

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Scene(
            elements: [position, alignment, paintOrder],
            child: const Window(
              delegate: TestDelegate(),
            ),
          ),
        ));

        await expectLater(
          find.byType(Scene),
          matchesGoldenFile('goldens/update_layout_0.png'),
        );

        position.layoutDelegate.position = const Offset(225, 225);
        alignment.windowElementAnchor = Alignment.topRight;
        paintOrder.paintOrder = -1;

        await tester.pump();

        await expectLater(
          find.byType(Scene),
          matchesGoldenFile('goldens/update_layout_1.png'),
        );
      },
    );
  });
}

Finder findWindow() => find.byWidgetPredicate((widget) => widget is Window);

Finder findByTypeInWindow(Type type) => find.descendant(
      of: findWindow(),
      matching: find.byType(type),
    );

Finder findTestElementWidget() => findByTypeInWindow(TestElementWidget);

class IncompatibleElement extends SceneElement {}

class TestElement
    extends LayoutDelegateSceneElement<PositionedBoxLayoutDelegate> {
  TestElement({
    bool? enabled,
    Offset position = Offset.zero,
    this.color = const Color(0xFFFFFFFF),
    AlignmentGeometry? windowElementAnchor,
    int? paintOrder,
  })  : _windowElementAnchor = windowElementAnchor,
        _paintOrder = paintOrder,
        super(
          enabled: enabled,
          layoutDelegate: PositionedBoxLayoutDelegate(
            alignment: Alignment.topLeft,
            size: const Size.square(100),
            position: position,
          ),
        );

  final Color color;

  AlignmentGeometry? get windowElementAnchor => _windowElementAnchor;
  AlignmentGeometry? _windowElementAnchor;

  set windowElementAnchor(AlignmentGeometry? alignment) {
    if (alignment != _windowElementAnchor) {
      _windowElementAnchor = alignment;
      notifyListeners();
    }
  }

  int? get paintOrder => _paintOrder;
  int? _paintOrder;

  set paintOrder(int? paintOrder) {
    if (paintOrder != _paintOrder) {
      _paintOrder = paintOrder;
      notifyListeners();
    }
  }
}

class TestDelegate extends WindowDelegate<TestElement> {
  const TestDelegate({bool shouldRebuild = true})
      : _shouldRebuild = shouldRebuild;

  final bool _shouldRebuild;

  @override
  AlignmentGeometry windowElementAnchor(TestElement element) =>
      element.windowElementAnchor ?? super.windowElementAnchor(element);

  @override
  int paintOrder(TestElement element) =>
      element.paintOrder ?? super.paintOrder(element);

  @override
  Widget build(BuildContext context, TestElement element) =>
      TestElementWidget(color: element.color);

  @override
  bool shouldRebuild(WindowDelegate<TestElement> oldDelegate) => _shouldRebuild;
}

class TestElementWidget extends StatelessWidget {
  const TestElementWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 100,
        height: 100,
        color: color,
      );
}

class DefaultDelegate<T extends SceneElement> extends WindowDelegate<T> {
  @override
  Widget build(BuildContext context, T element) {
    throw UnimplementedError();
  }
}

class NoopDelegate<T extends SceneElement> extends WindowDelegate<T> {
  @override
  bool showElement(T element) => false;

  @override
  Widget build(BuildContext context, T element) {
    throw UnimplementedError();
  }
}

class TestStatefulWindowDelegate extends StatefulWindowDelegate<TestElement> {
  TestStatefulWindowDelegate({
    this.onElementAdded,
    this.onElementChanged,
    this.onElementRemoved,
    this.hideElements = false,
  });
  final ValueChanged<TestElement>? onElementAdded;
  final ValueChanged<TestElement>? onElementChanged;
  final ValueChanged<TestElement>? onElementRemoved;
  bool hideElements;

  @override
  bool showElement(TestElement element) =>
      // ignore: avoid_bool_literals_in_conditional_expressions
      hideElements ? false : super.showElement(element);

  @override
  void didAddElement(TestElement element) {
    onElementAdded?.call(element);
  }

  @override
  void didChangeElement(TestElement element) {
    onElementChanged?.call(element);
  }

  @override
  void didRemoveElement(TestElement element) {
    onElementRemoved?.call(element);
  }

  @override
  Widget build(BuildContext context, TestElement element) =>
      const TestElementWidget(
        color: Colors.black,
      );
}
