import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/standby_page.dart';
import 'replacement_fixture.dart';

void main() {
  testWidgets(
    'phone verification gates requests and offer review discloses each journey credit before acceptance',
    (tester) async {
      final f = Fixture();
      var verified = false;
      var offered = false;
      final legs = [
        for (final direction in ['outbound', 'return'])
          {
            'direction': direction,
            'scheduleId': '$direction-schedule',
            'patternVersionId': '$direction-version',
            'pickupOccurrenceId': '$direction-pickup',
            'dropoffOccurrenceId': '$direction-dropoff',
          },
      ];
      f.reply = (request) {
        if (request.path == '/v1/me/verification') {
          return jsonResponse({
            'data': {
              'phone': {
                'status': verified ? 'verified' : 'incomplete',
                'maskedNumber': null,
                'verifiedAt': null,
              },
              'standbyEligible': verified,
              'missing': verified ? <String>[] : ['phone'],
            },
          });
        }
        if (request.path == '/v1/me/standby') {
          return jsonResponse(
            page(
              offered
                  ? [
                      {
                        'id': 'application',
                        'riderId': 'rider',
                        'riderName': 'Ama',
                        'routeName': 'B to C',
                        'state': 'offered',
                        'createdAt': timestamp,
                        'travelDays': [1, 3, 5],
                        'selection': {
                          'plan': 'monthly',
                          'routeId': 'route',
                          'useCredit': false,
                          'legs': legs,
                        },
                        'offer': {
                          'id': 'offer',
                          'state': 'offered',
                          'expiresAt': '2030-01-01T00:00:00Z',
                          'purchaseId': null,
                          'terms': {
                            'coverageStart': '2030-01-02',
                            'coverageEnd': '2030-01-30',
                            'price': {'amountMinor': 7000, 'currency': 'GHS'},
                            'legs': [
                              for (var i = 0; i < 2; i++)
                                {
                                  ...legs[i],
                                  'pickupName': i == 0 ? 'B' : 'C',
                                  'dropoffName': i == 0 ? 'C' : 'B',
                                  'fareId': 'fare-$i',
                                  'fare': {
                                    'amountMinor': 500 + i * 300,
                                    'currency': 'GHS',
                                  },
                                  'ridesGranted': 6,
                                  'travelDays': [1, 3, 5],
                                  'creditPerUnusedRide': {
                                    'amountMinor': 100 + i * 100,
                                    'currency': 'GHS',
                                  },
                                },
                            ],
                          },
                        },
                      },
                    ]
                  : [],
            ),
          );
        }
        return jsonResponse({'data': account()});
      };
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Future<void> drain(Future<void> Function() action) async {
        await tester.runAsync(() async {
          await action();
          for (var i = 0; i < 20; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            await tester.pump();
          }
        });
        await tester.pumpAndSettle();
      }

      await drain(() async {
        await f.signedIn();
        await tester.pumpWidget(MaterialApp(home: StandbyPage(client: f.api)));
      });
      expect(find.text('Verify phone'), findsOneWidget);
      expect(find.text('Choose a route'), findsNothing);
      verified = true;
      await drain(() => tester.tap(find.text('Refresh')));
      expect(find.text('Choose a route'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(7));
      offered = true;
      await drain(() => tester.tap(find.text('Refresh')));
      expect(
        find.text('Your offer is ready. Review it below before it expires.'),
        findsOneWidget,
      );
      expect(find.textContaining('We will let you know'), findsNothing);
      await tester.tap(find.text('Review your offer'));
      await tester.pumpAndSettle();
      expect(find.text('GHS 70.00'), findsOneWidget);
      expect(find.text('Credit per unused ride: GHS 1.00'), findsOneWidget);
      expect(find.text('Credit per unused ride: GHS 2.00'), findsOneWidget);
      expect(find.text('6 rides · Mon, Wed, Fri'), findsNWidgets(2));
      expect(
        f.requests.where(
          (r) => r.method == 'POST' && r.path.endsWith('/accept'),
        ),
        isEmpty,
      );
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      f.api.dispose();
    },
  );
}
