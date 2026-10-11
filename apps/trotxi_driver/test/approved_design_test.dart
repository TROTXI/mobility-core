import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trotxi_driver/data/device_readiness.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/scan_page.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/driver_information_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/location_connectivity_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/confirm_account_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/account_linked_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/pin_setup_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/forgot_pin_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/cant_sign_in_page.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/end_run_page.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/Presentations/Onboarding/pages/first_launch_page.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/manifest_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/run_page.dart';
import 'package:trotxi_driver/Presentations/Schedule/pages/schedule_page.dart';
import 'package:trotxi_driver/Presentations/Shell/pages/driver_shell.dart';
import 'package:trotxi_driver/Presentations/Support/pages/incident_support_page.dart';
import 'package:trotxi_driver/Presentations/Work/pages/work_requests_page.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'package:trotxi_driver/data/work_repository.dart';
import 'package:trotxi_driver/data/incidents_repository.dart';

const _driver = DriverSession(
  driverId: 'preview',
  driverCode: 'DR-B7K9',
  fullName: 'Kwame Asare',
  mustChangePin: false,
);

class _Auth implements DriverAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api implements DriverApi {
  @override
  Future<T> get<T>(
    String path,
    Serializer<T> serializer, {
    Map<String, dynamic>? query,
  }) async => throw const OfflineException();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Config implements ConfigRepository {
  @override
  Future<AppConfig> load() async => AppConfig.empty;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Maps implements RouteMapRepository {
  @override
  Future<RouteShape> shapeFor(String routeId) async => const RouteShape(
    points: [],
    stops: [],
    source: RouteShapeSource.stops,
    runCount: 0,
  );
  @override
  Future<VehicleFix?> vehicleOn(String runId) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Work implements WorkRepository {
  @override
  Future<List<OpenRoute>> openRoutes() async => const [
    OpenRoute(id: 'route-preview', name: 'Circle → Madina'),
  ];
  @override
  Future<List<WorkRequest>> mine() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Incidents implements IncidentsRepository {
  @override
  Future<List<DriverIncident>> mine() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Readiness implements DeviceReadinessService {
  const _Readiness(this.allowed);
  final bool allowed;
  @override
  Future<DeviceReadiness> check() async => DeviceReadiness(
    camera: allowed ? PermissionStatus.granted : PermissionStatus.denied,
    location: allowed ? PermissionStatus.granted : PermissionStatus.denied,
    locationServices: allowed,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Trips implements TripsRepository {
  _Trips({bool active = false})
    : run = DriverRun(
        id: 'trip-preview',
        routeId: 'route-preview',
        routeName: 'Circle → Madina',
        vehicleRegistration: 'GT 4821-22',
        scheduledAt: DateTime.utc(2026, 10, 12, 6, 30),
        status: active ? RunStatus.active : RunStatus.scheduled,
      );
  final DriverRun run;
  int completions = 0;
  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async => [run];
  @override
  Future<List<ManifestRider>> manifest(String runId) async => [
    for (final (index, name) in [
      'Ama Mensah',
      'Kojo Asante',
      'Akosua Frimpong-Boateng',
    ].indexed)
      ManifestRider(
        reservationId: 'r$index',
        name: name,
        avatarUrl: null,
        boarded: index == 0 && run.isActive,
        direction: 'outbound',
        source: null,
        noShow: false,
      ),
  ];
  @override
  Future<List<DriverStop>> stopsFor(String routeId) async => const [
    DriverStop(seq: 0, name: 'Circle', occurrenceId: 's0'),
    DriverStop(seq: 1, name: 'Madina', occurrenceId: 's1'),
  ];
  @override
  Future<TripDetail> detail(String runId) async =>
      TripDetail(stopCount: 2, vehicleRegistration: run.vehicleRegistration);
  @override
  Future<RunSummary> summary(String runId) async => RunSummary(
    boarded: 3,
    notBoarded: 0,
    byQr: 2,
    byPin: 1,
    byPhoto: 0,
    stopCount: 2,
    startedAt: DateTime.utc(2026, 10, 12, 6, 30),
    completedAt: DateTime.utc(2026, 10, 12, 7, 15),
  );
  @override
  Future<DriverRun> complete(String runId) async {
    completions++;
    return run;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _frame(String title, Widget child) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: SafeArea(child: child),
);

Future<_Trips> _show(
  WidgetTester tester,
  String page, {
  bool dark = false,
  double scale = 1,
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  const location = MethodChannel('flutter.baseflow.com/geolocator');
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    location,
    (call) async => call.method == 'checkPermission' ? 2 : true,
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      location,
      null,
    ),
  );
  final trips = _Trips(active: page != 'today' && page != 'pre-trip');
  final run = RunController(trips: trips, run: trips.run);
  final today = TodayController(
    trips: trips,
    now: () => DateTime.utc(2026, 10, 12, 5),
  );
  final positions = PositionPublisher(client: _Api());
  await run.load();
  await today.load();
  addTearDown(run.dispose);
  addTearDown(today.dispose);
  addTearDown(positions.dispose);
  final child = switch (page) {
    'readiness' => DeviceReadinessPage(
      service: const _Readiness(true),
      onContinue: () {},
    ),
    'permissions' => DeviceReadinessPage(
      service: const _Readiness(false),
      onContinue: () {},
    ),
    'scan' => _frame(
      'Scan',
      ScanPage(
        runId: trips.run.id,
        scannerBuilder: (_, _) =>
            const Center(child: Text('Camera preview on device')),
      ),
    ),
    'information' => _frame(
      'Driver information',
      const DriverInformationPage(showHeading: false),
    ),
    'connectivity' => LocationConnectivityPage(run: trips.run),
    'linked' => AccountLinkedPage(session: _driver, onContinue: () {}),
    'pin-setup' => PinSetupPage(
      changePin:
          ({
            required currentPin,
            required newPin,
            required idempotencyKey,
          }) async {},
      onChanged: () async {},
      onUncertain: () async {},
      onSignOut: () async {},
    ),
    'forgot-pin' => const ForgotPinPage(),
    'cant-sign-in' => const CantSignInPage(),
    'end-trip' => const EndRunPage(),
    'report-incident' => ReportIncidentPage(activeRun: trips.run),
    'reports' => const MyReportsPage(),
    'route-request' => const RouteChangeRequestPage(),
    'leave-request' => const LeaveRequestPage(),
    'welcome' => DriverFirstLaunchPage(onContinue: () async {}),
    'sign-in' => SignInPage(auth: _Auth(), onSignedIn: (_) {}),
    'confirm' => ConfirmAccountPage(
      session: _driver,
      onConfirmed: () {},
      onRejected: () async {},
    ),
    'today' || 'today-active' => const DriverShell(),
    'pre-trip' || 'trip' => _frame('Trip', RunPage(run: trips.run)),
    'manifest' => _frame('Passengers', const ManifestPage()),
    'boarding' => BoardByCodePage(runId: trips.run.id),
    'summary' => const RunSummaryPage(),
    'profile' => _frame('Profile', const ProfilePage()),
    'schedule' => _frame('Schedule', const SchedulePage(showHeading: false)),
    'requests' => _frame(
      'Work requests',
      const WorkRequestsPage(showHeading: false),
    ),
    'support' => _frame(
      'Help & support',
      const IncidentSupportPage(showHeading: false),
    ),
    _ => throw ArgumentError(page),
  };
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<DriverApi>.value(value: _Api()),
        Provider<TripsRepository>.value(value: trips),
        Provider<RouteMapRepository>.value(value: _Maps()),
        Provider<WorkRepository>.value(value: _Work()),
        Provider<IncidentsRepository>.value(value: _Incidents()),
        ChangeNotifierProvider<RunController>.value(value: run),
        ChangeNotifierProvider<TodayController>.value(value: today),
        ChangeNotifierProvider<PositionPublisher>.value(value: positions),
        ChangeNotifierProvider(create: (_) => AppThemeController()),
        ChangeNotifierProvider(
          create: (_) => ConfigController(config: _Config()),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionController(auth: _Auth())..onSignedIn(_driver),
        ),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: RepaintBoundary(key: const ValueKey('preview'), child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return trips;
}

void main() {
  const pages = [
    'readiness',
    'permissions',
    'scan',
    'information',
    'connectivity',
    'linked',
    'pin-setup',
    'forgot-pin',
    'cant-sign-in',
    'end-trip',
    'report-incident',
    'reports',
    'route-request',
    'leave-request',
    'welcome',
    'sign-in',
    'confirm',
    'today',
    'today-active',
    'pre-trip',
    'trip',
    'manifest',
    'boarding',
    'summary',
    'profile',
    'schedule',
    'requests',
    'support',
  ];
  for (final page in pages) {
    for (final dark in [false, true]) {
      testWidgets('$page fits narrow screen with large text, dark=$dark', (
        tester,
      ) async {
        await _show(
          tester,
          page,
          dark: dark,
          scale: 1.6,
          size: const Size(320, 700),
        );
        expect(tester.takeException(), isNull);
        for (final scrollable in find.byType(Scrollable).evaluate().toList()) {
          final state =
              (scrollable as StatefulElement).state as ScrollableState;
          state.position.jumpTo(state.position.maxScrollExtent);
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets('Today continues active trip without completing it', (
    tester,
  ) async {
    final trips = await _show(tester, 'today-active');
    await tester.ensureVisible(find.text('Continue trip'));
    await tester.tap(find.text('Continue trip'));
    await tester.pumpAndSettle();
    expect(find.byType(RunPage), findsOneWidget);
    expect(trips.completions, 0);
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  const output = String.fromEnvironment('DESIGN_OUTPUT');
  for (final dark in [false, true]) {
    testWidgets('selected two-digit calendar date at 2x text, dark=$dark', (
      tester,
    ) async {
      if (output.isNotEmpty) {
        await (FontLoader(
          'Inter',
        )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      }
      await _show(
        tester,
        'schedule',
        dark: dark,
        scale: 2,
        size: const Size(320, 700),
      );
      await tester.ensureVisible(find.text('28'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('28'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.widget<Text>(find.text('28')).style?.color,
        dark ? AppColors.dark.onAction : AppColors.light.onAction,
      );
      if (output.isNotEmpty) {
        await expectLater(
          find.byKey(const ValueKey('preview')),
          matchesGoldenFile(
            '$output/calendar-large-${dark ? 'dark' : 'light'}.png',
          ),
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
  if (output.isNotEmpty) {
    for (final dark in [false, true]) {
      for (final page in pages) {
        testWidgets('render $page dark=$dark', (tester) async {
          await (FontLoader(
            'Inter',
          )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          await _show(tester, page, dark: dark);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const ValueKey('preview')),
            matchesGoldenFile('$output/$page-${dark ? 'dark' : 'light'}.png'),
          );
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
