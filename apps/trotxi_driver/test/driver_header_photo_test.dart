import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_header.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

class _Auth implements DriverAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> draw(WidgetTester tester, String? url) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SessionController(auth: _Auth()),
          ),
          ChangeNotifierProvider(create: (_) => AppThemeController()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: DriverHeader(photoUrl: url)),
        ),
      ),
    );
  }

  testWidgets('header uses the account photo when present', (tester) async {
    await draw(tester, 'https://example.com/driver.png');
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://example.com/driver.png');
    expect(image.fit, BoxFit.cover);
    expect(image.errorBuilder, isNotNull);
  });

  testWidgets('header falls back to initials without a photo', (tester) async {
    await draw(tester, null);
    expect(find.byType(Image), findsNothing);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('failed photo displays initials instead of a broken image', (
    tester,
  ) async {
    await draw(tester, 'https://example.com/driver.png');
    await tester.pumpAndSettle();
    expect(find.text('D'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
