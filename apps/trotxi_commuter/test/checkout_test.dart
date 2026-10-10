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
    Future<void> Function() action, {
    Finder? until,
  }) async {
    await tester.runAsync(() async {
      await action();
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
        if (until != null
            ? until.evaluate().isNotEmpty
            : find.byType(LinearProgressIndicator).evaluate().isEmpty) {
          break;
        }
      }
    });
    if (until != null) expect(until, findsOneWidget);
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
      expect(find.text('Monthly plan'), findsOneWidget);
      expect(find.textContaining('old-purchase'), findsNothing);
      expect(find.text('View payment details'), findsOneWidget);
      expect(find.text('Prepare checkout'), findsNothing);
      expect(f.requests.last.queryParameters.containsKey('fromDate'), isFalse);
      await pay(tester);
      expect(
        launched.single.toString(),
        'https://checkout.paystack.com/test-only',
      );
      expect(find.text('Awaiting payment'), findsOneWidget);
      expect(find.textContaining('Payment confirmed'), findsNothing);
      await drain(tester, () async {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });
      expect(find.textContaining('Payment confirmed'), findsNothing);
      state = 'processing';
      collection = 'successful';
      await drain(
        tester,
        () => tester.tap(find.text('Refresh payment status')),
      );
      expect(find.textContaining('Please do not pay again'), findsOneWidget);
      expect(find.textContaining('Continue to Paystack'), findsNothing);
      state = 'fulfilled';
      await drain(
        tester,
        () => tester.tap(find.text('Refresh payment status')),
      );
      expect(find.textContaining('Payment confirmed'), findsOneWidget);
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
    expect(find.text('Monthly plan'), findsOneWidget);
    expect(find.textContaining('old-purchase'), findsNothing);
    expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
    await finish(tester);
  });
  testWidgets('collected payment needing Ops review is not labelled failed', (
    tester,
  ) async {
    await pump(tester);
    state = 'failed';
    collection = 'successful';
    await drain(tester, () => tester.tap(find.text('Refresh payment status')));
    expect(find.text('Payment received · Under review'), findsOneWidget);
    expect(find.text('Payment failed'), findsNothing);
    expect(find.textContaining('Please do not pay again'), findsOneWidget);
    expect(find.textContaining('Continue to Paystack'), findsNothing);
    await finish(tester);
  });
  testWidgets('collected payment awaiting fulfilment is not shown as due', (
    tester,
  ) async {
    await pump(tester);
    collection = 'successful';
    await drain(tester, () => tester.tap(find.text('Refresh payment status')));
    expect(find.text('Payment processing'), findsOneWidget);
    expect(find.text('Collected via Paystack'), findsOneWidget);
    expect(find.textContaining('Please do not pay again'), findsOneWidget);
    expect(find.textContaining('Continue to Paystack'), findsNothing);
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
      expect(find.text('GHS 245.00'), findsOneWidget);
      await finish(tester);
    },
  );
  testWidgets('unsafe checkout URL is never offered', (tester) async {
    await pump(
      tester,
      unsafeUrl: 'https://checkout.paystack.com.attacker.test/x',
    );
    expect(find.textContaining('Continue to Paystack'), findsNothing);
    expect(
      find.textContaining('The payment link is unavailable'),
      findsOneWidget,
    );
    expect(launched, isEmpty);
    await finish(tester);
  });
  testWidgets('details show support action without database ids', (
    tester,
  ) async {
    await pump(tester);
    state = 'fulfilled';
    collection = 'successful';
    final previousReply = f.reply;
    f.reply = (request) => request.path == '/v1/me/purchases/old-purchase'
        ? jsonResponse({'data': purchase()})
        : previousReply(request);
    await drain(tester, () => tester.tap(find.text('Refresh payment status')));
    await tester.ensureVisible(find.text('View payment details'));
    await drain(
      tester,
      () => tester.tap(find.text('View payment details')),
      until: find.text('Copy reference for support'),
    );
    expect(find.text('Copy reference for support'), findsOneWidget);
    expect(find.text('Billing period'), findsNothing);
    expect(find.text('period'), findsNothing);
    expect(find.textContaining('old-purchase'), findsNothing);
    await finish(tester);
  });
  testWidgets(
    'new checkout directs riders to Ops offers without a direct purchase form',
    (tester) async {
      await pump(tester, noPurchases: true);
      expect(find.text('Prepare checkout'), findsNothing);
      expect(find.text('View waitlist'), findsOneWidget);
      expect(f.requests.where((r) => r.method == 'POST'), isEmpty);
      await finish(tester);
    },
  );
}
