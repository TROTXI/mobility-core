import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/help_support_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';

import 'replacement_fixture.dart';

void main() {
  testWidgets('help remains useful without a configured support contact', (
    tester,
  ) async {
    final fixture = Fixture();
    addTearDown(fixture.api.dispose);
    await fixture.signedIn();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: HelpSupportPage(client: fixture.api),
      ),
    );

    expect(find.text('Payment history'), findsOneWidget);
    expect(
      find.textContaining('A direct support contact is not available'),
      findsOneWidget,
    );
    expect(find.text('Privacy notice'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(find.text('Request account deletion'), findsOneWidget);
    expect(find.textContaining('Please try again later'), findsNothing);
  });
}
