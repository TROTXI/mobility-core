import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

class _Auth implements DriverAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OfflineApi implements DriverApi {
  @override
  Future<T> get<T>(
    String path,
    Serializer<T> serializer, {
    Map<String, dynamic>? query,
  }) async => throw const OfflineException();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final (mode, scale) in [
    (ThemeMode.light, 1.0),
    (ThemeMode.dark, 1.0),
    (ThemeMode.light, 1.6),
    (ThemeMode.dark, 1.6),
  ]) {
    testWidgets(
      'Profile scrolls and accepts taps in $mode at $scale text scale',
      (tester) async {
        const location = MethodChannel('flutter.baseflow.com/geolocator');
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(location, (call) async {
          return switch (call.method) {
            'checkPermission' => 2,
            'isLocationServiceEnabled' => true,
            _ => throw StateError('Unexpected location call: ${call.method}'),
          };
        });
        addTearDown(() => messenger.setMockMethodCallHandler(location, null));
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final theme = AppThemeController(initialMode: mode);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<DriverApi>.value(value: _OfflineApi()),
              ChangeNotifierProvider(
                create: (_) => SessionController(auth: _Auth()),
              ),
              ChangeNotifierProvider<AppThemeController>.value(value: theme),
            ],
            child: ListenableBuilder(
              listenable: theme,
              builder: (context, _) => MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: theme.themeMode,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const Scaffold(body: ProfilePage()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final next = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        await tester.ensureVisible(
          find.text(next == ThemeMode.dark ? 'Dark' : 'Light'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(next == ThemeMode.dark ? 'Dark' : 'Light'));
        await tester.pumpAndSettle();
        expect(theme.themeMode, next);
        expect(tester.takeException(), isNull);

        final scrollable = find.byType(Scrollable).first;
        tester.state<ScrollableState>(scrollable).position.jumpTo(0);
        await tester.pumpAndSettle();
        final before = tester
            .state<ScrollableState>(scrollable)
            .position
            .pixels;
        for (
          var i = 0;
          i < 10 && find.text('Sign out').hitTestable().evaluate().isEmpty;
          i++
        ) {
          await tester.drag(find.byType(ListView), const Offset(0, -250));
          await tester.pumpAndSettle();
        }
        expect(find.text('Sign out').hitTestable(), findsOneWidget);
        expect(
          tester.state<ScrollableState>(scrollable).position.pixels,
          greaterThan(before),
        );
        await tester.tap(find.text('Sign out'));
        await tester.pumpAndSettle();
        expect(find.text('Sign out?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Sign out?'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        theme.dispose();
      },
    );
  }
}
