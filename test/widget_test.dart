

import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZarMemoryApp());

    // Verify that our app title is present.
    // Note: In a SliverAppBar with a FlexibleSpaceBar, the title might be found differently
    // or sometimes not found by text immediately if not fully expanded/collapsed or depending on implementation.
    // But usually 'ZAR Memory' should be in the widget tree.
    expect(find.text('ZAR Memory'), findsOneWidget);
    
    // Verify that "No memories yet" is actively shown initially (as list is empty)
    expect(find.text('No memories yet'), findsOneWidget);
  });
}
