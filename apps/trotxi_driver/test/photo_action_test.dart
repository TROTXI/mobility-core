import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Profile/widgets/photo_action.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';

Future<void> pump(
  WidgetTester tester,
  Widget child,
) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('tapping the label actually fires', (tester) async {
    // The first version wrapped a bare Text in a GestureDetector. It rendered
    // identically and never fired, because hit testing defers to a child that
    // does not hit test itself. This is that regression.
    var taps = 0;
    await pump(
      tester,
      PhotoAction(hasPhoto: false, busy: false, onPressed: () => taps++),
    );

    expect(find.text('Add a photo'), findsOneWidget);
    await tester.tap(find.text('Add a photo'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('the target is big enough to hit on a moving vehicle', (
    tester,
  ) async {
    await pump(
      tester,
      PhotoAction(hasPhoto: false, busy: false, onPressed: () {}),
    );
    expect(
      tester.getSize(find.byType(PhotoAction)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('an upload in flight disables the control and says so', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      PhotoAction(hasPhoto: false, busy: true, onPressed: () => taps++),
    );

    expect(find.text('Uploading…'), findsOneWidget);
    await tester.tap(find.byType(PhotoAction), warnIfMissed: false);
    await tester.pump();
    expect(taps, 0, reason: 'a second upload must not start on top of one');
  });

  testWidgets('an existing photo offers a change, not an add', (tester) async {
    await pump(
      tester,
      PhotoAction(hasPhoto: true, busy: false, onPressed: () {}),
    );
    expect(find.text('Change photo'), findsOneWidget);
  });
}
