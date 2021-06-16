import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/glopos.dart';

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

    test('notifies listeners when enabled changes', () {
      TestElement()
        ..addListener(expectAsync0(() {}, count: 0))
        ..enabled = true;

      TestElement()
        ..addListener(expectAsync0(() {}, count: 1))
        ..enabled = false;
    });

    test('notifies position listeners when position changes', () {
      TestElement()
        ..addPositionListener(expectAsync0(() {}, count: 0))
        ..position = Offset.zero;

      TestElement()
        ..addPositionListener(expectAsync0(() {}, count: 1))
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
          <SceneElement>[]
        ]);
      },
    );
  });
}

class TestElement extends SceneElement {}
