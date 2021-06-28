// ignore_for_file: lines_longer_than_80_chars, diagnostic_describe_all_properties
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/glopos.dart';

void main() {
  group('SceneElement', () {
    test('is enabled by default', () {
      expect(TestElement().enabled, isTrue);
    });

    test('exposes debug properties', () {
      expect(
        TestElement().toDiagnosticsNode().getProperties(),
        containsAll(<dynamic>[
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'enabled')
              .having((it) => it.value, 'value', true),
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'layerLink')
              .having((it) => it.value, 'value', isA<LayerLink>()),
        ]),
      );
    });

    testWidgets('notifies listeners when enabled changes', (_) async {
      TestElement()
        ..addListener(expectAsync0(() {}, count: 0))
        ..enabled = true;

      TestElement()
        ..addListener(expectAsync0(() {}, count: 1))
        ..enabled = false;
    });
  });

  group('PositionLayoutDelegate', () {
    test('initializes position to Offset.zero', () {
      expect(TestPositionLayoutDelegate().position, Offset.zero);
    });

    testWidgets('notifies listeners when position changes', (_) async {
      final delegate = TestPositionLayoutDelegate();

      delegate.addListener(expectAsync0(() {
        expect(delegate.position, Offset.infinite);
      }));

      // ignore: cascade_invocations
      delegate
        ..position = Offset.zero
        ..position = Offset.infinite;
    });

    test('adds position to debug properties', () {
      expect(
        TestPositionLayoutDelegate().toDiagnosticsNode().getProperties(),
        contains(
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'position')
              .having((it) => it.value, 'value', Offset.zero),
        ),
      );
    });
  });

  group('SizeLayoutDelegate', () {
    test('initializes size to Size.zero', () {
      expect(TestSizeLayoutDelegate().size, Size.zero);
    });

    testWidgets('notifies listeners when size changes', (_) async {
      final delegate = TestSizeLayoutDelegate();

      delegate.addListener(expectAsync0(() {
        expect(delegate.size, Size.infinite);
      }));

      // ignore: cascade_invocations
      delegate
        ..size = Size.zero
        ..size = Size.infinite;
    });

    test('adds size to debug properties', () {
      expect(
        TestSizeLayoutDelegate().toDiagnosticsNode().getProperties(),
        contains(
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'size')
              .having((it) => it.value, 'value', Size.zero),
        ),
      );
    });
  });

  group('PositionedBoxLayoutDelegate', () {
    test('initializes alignment to Alignment.topLeft', () {
      expect(
        PositionedBoxLayoutDelegate(size: Size.zero).alignment,
        Alignment.topLeft,
      );
    });

    testWidgets('notifies listeners when alignment changes', (_) async {
      final delegate = PositionedBoxLayoutDelegate(size: Size.zero);

      delegate.addListener(expectAsync0(() {
        expect(delegate.alignment, Alignment.center);
      }));

      // ignore: cascade_invocations
      delegate
        ..alignment = Alignment.topLeft
        ..alignment = Alignment.center;
    });

    test('adds alignment to debug properties', () {
      expect(
        PositionedBoxLayoutDelegate(size: Size.zero)
            .toDiagnosticsNode()
            .getProperties(),
        contains(
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'alignment')
              .having((it) => it.value, 'value', Alignment.topLeft),
        ),
      );
    });

    testWidgets('correctly lays out SceneElement', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Scene(
          elements: [
            LayoutTestElement(
              color: Colors.red,
              layoutDelegate: PositionedBoxLayoutDelegate(
                size: const Size.square(100),
              ),
            ),
            LayoutTestElement(
              color: Colors.green,
              layoutDelegate: PositionedBoxLayoutDelegate(
                position: const Offset(200, 100),
                alignment: Alignment.center,
                size: const Size.square(200),
              ),
            ),
          ],
          child: Window(
            delegate: LayoutTestDelegate(),
          ),
        ),
      ));

      await expectLater(
        find.byType(Scene),
        matchesGoldenFile('goldens/PositionedBoxLayoutDelegate/layout.png'),
      );
    });
  });

  group('AlignedBoxLayoutDelegate', () {
    test('initializes alignment to Alignment.topLeft', () {
      expect(
        AlignedBoxLayoutDelegate(size: Size.zero).alignment,
        Alignment.center,
      );
    });

    testWidgets('notifies listeners when alignment changes', (_) async {
      final delegate = AlignedBoxLayoutDelegate(size: Size.zero);

      delegate.addListener(expectAsync0(() {
        expect(delegate.alignment, Alignment.topLeft);
      }));

      // ignore: cascade_invocations
      delegate
        ..alignment = Alignment.center
        ..alignment = Alignment.topLeft;
    });

    testWidgets('notifies listeners when padding changes', (_) async {
      final delegate = AlignedBoxLayoutDelegate(size: Size.zero);

      delegate.addListener(expectAsync0(() {
        expect(delegate.padding, const EdgeInsets.all(10));
      }));

      // ignore: cascade_invocations
      delegate
        ..padding = EdgeInsets.zero
        ..padding = const EdgeInsets.all(10);
    });

    test('adds alignment to debug properties', () {
      expect(
        AlignedBoxLayoutDelegate(size: Size.zero)
            .toDiagnosticsNode()
            .getProperties(),
        containsAll(<dynamic>[
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'alignment')
              .having((it) => it.value, 'value', Alignment.center),
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'padding')
              .having((it) => it.value, 'value', EdgeInsets.zero),
        ]),
      );
    });

    testWidgets('correctly lays out SceneElement', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Scene(
          elements: [
            LayoutTestElement(
              color: Colors.red,
              layoutDelegate: AlignedBoxLayoutDelegate(
                size: const Size.square(100),
              ),
            ),
            LayoutTestElement(
              color: Colors.green,
              layoutDelegate: AlignedBoxLayoutDelegate(
                alignment: Alignment.topLeft,
                size: const Size.square(200),
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
          child: Window(
            delegate: LayoutTestDelegate(),
          ),
        ),
      ));

      await expectLater(
        find.byType(Scene),
        matchesGoldenFile('goldens/AlignedBoxLayoutDelegate/layout.png'),
      );
    });
  });

  group('LayoutDelegateSceneElement', () {
    test('adds layoutDelegate to debug properties', () {
      expect(
        LayoutTestElement(
          layoutDelegate: AlignedBoxLayoutDelegate(size: Size.zero),
          color: Colors.black,
        ).toDiagnosticsNode().getProperties(),
        containsAll(<dynamic>[
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'layoutDelegate')
              .having(
                (it) => it.value,
                'value',
                isA<AlignedBoxLayoutDelegate>(),
              ),
        ]),
      );
    });

    testWidgets(
      'notifies listeners when layout delegate changes',
      (_) async {
        final element = LayoutTestElement(
          layoutDelegate: AlignedBoxLayoutDelegate(size: Size.zero),
          color: Colors.black,
        );
        final newLayoutDelegate = AlignedBoxLayoutDelegate(size: Size.zero);

        element.layoutDelegateChanges.addListener(expectAsync0(() {
          expect(element.layoutDelegate, newLayoutDelegate);
        }));

        element.layoutDelegate = newLayoutDelegate;
      },
    );
  });

  group('LayedOutSceneElement', () {
    test('exposes debug properties', () {
      expect(
        LayedOutTestElement().toDiagnosticsNode().getProperties(),
        containsAll(<dynamic>[
          isA<DiagnosticsProperty>()
              .having((it) => it.name, 'name', 'size')
              .having((it) => it.value, 'value', const Size.square(100)),
        ]),
      );
    });

    testWidgets(
      'notifies listeners when size changes',
      (tester) async {
        final element = LayedOutTestElement();

        element.addListener(expectAsync0(() {
          expect(element.size, Size.zero);
        }));

        expect(element.size, const Size.square(100));

        element.size = Size.zero;
      },
    );

    testWidgets('correctly lays out SceneElement', (tester) async {
      final elementA = LayedOutTestElement(
        color: Colors.red,
      );
      final elementB = LayedOutTestElement(
        color: Colors.green,
        size: const Size.square(200),
      );

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Scene(
          elements: [elementA, elementB],
          layout: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                LayoutSceneElement(element: elementA),
                LayoutSceneElement(element: elementB),
              ],
            ),
          ),
          child: Window(
            delegate: LayedOutTestDelegate(),
          ),
        ),
      ));

      await expectLater(
        find.byType(Scene),
        matchesGoldenFile('goldens/LayedOutSceneElement/layout.png'),
      );
    });

    testWidgets('update layout of SceneElement', (tester) async {
      final element = LayedOutTestElement(
        color: Colors.red,
      );
      final padding = ValueNotifier(EdgeInsets.zero);

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Scene(
          elements: [element],
          layout: ValueListenableBuilder<EdgeInsets>(
            valueListenable: padding,
            builder: (context, padding, child) => Padding(
              padding: padding,
              child: child,
            ),
            child: Row(
              children: [
                LayoutSceneElement(element: element),
              ],
            ),
          ),
          child: Window(
            delegate: LayedOutTestDelegate(),
          ),
        ),
      ));

      await expectLater(
        find.byType(Scene),
        matchesGoldenFile('goldens/LayedOutSceneElement/update_layout_0.png'),
      );

      element.size = const Size.square(200);
      padding.value = const EdgeInsets.all(10);
      await tester.pump();

      await expectLater(
        find.byType(Scene),
        matchesGoldenFile('goldens/LayedOutSceneElement/update_layout_1.png'),
      );
    });
  });

  group('Scene', () {
    test('expose debug properties', () {
      final scene = Scene(
        elements: [TestElement()],
        child: Container(),
      );

      expect(
        scene.toString(),
        stringContainsInOrder([
          'Scene(elements: [TestElement#',
          '(layerLink: LayerLink#',
          '(<dangling>), enabled: true)])',
        ]),
      );
    });

    testWidgets(
      'throw error when Scene.of cannot find Scene',
      (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (context) {
            Scene.of(context);
            return Container();
          }),
        ));

        expect(
          tester.takeException(),
          isA<FlutterError>().having(
            (it) => it.message,
            'message',
            'Could not find an ancestor `Scene` widget\nEnsure there is a '
                '`Scene` widget above every `Window` widget',
          ),
        );
      },
    );

    testWidgets(
      'notify dependents when elements changes',
      (tester) async {
        final element = TestElement();
        final elements = ValueNotifier(<SceneElement>[]);
        final receivedElements = <List<SceneElement>>[];
        Widget builder(BuildContext context) {
          receivedElements.add(Scene.of(context).elements);
          return Container();
        }

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ValueListenableBuilder<List<SceneElement>>(
            valueListenable: elements,
            builder: (context, elements, _) => Scene(
              elements: elements,
              child: Builder(builder: builder),
            ),
          ),
        ));

        elements.value = [element];
        await tester.pump();
        elements.value = [];
        await tester.pump();

        expect(receivedElements, [
          <SceneElement>[],
          [element],
          <SceneElement>[],
        ]);
      },
    );
  });
}

class TestElement extends SceneElement {}

class TestPositionLayoutDelegate extends SceneElementLayoutDelegate
    with PositionLayoutDelegate {
  @override
  Widget buildPositioned(BuildContext context, Widget content) =>
      throw UnimplementedError();
}

class TestSizeLayoutDelegate extends SceneElementLayoutDelegate
    with SizeLayoutDelegate {
  @override
  Widget buildPositioned(BuildContext context, Widget content) =>
      throw UnimplementedError();
}

class LayoutTestElement<T extends SizeLayoutDelegate>
    extends LayoutDelegateSceneElement<T> {
  LayoutTestElement({required T layoutDelegate, required this.color})
      : super(layoutDelegate: layoutDelegate);

  final Color color;
}

class LayoutTestDelegate extends WindowDelegate<LayoutTestElement> {
  @override
  Widget build(
    BuildContext context,
    LayoutTestElement element,
  ) =>
      LayoutDelegateBuilder<SizeLayoutDelegate>(
        element: element,
        builder: (context, value, child) => SizedBox.fromSize(
          size: value.size,
          child: Container(
            color: element.color,
          ),
        ),
      );
}

class LayedOutTestElement extends LayedOutSceneElement {
  LayedOutTestElement({
    Size size = const Size.square(100),
    this.color = Colors.white,
  }) : super(size: size);

  final Color color;
}

class LayedOutTestDelegate extends WindowDelegate<LayedOutTestElement> {
  @override
  Widget build(BuildContext context, LayedOutTestElement element) =>
      Container(color: element.color);
}
