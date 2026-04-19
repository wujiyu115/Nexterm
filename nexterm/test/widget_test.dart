import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexterm/app.dart';

void main() {
  testWidgets('Nexterm app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NextermApp()),
    );

    // App renders without crashing
    expect(find.byType(NextermApp), findsOneWidget);
  });
}
