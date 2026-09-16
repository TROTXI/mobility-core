import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/pass_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/wallet_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

void main() {
  late Fixture f;
  late DateTime now;
  late bool offline;
  Map<String, Object?> seat(String id, String direction) => {
    'id': id,
    'tripId': 'trip-$id',
    'travelDate': '2026-09-16',
    'direction': direction,
    'status': 'reserved',
    'source': 'confirmation',
    'pickupOccurrenceId': 'pickup',
    'dropoffOccurrenceId': 'dropoff',
    'createdAt': timestamp,
    'updatedAt': timestamp,
    'version': 1,
  };
  ResponseBody proof(String id, {String code = 'A3BC'}) => jsonResponse({
    'data': {
      'reservationId': id,
      'tripId': 'trip-$id',
      'qrToken': 'proof-$id',
      'expiresAt': now.add(const Duration(seconds: 10)).toIso8601String(),
      'boardingCode': code,
    },
  });
  setUp(() {
    f = Fixture();
    // Widget timing/selection tests use the real wire serializer, errors and
    // generation guard. Root/shared suites exercise the real auth/OS queue.
    f.transport.dio.interceptors.removeWhere((i) => i is wire.AuthInterceptor);
    now = DateTime.utc(2026, 9, 16, 6);
    offline = false;
    f.reply = (o) {
      if (offline) {
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        );
      }
      if (o.path == '/v1/me/reservations') {
        return jsonResponse(
          page([seat('outbound', 'outbound'), seat('return', 'return')]),
        );
      }
      if (o.path == '/v1/me/reservations/outbound/pass') {
        return proof('outbound');
      }
      if (o.path == '/v1/me/reservations/return/pass') {
        return proof('return', code: 'Z7YX');
      }
      return jsonResponse({
        'error': {'code': 'not_found', 'message': 'No fixture'},
      }, 404);
    };
  });
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: child),
    );
    await tester.pumpAndSettle();
  }

  Future<void> select(
    WidgetTester tester,
    String direction, {
    bool settle = true,
  }) async {
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('2026-09-16 · $direction').last);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    f.api.dispose();
  }

  testWidgets(
    'pass waits for an explicit seat and shows its real QR and code',
    (tester) async {
      await pump(tester, PassTab(client: f.api, now: () => now));
      expect(find.byType(QrImageView), findsNothing);
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
      expect(f.requests.single.queryParameters['fromDate'], '2026-09-15');
      expect(f.requests.single.queryParameters['toDate'], '2026-09-16');
      await select(tester, 'Return');
      expect(f.requests.last.path, '/v1/me/reservations/return/pass');
      expect(
        tester.widget<BoardingQr>(find.byType(BoardingQr)).data,
        'proof-return',
      );
      await tester.ensureVisible(find.byTooltip('Show code'));
      await tester.tap(find.byTooltip('Show code'));
      await tester.pump();
      expect(find.text('Z 7 Y X'), findsOneWidget);
      expect(find.textContaining('4821'), findsNothing);
      await finish(tester);
    },
  );

  testWidgets('an offline refresh cannot leave an expired QR or code visible', (
    tester,
  ) async {
    await pump(tester, PassTab(client: f.api, now: () => now));
    await select(tester, 'Outbound');
    expect(find.byType(QrImageView), findsOneWidget);
    offline = true;
    now = now.add(const Duration(seconds: 11));
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('RESERVATION BOARDING CODE'), findsNothing);
    await finish(tester);
  });

  testWidgets('backgrounding clears the proof and stops refreshes', (
    tester,
  ) async {
    await pump(tester, PassTab(client: f.api, now: () => now));
    await select(tester, 'Outbound');
    final count = f.requests.length;
    // Inactive is delivered before paused; paused disables rendering frames.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('RESERVATION BOARDING CODE'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 1));
    expect(f.requests, hasLength(count));
    await finish(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets(
    'a delayed pass for the previous selection cannot replace the new one',
    (tester) async {
      final delayed = Completer<ResponseBody>();
      final original = f.reply;
      f.reply = (o) => o.path == '/v1/me/reservations/outbound/pass'
          ? delayed.future
          : original(o);
      await pump(tester, PassTab(client: f.api, now: () => now));
      await select(tester, 'Outbound', settle: false);
      await select(tester, 'Return');
      delayed.complete(proof('outbound'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<BoardingQr>(find.byType(BoardingQr)).data,
        'proof-return',
      );
      await finish(tester);
    },
  );

  testWidgets(
    'wallet displays actual balances, pause and dispute together, not a sample card',
    (tester) async {
      f.reply = (o) => o.path == '/v1/me/membership'
          ? jsonResponse({
              'data': {
                'membership': {'id': 'member', 'lifecycle': 'open'},
                'coverage': {
                  'id': 'period',
                  'startsAt': timestamp,
                  'endsAt': null,
                  'state': 'open',
                  'paused': true,
                  'renewalMode': 'manual',
                },
                'lastCoverageEndedAt': null,
                'commute': null,
                'access': {
                  'canReserve': false,
                  'blocks': [
                    {'kind': 'paused', 'scope': 'period', 'periodId': 'period'},
                    {
                      'kind': 'dispute',
                      'scope': 'period',
                      'periodId': 'period',
                    },
                  ],
                },
                'entitlements': {
                  'remainingRides': 12,
                  'credit': {'amountMinor': 1980, 'currency': 'GHS'},
                  'heldCredit': {'amountMinor': 100, 'currency': 'GHS'},
                  'availableCredit': {'amountMinor': 1880, 'currency': 'GHS'},
                },
              },
            })
          : jsonResponse(page([]));
      await pump(tester, WalletTab(client: f.api));
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Available: GHS 18.80'), findsOneWidget);
      expect(find.text('Held for checkout: GHS 1.00'), findsOneWidget);
      expect(find.text('Total: GHS 19.80'), findsOneWidget);
      expect(find.text('Service paused'), findsOneWidget);
      expect(find.text('Payment dispute — contact operations'), findsOneWidget);
      expect(find.textContaining('4281'), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(
        f.requests.last.queryParameters.keys,
        containsAll(['fromDate', 'toDate']),
      );
      await finish(tester);
    },
  );
}
