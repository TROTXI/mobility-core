import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:test/test.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// Guards the generated client's serializer wiring: `standardSerializers` is
/// built from a hand-maintained `@SerializersFor` list, so a model that is
/// generated but never registered compiles fine and only fails at runtime,
/// on the response it was meant to parse.
///
/// The exact `GET /v1/me/membership` body the wallet page has to render for a
/// brand-new rider: no membership, no coverage, no commute, zero balances.
const _emptyRider = '''
{
  "data": {
    "membership": null,
    "coverage": null,
    "lastCoverageEndedAt": null,
    "access": { "canReserve": false, "blocks": [] },
    "commute": null,
    "entitlements": {
      "remainingRides": 0,
      "credit": { "amountMinor": 0, "currency": "GHS" },
      "heldCredit": { "amountMinor": 0, "currency": "GHS" },
      "availableCredit": { "amountMinor": 0, "currency": "GHS" }
    }
  }
}
''';

/// A subscribed rider, so the non-null branches get exercised too.
const _activeRider = '''
{
  "data": {
    "membership": { "id": "mem_1", "lifecycle": "open" },
    "coverage": {
      "id": "cov_1",
      "startsAt": "2026-09-01T00:00:00Z",
      "endsAt": "2026-10-01T00:00:00Z",
      "state": "open",
      "paused": false,
      "renewalMode": "manual"
    },
    "lastCoverageEndedAt": null,
    "access": {
      "canReserve": false,
      "blocks": [{ "kind": "paused", "scope": "period", "periodId": "bp_1" }]
    },
    "commute": {
      "id": "com_1",
      "routeId": "rt_1",
      "routeName": "Adenta - Airport City",
      "effectiveFrom": "2026-09-01",
      "effectiveTo": null,
      "legs": [
        {
          "direction": "outbound",
          "scheduleId": "sch_1",
          "patternVersionId": "pv_1",
          "pickupOccurrenceId": "so_1",
          "dropoffOccurrenceId": "so_2",
          "localDeparture": "06:30",
          "timeZone": "Africa/Accra",
          "pickupName": "Adenta Barrier",
          "dropoffName": "Airport City"
        },
        {
          "direction": "return",
          "scheduleId": "sch_2",
          "patternVersionId": "pv_2",
          "pickupOccurrenceId": "so_3",
          "dropoffOccurrenceId": "so_4",
          "localDeparture": "17:30",
          "timeZone": "Africa/Accra",
          "pickupName": "Airport City",
          "dropoffName": "Adenta Barrier"
        }
      ]
    },
    "entitlements": {
      "remainingRides": 23,
      "credit": { "amountMinor": 1500, "currency": "GHS" },
      "heldCredit": { "amountMinor": 500, "currency": "GHS" },
      "availableCredit": { "amountMinor": 1000, "currency": "GHS" }
    }
  }
}
''';

const _ridePage = '''
{
  "data": [
    {
      "id": "re_1",
      "deltaRides": -1,
      "reason": "boarding",
      "billingPeriodId": "bp_1",
      "createdAt": "2026-09-19T06:35:00Z"
    },
    {
      "id": "re_2",
      "deltaRides": 40,
      "reason": "allocation",
      "billingPeriodId": "bp_1",
      "createdAt": "2026-09-01T00:00:00Z"
    }
  ],
  "page": { "nextCursor": null }
}
''';

const _purchasePage = '''
{
  "data": [
    {
      "id": "pur_1",
      "plan": "monthly",
      "state": "fulfilled",
      "collectionState": "successful",
      "price": { "amountMinor": 30000, "currency": "GHS" },
      "appliedCredit": { "amountMinor": 1000, "currency": "GHS" },
      "cashDue": { "amountMinor": 29000, "currency": "GHS" },
      "checkout": null,
      "billingPeriodId": "bp_1",
      "failureCode": null,
      "createdAt": "2026-09-01T00:00:00Z"
    }
  ],
  "page": { "nextCursor": null }
}
''';

T _parse<T>(String body, FullType type) {
  return standardSerializers.deserialize(
    json.decode(body) as Object,
    specifiedType: type,
  ) as T;
}

void main() {
  test('parses an empty rider membership', () {
    final response = _parse<MembershipResponse>(
      _emptyRider,
      const FullType(MembershipResponse),
    );
    final data = response.data;

    expect(data.membership, isNull);
    expect(data.coverage, isNull);
    expect(data.lastCoverageEndedAt, isNull);
    expect(data.commute, isNull);
    expect(data.access.canReserve, isFalse);
    expect(data.access.blocks, isEmpty);
    expect(data.entitlements.remainingRides, 0);
    expect(data.entitlements.availableCredit.amountMinor, 0);
    expect(
      data.entitlements.availableCredit.currency,
      MoneyCurrencyEnum.GHS,
    );
  });

  test('parses an active membership with a commute and an access block', () {
    final data = _parse<MembershipResponse>(
      _activeRider,
      const FullType(MembershipResponse),
    ).data;

    expect(data.membership!.lifecycle, MembershipMembershipLifecycleEnum.open);
    expect(data.coverage!.state, MembershipCoverageStateEnum.open);
    expect(data.coverage!.paused, isFalse);
    expect(
      data.coverage!.renewalMode,
      MembershipCoverageRenewalModeEnum.manual,
    );
    expect(data.coverage!.endsAt, DateTime.utc(2026, 10, 1));

    expect(data.access.blocks.single.kind, AccessBlockKindEnum.paused);
    expect(data.access.blocks.single.scope, AccessBlockScopeEnum.period);

    final commute = data.commute!;
    expect(commute.routeName, 'Adenta - Airport City');
    expect(commute.effectiveFrom.toDateTime(), DateTime(2026, 9, 1));
    expect(commute.effectiveTo, isNull);
    expect(commute.legs, hasLength(2));
    expect(
      commute.legs.first.direction,
      CommuteLegViewDirectionEnum.outbound,
    );
    // `return` is a Dart keyword, so the generator renames the constant.
    expect(commute.legs.last.direction, CommuteLegViewDirectionEnum.return_);
    expect(commute.legs.last.dropoffName, 'Adenta Barrier');

    expect(data.entitlements.remainingRides, 23);
    expect(data.entitlements.heldCredit.amountMinor, 500);
  });

  test('parses the ride-entry ledger page', () {
    final page = _parse<RideEntryPage>(
      _ridePage,
      const FullType(RideEntryPage),
    );

    expect(page.page.nextCursor, isNull);
    expect(page.data, hasLength(2));
    expect(page.data.first.reason, RideEntryReasonEnum.boarding);
    expect(page.data.first.deltaRides, -1);
    expect(page.data.last.reason, RideEntryReasonEnum.allocation);
  });

  test('parses the purchase page', () {
    final page = _parse<PurchasePage>(
      _purchasePage,
      const FullType(PurchasePage),
    );

    final purchase = page.data.single;
    expect(purchase.plan, PurchasePlanEnum.monthly);
    expect(purchase.state, PurchaseStateEnum.fulfilled);
    expect(
      purchase.collectionState,
      PurchaseCollectionStateEnum.successful,
    );
    expect(purchase.checkout, isNull);
    expect(purchase.price.amountMinor, 30000);
    expect(purchase.cashDue.amountMinor, 29000);
  });
}
