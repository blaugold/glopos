// ignore: lines_longer_than_80_chars
// ignore_for_file: diagnostic_describe_all_properties, avoid_redundant_argument_values

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/glopos.dart';

void main() {
  setUpAll(loadFont);

  group('WindowDelegate', () {
    test('default implementation of showElement returns element.enabled', () {
      final element = TestElement();
      final delegate = DefaultDelegate();

      expect(delegate.showElement(element), isTrue);
      element.enabled = false;
      expect(delegate.showElement(element), isFalse);
    });

    test('default implementation of alignment returns Alignment.center', () {
      final element = TestElement();
      final delegate = DefaultDelegate();

      expect(delegate.alignment(element), Alignment.center);
    });

    test('default implementation of paintOrder returns 0', () {
      final element = TestElement();
      final delegate = DefaultDelegate();

      expect(delegate.paintOrder(element), 0);
    });
  });

  group('Window', () {
    testWidgets('throw error when Window is used without Scene',
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
    });

    testWidgets(
      'update elements when delegate changes',
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

        expect(
          findTestElementWidget(),
          findsNothing,
        );

        delegate.value = const TestDelegate();
        await tester.pump();

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );
      },
    );

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

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );

        element.enabled = false;
        await tester.pump();

        expect(
          findTestElementWidget(),
          findsNothing,
        );
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

        expect(
          findTestElementWidget(),
          findsNothing,
        );

        element.value = TestElement();
        await tester.pump();

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );
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

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );

        element.value = null;
        await tester.pump();
        expect(
          findTestElementWidget(),
          findsNothing,
        );
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

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );
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

        expect(
          findTestElementWidget(),
          findsOneWidget,
        );
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
                label: 'Back',
                color: Colors.orange,
                position: const Offset(150, 150),
              ),
              TestElement(
                label: 'Front',
                color: Colors.blue,
                position: const Offset(100, 100),
              )
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
                label: 'Front',
                paintOrder: 1,
                color: Colors.orange,
                position: const Offset(150, 150),
              ),
              TestElement(
                label: 'Back',
                color: Colors.blue,
                position: const Offset(100, 100),
              )
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
                  label: 'TopLeft',
                  color: Colors.blue,
                  alignment: Alignment.topLeft,
                  position: Offset.zero,
                ),
                TestElement(
                  label: 'TopRight',
                  color: Colors.red,
                  alignment: Alignment.topLeft,
                  position: const Offset(100, 0),
                ),
                TestElement(
                  label: 'BottomLeft',
                  color: Colors.green,
                  alignment: Alignment.topLeft,
                  position: const Offset(0, 100),
                ),
                TestElement(
                  label: 'BottomRight',
                  color: Colors.amber,
                  alignment: Alignment.topLeft,
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
                label: 'TopLeft',
                color: Colors.blue,
                position: position,
                alignment: Alignment.topLeft,
              ),
              TestElement(
                label: 'TopRight',
                color: Colors.red,
                position: position,
                alignment: Alignment.topRight,
              ),
              TestElement(
                label: 'BottomLeft',
                color: Colors.green,
                position: position,
                alignment: Alignment.bottomLeft,
              ),
              TestElement(
                label: 'BottomRight',
                color: Colors.amber,
                position: position,
                alignment: Alignment.bottomRight,
              ),
              TestElement(
                label: 'Center',
                color: Colors.orange,
                position: position,
                alignment: Alignment.center,
              ),
              TestElement(
                label: 'BottomRight 3x',
                color: Colors.purple,
                position: position,
                alignment: Alignment.bottomRight * 3,
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
          label: 'Position',
          color: Colors.red,
          position: const Offset(200, 200),
        );
        final alignment = TestElement(
          label: 'Alignment',
          color: Colors.blue,
          position: const Offset(250, 250),
        );
        final paintOrder = TestElement(
          label: 'PaintOrder',
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

        position.position = const Offset(225, 225);
        alignment.alignment = Alignment.topRight;
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

class TestElement extends SceneElement {
  TestElement({
    bool? enabled,
    Offset? position,
    this.label,
    this.color = const Color(0xFFFFFFFF),
    AlignmentGeometry alignment = Alignment.center,
    int paintOrder = 0,
  })  : _alignment = alignment,
        _paintOrder = paintOrder,
        super(enabled: enabled, position: position);

  final String? label;

  final Color color;

  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;

  set alignment(AlignmentGeometry alignment) {
    if (alignment != _alignment) {
      _alignment = alignment;
      notifyListeners();
    }
  }

  int get paintOrder => _paintOrder;
  int _paintOrder;

  set paintOrder(int paintOrder) {
    if (paintOrder != _paintOrder) {
      _paintOrder = paintOrder;
      notifyListeners();
    }
  }
}

class TestDelegate extends WindowDelegate<TestElement> {
  const TestDelegate();

  @override
  AlignmentGeometry alignment(TestElement element) => element.alignment;

  @override
  int paintOrder(TestElement element) => element.paintOrder;

  @override
  Widget buildRepresentation(BuildContext context, TestElement element) =>
      TestElementWidget(color: element.color, label: element.label);
}

class TestElementWidget extends StatelessWidget {
  const TestElementWidget({
    Key? key,
    required this.color,
    this.label,
  }) : super(key: key);

  final Color color;

  final String? label;

  @override
  Widget build(BuildContext context) => Container(
        width: 100,
        height: 100,
        color: color,
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Roboto-Regular',
                  fontSize: 14,
                ),
              )
            : null,
      );
}

class DefaultDelegate<T extends SceneElement> extends WindowDelegate<T> {
  @override
  Widget buildRepresentation(BuildContext context, T element) {
    throw UnimplementedError();
  }
}

class NoopDelegate<T extends SceneElement> extends WindowDelegate<T> {
  @override
  bool showElement(T element) => false;

  @override
  Widget buildRepresentation(BuildContext context, T element) {
    throw UnimplementedError();
  }
}

Future<void> loadFont() async {
  final fontData = File('test/assets/Roboto-Regular.ttf')
      .readAsBytes()
      .then((value) => value.buffer.asByteData());

  final fontLoader = FontLoader('Roboto-Regular')..addFont(fontData);

  await fontLoader.load();
}
