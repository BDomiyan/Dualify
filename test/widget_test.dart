import 'package:flutter_test/flutter_test.dart';

import 'package:dualify_dashboard/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DualifyApp());

    // Verify that the app title is displayed
    expect(find.text('Dualify Dashboard'), findsOneWidget);
    expect(
      find.text('Setting up your apprenticeship journey...'),
      findsOneWidget,
    );
  });
}
