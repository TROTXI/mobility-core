import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/driver_information_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';

class _Config implements ConfigRepository {
  @override
  Future<AppConfig?> cached() async => null;
  @override
  Future<AppConfig> load() async => AppConfig.empty;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'pilot notice is readable and uses configured support, not invented contacts',
    (tester) async {
      final config = ConfigController(config: _Config());
      addTearDown(config.dispose);
      await config.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: config,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: DriverInformationPage()),
          ),
        ),
      );
      expect(find.text('Driver privacy & guidance'), findsOneWidget);
      expect(
        driverInformationSections['Location during an active trip'],
        contains('background'),
      );
      expect(
        driverInformationSections['Your information'],
        contains('Firebase'),
      );
      final contact = find.text('SUPPORT & PRIVACY REQUESTS');
      await tester.scrollUntilVisible(contact, 400);
      expect(contact, findsOneWidget);
      expect(
        find.textContaining('not published contact details'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
