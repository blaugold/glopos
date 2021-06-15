import 'package:flutter_test/flutter_test.dart';
import 'package:glopos_example/src/app.dart';

void main() {
  testWidgets('can pump GloposExampleApp', (tester) async {
    await tester.pumpWidget(const GloposExampleApp());
  });
}
