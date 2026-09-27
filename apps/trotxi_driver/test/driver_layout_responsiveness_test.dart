import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/account_linked_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/confirm_account_page.dart';
import 'package:trotxi_driver/Presentations/Onboarding/pages/first_launch_page.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_nav.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

const _driver = DriverSession(
  driverId: 'driver-1',
  driverCode: 'DR-B7K9',
  fullName: 'Kwame Asare',
  mustChangePin: false,
);

void main() {
  final sizes = <Size>[
    const Size(390, 844),
    const Size(834, 1112),
    const Size(1194, 834),
  ];

  for (final size in sizes) {
    testWidgets('first launch fits ${size.width}×${size.height}', (
      tester,
    ) async {
      await _atSize(
        tester,
        size,
        DriverFirstLaunchPage(onContinue: () async {}),
      );
      expect(find.text('Welcome to Trotxi Driver'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('account linking fits ${size.width}×${size.height}', (
      tester,
    ) async {
      await _atSize(
        tester,
        size,
        ConfirmAccountPage(
          session: _driver,
          onConfirmed: () {},
          onRejected: () async {},
        ),
      );
      expect(find.text('Confirm your account'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _atSize(
        tester,
        size,
        const AccountLinkedPage(session: _driver, onContinue: _noop),
      );
      expect(find.text('Account linked'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'phone navigation remains a bottom bar, not a full-screen layer',
    (tester) async {
      await _atSize(
        tester,
        const Size(390, 844),
        Scaffold(
          body: const Center(child: Text('Driver workspace')),
          bottomNavigationBar: DriverNav(
            current: DriverTab.today,
            onSelect: (_) {},
          ),
        ),
      );

      expect(tester.getSize(find.byType(DriverNav)).height, lessThan(140));
      expect(tester.getBottomLeft(find.byType(DriverNav)).dy, 844);
      expect(find.text('Driver workspace'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

void _noop() {}

Future<void> _atSize(WidgetTester tester, Size size, Widget child) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: child));
  await tester.pump();
}
