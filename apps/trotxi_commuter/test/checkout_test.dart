import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/checkout_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

void main() {
  late Fixture f;
  late List<Uri> launched;
  late String state, collection, url;
  late int amount;
  late bool launchWorks, empty;
  Map<String, Object?> purchase() => {
    'id': 'old-purchase',
    'plan': 'monthly',
    'state': state,
    'collectionState': collection,
    'price': {'amountMinor': 26400, 'currency': 'GHS'},
    'appliedCredit': {'amountMinor': 1980, 'currency': 'GHS'},
    'cashDue': {'amountMinor': amount, 'currency': 'GHS'},
    'checkout': {'url': url, 'expiresAt': null},
    'billingPeriodId': state == 'fulfilled' ? 'period' : null,
    'failureCode': null,
    'createdAt': '2025-01-01T00:00:00Z',
  };
  Future<void> drain(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    await tester.runAsync(() async {
      await action();
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
        if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> pump(
    WidgetTester tester, {
    bool noPurchases = false,
    String? unsafeUrl,
  }) async {
    state = 'awaiting_payment';
    collection = 'pending';
    amount = 24420;
    url = unsafeUrl ?? 'https://checkout.paystack.com/test-only';
    launchWorks = true;
    empty = noPurchases;
    launched = [];
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await drain(tester, () async {
      f = Fixture();
      await f.signedIn();
      f.reply = (o) => o.path == '/v1/me'
          ? jsonResponse({'data': account()})
          : jsonResponse(page(empty ? [] : [purchase()]));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CheckoutPage(
            client: f.api,
            openCheckout: (uri) async {
              launched.add(uri);
              return launchWorks;
            },
          ),
        ),
      );
    });
  }

  Future<void> pay(WidgetTester tester) async {
    final button = find.textContaining('Continue to Paystack');
    await tester.ensureVisible(button);
    await drain(tester, () => tester.tap(button));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    f.api.dispose();
  }

  testWidgets(
    'restart discovery finds old payment; browser return never declares it paid',
    (tester) async {
      await pump(tester);
      expect(find.textContaining('old-purchase'), findsOneWidget);
      expect(find.text('Prepare checkout'), findsNothing);
      expect(f.requests.last.queryParameters.containsKey('fromDate'), isFalse);
      await pay(tester);
      expect(
        launched.single.toString(),
        'https://checkout.paystack.com/test-only',
      );
      expect(find.textContaining('Purchase: awaitingPayment'), findsOneWidget);
      expect(find.textContaining('Server-confirmed fulfilment'), findsNothing);
      await drain(tester, () async {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });
      expect(find.textContaining('Server-confirmed fulfilment'), findsNothing);
      state = 'processing';
      collection = 'successful';
      await drain(
        tester,
        () => tester.tap(find.text('Refresh payment status')),
      );
      expect(find.textContaining('Do not pay again'), findsOneWidget);
      expect(find.textContaining('Continue to Paystack'), findsNothing);
      state = 'fulfilled';
      await drain(
        tester,
        () => tester.tap(find.text('Refresh payment status')),
      );
      expect(
        find.textContaining('Server-confirmed fulfilment'),
        findsOneWidget,
      );
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
      await finish(tester);
    },
  );
  testWidgets('opening failure leaves purchase visible and retryable', (
    tester,
  ) async {
    await pump(tester);
    launchWorks = false;
    await pay(tester);
    expect(find.textContaining('Could not open Paystack'), findsOneWidget);
    expect(find.textContaining('old-purchase'), findsOneWidget);
    expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
    await finish(tester);
  });
  testWidgets(
    'changed server amount requires new consent instead of opening an old quote',
    (tester) async {
      await pump(tester);
      amount = 24500;
      await pay(tester);
      expect(launched, isEmpty);
      expect(find.textContaining('amounts changed'), findsOneWidget);
      expect(find.text('Cash due: GHS 245.00'), findsOneWidget);
      await finish(tester);
    },
  );
  testWidgets('unsafe checkout URL is never offered', (tester) async {
    await pump(
      tester,
      unsafeUrl: 'https://checkout.paystack.com.attacker.test/x',
    );
    expect(find.textContaining('Continue to Paystack'), findsNothing);
    expect(find.textContaining('No usable checkout link'), findsOneWidget);
    expect(launched, isEmpty);
    await finish(tester);
  });
  testWidgets(
    'new checkout requires a commute and labels preparation rather than a charge',
    (tester) async {
      await pump(tester, noPurchases: true);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Prepare checkout'),
            )
            .onPressed,
        isNull,
      );
      expect(find.textContaining('does not charge you'), findsOneWidget);
      expect(
        find.textContaining('cancellation currently requires operations'),
        findsOneWidget,
      );
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
      await finish(tester);
    },
  );
}
