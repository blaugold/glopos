import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/src/scene.dart';

void main() {
  group('SceneElement', () {
    test('is enabled by default', () {
      expect(TestElement().enabled, isTrue);
    });

    test('is positioned at origin by default', () {
      expect(TestElement().position, Offset.zero);
    });

    test('exposes debug properties', () {
      expect(
        TestElement().toString(),
        stringContainsInOrder([
          'TestElement#',
          '(enabled: true, position: Offset(0.0, 0.0))',
        ]),
      );
    });

    test('notifies listeners if properties change', () {
      TestElement()
        ..addListener(expectAsync0(() {}, count: 0))
        ..enabled = true
        ..position = Offset.zero;

      TestElement()
        ..addListener(expectAsync0(() {}, count: 2))
        ..enabled = false
        ..position = Offset.infinite;
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
          '(enabled: true, position: Offset(0.0, 0.0))])',
        ]),
      );
    });

    testWidgets(
      'uses RenderScene RenderObject',
      (tester) async {
        await tester.pumpWidget(Scene(
          elements: const [],
          child: Container(),
        ));

        expect(
          tester.firstRenderObject(find.byType(Scene)),
          isA<RenderScene>(),
        );
      },
    );

    testWidgets(
      'throw error when Scene.of cannot find Scene',
      (tester) async {
        await tester.pumpWidget(Builder(builder: (context) {
          Scene.of(context);
          return Container();
        }));

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

        await tester.pumpWidget(ValueListenableBuilder<List<SceneElement>>(
          valueListenable: elements,
          builder: (context, elements, _) => Scene(
            elements: elements,
            child: Builder(builder: builder),
          ),
        ));

        elements.value = [element];
        await tester.pump();
        elements.value = [];
        await tester.pump();

        expect(receivedElements, [
          <SceneElement>[],
          [element],
          <SceneElement>[]
        ]);
      },
    );
  });
}

class TestElement extends SceneElement {}
