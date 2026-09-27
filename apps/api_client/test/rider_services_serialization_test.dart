import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';

void main() {
  test('no personal pause is a nullable data response', () {
    final response = standardSerializers.deserializeWith(
      OptionalPersonalPauseResponse.serializer,
      {'data': null},
    )!;
    expect(response.data, isNull);
  });

  test('pause dates and unapplied extension survive serialization', () {
    final json = {
      'id': 'eaa5b6d3-5260-41bd-98de-98f39499bce4',
      'startDate': '2026-09-21',
      'resumeDate': '2026-09-24',
      'status': 'scheduled',
      'projectedEndsAt': '2026-09-30T00:00:00.000Z',
      'extensionApplied': false,
    };
    final pause = standardSerializers.deserializeWith(
      PersonalPause.serializer,
      json,
    )!;
    expect(pause.status, PersonalPauseStatusEnum.scheduled);
    expect(pause.extensionApplied, isFalse);
    expect(
      standardSerializers.serializeWith(PersonalPause.serializer, pause),
      json,
    );
  });

  test('price preview keeps pesewas and manual nonbinding semantics', () {
    Map<String, Object> money(int amount) => {
          'amountMinor': amount,
          'currency': 'GHS',
        };
    final quote = standardSerializers.deserializeWith(
      PurchaseQuote.serializer,
      {
        'routeId': 'd3cf3252-c547-4372-bdcb-1d751fa600a1',
        'plan': 'monthly',
        'ridesGranted': 44,
        'fare': money(600),
        'price': money(26400),
        'availableCredit': money(0),
        'appliedCredit': money(0),
        'cashDue': money(26400),
        'minimumCashDue': money(100),
        'renewalMode': 'manual',
        'binding': false,
        'quotedAt': '2026-09-20T03:00:00.000Z',
      },
    )!;
    expect(quote.cashDue.amountMinor, 26400);
    expect(quote.minimumCashDue.amountMinor, 100);
    expect(quote.binding, isFalse);
    expect(quote.renewalMode, PurchaseQuoteRenewalModeEnum.manual);
  });

  test('ride history retains negative debits and empty pagination', () {
    final entry = standardSerializers.deserializeWith(RideEntry.serializer, {
      'id': 'd3cf3252-c547-4372-bdcb-1d751fa600a1',
      'deltaRides': -1,
      'reason': 'boarding',
      'billingPeriodId': 'b16f676a-3cf8-4645-a889-101355a1c806',
      'createdAt': '2026-09-20T03:00:00.000Z',
    })!;
    expect(entry.deltaRides, -1);
    expect(entry.reason, RideEntryReasonEnum.boarding);
    final page = standardSerializers.deserializeWith(RideEntryPage.serializer, {
      'data': <Object>[],
      'page': {'nextCursor': null},
    })!;
    expect(page.data, isEmpty);
    expect(page.page.nextCursor, isNull);
  });
}
