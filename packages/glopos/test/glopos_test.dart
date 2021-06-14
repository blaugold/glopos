import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glopos/glopos.dart';

void main() {
  testWidgets('throw error when Window is used without Scene', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: Window(
        delegate: ZeroBoxDelegate(),
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

  testWidgets('center element in Scene', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Container(
          height: 300,
          width: 300,
          color: Colors.blue,
          child: Scene(
            elements: [TestElement(position: const Offset(150, 150))],
            child: const Window(
              delegate: CenteredOrangeBoxDelegate(),
            ),
          ),
        ),
      ),
    ));

    await expectLater(
      find.byType(Scene),
      matchesGoldenFile('goldens/center_element_in_scene.png'),
    );
  });

  testWidgets(
    'adding/removing SceneElement is reflected in Window',
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
            delegate: ZeroBoxDelegate(),
          ),
        ),
      ));

      expect(
        find.descendant(
          of: findWindow<TestElement>(),
          matching: find.byType(SizedBox),
        ),
        findsNothing,
      );

      element.value = TestElement();
      await tester.pump();
      expect(
        find.descendant(
          of: findWindow<TestElement>(),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );

      element.value = null;
      await tester.pump();
      expect(
        find.descendant(
          of: findWindow<TestElement>(),
          matching: find.byType(SizedBox),
        ),
        findsNothing,
      );
    },
  );
}

Finder findWindow<T extends SceneElement>() =>
    find.byWidgetPredicate((widget) => widget is Window<T>);

class IncompatibleTypeTestElement extends SceneElement {}

class TestElement extends SceneElement {
  TestElement({Offset position = Offset.zero}) {
    this.position = position;
  }
}

class ZeroBoxDelegate extends WindowDelegate<TestElement> {
  const ZeroBoxDelegate();

  @override
  Widget buildRepresentation(BuildContext context, TestElement element) =>
      const SizedBox(width: 0, height: 0);
}

class CenteredOrangeBoxDelegate extends WindowDelegate<TestElement> {
  const CenteredOrangeBoxDelegate();

  @override
  Widget buildRepresentation(BuildContext context, TestElement element) =>
      Container(
        height: 100,
        width: 100,
        color: Colors.orange,
      );
}
