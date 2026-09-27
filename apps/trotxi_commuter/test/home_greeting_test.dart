import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/home_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

class FixedLifecycle extends RideLifecycleNotifier {
  FixedLifecycle(this.value);
  final RideLifecycleState value;
  @override
  Future<RideLifecycleState?> build() async => value;
}

void main() {
  for (final boarded in [false, true]) {
    testWidgets(
      'greeting distinguishes ${boarded ? 'boarded' : 'reserved'} seat',
      (tester) async {
        final fixture = Fixture();
        final state = boarded
            ? const RideBoarded(tripId: 'trip')
            : const RideReserved(
                tripId: 'trip',
                etaPhase: EtaPhase(isEstimated: true),
              );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              rideLifecycleProvider.overrideWith(() => FixedLifecycle(state)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: HomeTab(
                client: fixture.api,
                userData: wire.Account(
                  (b) => b
                    ..id = 'rider'
                    ..displayName = 'Ama'
                    ..role = wire.AccountRoleEnum.commuter
                    ..createdAt = DateTime.utc(2026, 9, 16),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('You have boarded this departure.'),
          boarded ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Your seat is confirmed for this departure.'),
          boarded ? findsNothing : findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
        fixture.api.dispose();
      },
    );
  }
}
