import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_security.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

void main() {
  late Fixture f;
  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      f = Fixture();
      await f.signedIn();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProfileSecurityPage(client: f.api),
        ),
      );
    });
    await tester.pumpAndSettle();
  }

  Future<void> openDelete(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Delete account'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    f.api.dispose();
  }

  testWidgets(
    'erasure requires confirmation and describes retained records honestly',
    (tester) async {
      await pump(tester);
      await openDelete(tester);
      expect(
        find.textContaining('required accounting records are retained'),
        findsOneWidget,
      );
      expect(f.requests, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(f.requests, isEmpty);
      await finish(tester);
    },
  );
  testWidgets(
    'acknowledged erasure plus local failure does not claim the server refused deletion',
    (tester) async {
      await pump(tester);
      f.storage.failDelete = true;
      f.reply = (_) => jsonResponse(null, 204);
      await tester.runAsync(() async {
        await openDelete(tester);
        await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
        for (var i = 0; i < 100; i++) {
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 20));
          if (find.byType(SnackBar).evaluate().isNotEmpty) break;
        }
      });
      await tester.pumpAndSettle();
      expect(f.requests.single.method, 'DELETE');
      expect(f.requests.single.path, '/v1/me');
      expect(find.textContaining('server accepted erasure'), findsOneWidget);
      expect(await tester.runAsync(f.store.getAccessToken), 'access-Ama');
      await finish(tester);
    },
  );
  testWidgets(
    'a confirmation opened by the previous rider cannot erase the next rider',
    (tester) async {
      await pump(tester);
      await openDelete(tester);
      await tester.runAsync(
        () => f.store.saveTokens(accessToken: 'new', refreshToken: 'new-r'),
      );
      await tester.tap(find.widgetWithText(TextButton, 'Delete account'));
      await tester.pumpAndSettle();
      expect(f.requests, isEmpty);
      expect(await tester.runAsync(f.store.getAccessToken), 'new');
      await finish(tester);
    },
  );
}
