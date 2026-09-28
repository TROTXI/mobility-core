import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/main.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'replacement_fixture.dart';

void main() {
  late Fixture f;
  Future<void> init(WidgetTester tester) async {
    await tester.runAsync(() async {
      f = Fixture();
      await f.signedIn();
    });
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(TrotxiCommuterApp(client: f.api));
      for (var i = 0; i < 150; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
        if ((f.api.stage.value != CommuterStage.loading ||
                f.api.upgradeRequired.value) &&
            find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    f.api.dispose();
  }

  testWidgets('replacement account restores; theme is Material3', (
    tester,
  ) async {
    await init(tester);
    await pump(tester);
    expect(f.api.stage.value, CommuterStage.ready);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!.useMaterial3,
      isTrue,
    );
    expect(f.requests.where((r) => r.path == '/v1/me'), isNotEmpty);
    expect(f.requests.any((r) => r.path == '/me'), isFalse);
    await finish(tester);
  });

  testWidgets('offline restore preserves credentials and presents retry', (
    tester,
  ) async {
    await init(tester);
    f.reply = (o) {
      if (o.path == '/flags') return jsonResponse(flags());
      throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      );
    };
    await pump(tester);
    expect(find.text('Try again'), findsOneWidget);
    expect(await tester.runAsync(f.store.getRefreshToken), 'refresh-Ama');
    expect(f.api.stage.value, CommuterStage.failed);
    await finish(tester);
  });

  testWidgets(
    'bootstrap minimum version blocks without querying private data',
    (tester) async {
      await init(tester);
      f.reply = (_) => jsonResponse(flags(floor: 32));
      await pump(tester);
      expect(find.text('Please update the app to continue.'), findsOneWidget);
      expect(f.requests.map((r) => r.path), ['/flags']);
      await tester.binding.handlePopRoute();
      expect(find.text('Please update the app to continue.'), findsOneWidget);
      expect(await tester.runAsync(f.store.getAccessToken), 'access-Ama');
      await finish(tester);
    },
  );

  testWidgets('426 removes pushed screens and back cannot bypass it', (
    tester,
  ) async {
    await init(tester);
    await pump(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Private pushed screen')),
      ),
    );
    await tester.pumpAndSettle();
    f.reply = (_) => jsonResponse({
      'error': {'code': 'upgrade_required', 'message': 'Update'},
    }, 426);
    await tester.runAsync(
      () => expectLater(
        f.api.account(),
        throwsA(isA<UpgradeRequiredException>()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Private pushed screen'), findsNothing);
    expect(find.text('Please update the app to continue.'), findsOneWidget);
    expect(await tester.runAsync(f.store.getAccessToken), 'access-Ama');
    await finish(tester);
  });

  testWidgets(
    'logout removes private pushed screens even if remote logout fails',
    (tester) async {
      await init(tester);
      await pump(tester);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Private pushed screen')),
        ),
      );
      await tester.pumpAndSettle();
      f.reply = (_) => jsonResponse({
        'error': {'code': 'unavailable', 'message': 'Offline'},
      }, 503);
      expect(await tester.runAsync(f.api.signOut), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Private pushed screen'), findsNothing);
      expect(f.api.stage.value, CommuterStage.signedOut);
      expect(await tester.runAsync(f.store.getAccessToken), isNull);
      await finish(tester);
    },
  );

  testWidgets('late restore after logout cannot rebuild the old account', (
    tester,
  ) async {
    await init(tester);
    await tester.runAsync(() async {
      final entered = Completer<void>(), release = Completer<void>();
      f.reply = (o) async {
        if (o.path == '/flags') return jsonResponse(flags());
        if (o.path == '/v1/me') {
          entered.complete();
          await release.future;
          return jsonResponse({'data': account()});
        }
        return jsonResponse(null, 204);
      };
      await tester.pumpWidget(TrotxiCommuterApp(client: f.api));
      await entered.future.timeout(const Duration(seconds: 3));
      await f.api.signOut();
      release.complete();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pumpAndSettle();
    expect(f.api.currentAccount, isNull);
    expect(f.api.stage.value, CommuterStage.signedOut);
    await finish(tester);
  });
}
