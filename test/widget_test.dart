

import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZarMemoryApp());
    await tester.pumpAndSettle();

    // Verify that our app title is present.
    // Note: In a SliverAppBar with a FlexibleSpaceBar, the title might be found differently
    // or sometimes not found by text immediately if not fully expanded/collapsed or depending on implementation.
    // But usually 'ZAR Memory' should be in the widget tree.
    // expect(find.text('LISTO'), findsOneWidget); // Title is now an image
    
    // Verify that "No memories yet" is actively shown initially (as list is empty)
    expect(find.text('No memories yet'), findsOneWidget);
  });
}
