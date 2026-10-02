import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/Features/Search/commuter_search.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

SearchEntry entry(String title, {String keywords = '', String? subtitle}) =>
    SearchEntry(
      group: 'Go to',
      title: title,
      subtitle: subtitle,
      keywords: keywords,
      icon: Icons.search,
      onSelected: () {},
    );

void main() {
  test('every word must match, in any order and case', () {
    final entries = [
      entry('Wallet', keywords: 'money membership'),
      entry('Trips', subtitle: 'Morning commute'),
    ];
    List<String> titles(String q) =>
        searchEntries(entries, q).map((e) => e.title).toList();
    expect(titles(''), ['Wallet', 'Trips']);
    expect(titles('WALL'), ['Wallet']);
    expect(titles('membership money'), ['Wallet']);
    expect(titles('morning trips'), ['Trips']);
    expect(titles('wallet trips'), isEmpty);
    expect(titles('zzz'), isEmpty);
  });

  testWidgets('floating search finds screens and trips and opens a tab', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (request) => request.path == '/v1/me/reservations'
        ? jsonResponse(
            page([
              {
                'id': 'seat-1',
                'tripId': 'trip-1',
                'travelDate': '2026-09-16',
                'direction': 'outbound',
                'status': 'reserved',
                'pickupOccurrenceId': 'pickup',
                'dropoffOccurrenceId': 'dropoff',
                'source': 'confirmation',
                'createdAt': timestamp,
                'updatedAt': timestamp,
                'version': 1,
              },
            ]),
          )
        : jsonResponse({
            'error': {'code': 'not_found', 'message': 'No fixture'},
          }, 404);
    CommuterDestination? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCommuterSearch(
                context,
                client: fixture.api,
                onDestination: (d) => opened = d,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    // Empty query shows shortcuts, not trips.
    expect(find.text('Shortcuts'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.textContaining('Morning commute'), findsNothing);

    await tester.enterText(find.byType(TextField), 'morning');
    await tester.pumpAndSettle();
    expect(find.text('Your trips'), findsOneWidget);
    expect(find.textContaining('Morning commute'), findsOneWidget);
    expect(find.text('Wallet'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nothing like this');
    await tester.pumpAndSettle();
    expect(find.textContaining('No results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'money');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(opened, CommuterDestination.wallet);
    expect(find.byType(TextField), findsNothing); // Search closed.
    fixture.api.dispose();
  });
}
