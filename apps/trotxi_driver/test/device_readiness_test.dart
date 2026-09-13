import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/data/device_readiness.dart';

DeviceReadiness _state({
  PermissionStatus camera = PermissionStatus.denied,
  PermissionStatus location = PermissionStatus.denied,
  bool services = true,
}) => DeviceReadiness(
  camera: camera,
  location: location,
  locationServices: services,
);

class _Device implements DeviceReadinessService {
  DeviceReadiness value = _state();
  int checks = 0;
  int appSettings = 0;
  int locationSettings = 0;
  bool opensSettings = true;
  bool fails = false;
  Completer<void>? requestPending;
  Completer<DeviceReadiness>? checkPending;
  final requests = <DevicePermission>[];

  @override
  Future<DeviceReadiness> check() async {
    checks++;
    if (fails) throw StateError('Device unavailable');
    return checkPending?.future ?? value;
  }

  @override
  Future<void> request(DevicePermission permission) async {
    requests.add(permission);
    await requestPending?.future;
  }

  @override
  Future<bool> openAppSettings() async {
    appSettings++;
    return opensSettings;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettings++;
    return opensSettings;
  }
}

Future<void> _pump(
  WidgetTester tester,
  _Device device, {
  bool beforeTrip = true,
  bool dark = false,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: DeviceReadinessPage(service: device, beforeTrip: beforeTrip),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'only granted location with services on permits a trip; camera is optional',
    () {
      for (final location in PermissionStatus.values) {
        for (final camera in PermissionStatus.values) {
          for (final services in [true, false]) {
            expect(
              _state(
                location: location,
                camera: camera,
                services: services,
              ).canStartTrip,
              location == PermissionStatus.granted && services,
            );
          }
        }
      }
    },
  );

  testWidgets(
    'Start rechecks location and stays locked if access was revoked',
    (tester) async {
      final device = _Device()
        ..value = _state(location: PermissionStatus.granted);
      await _pump(tester, device);
      device.value = _state(location: PermissionStatus.permanentlyDenied);
      await _tap(tester, 'Start with code boarding');
      expect(device.checks, 2);
      expect(find.byType(DeviceReadinessPage), findsOneWidget);
      expect(find.text('Open location settings'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Start trip'),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('opening only checks; denied location blocks trip start', (
    tester,
  ) async {
    final device = _Device();
    await _pump(tester, device);
    expect(device.checks, 1);
    expect(device.requests, isEmpty);
    expect(find.text('Not allowed'), findsNWidgets(2));
    expect(find.textContaining('Board by code'), findsOneWidget);
    await tester.ensureVisible(find.text('Start trip'));
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Start trip'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'camera and foreground location are requested only by their actions',
    (tester) async {
      final device = _Device();
      await _pump(tester, device);
      await _tap(tester, 'Allow camera');
      expect(device.requests, [DevicePermission.camera]);
      await _tap(tester, 'Allow location access');
      expect(device.requests, [
        DevicePermission.camera,
        DevicePermission.location,
      ]);
      expect(device.checks, 3);
    },
  );

  testWidgets(
    'permanent denial opens settings, never repeats permission prompt',
    (tester) async {
      final device = _Device()
        ..value = _state(camera: PermissionStatus.permanentlyDenied);
      await _pump(tester, device);
      await _tap(tester, 'Open camera settings');
      expect(device.appSettings, 1);
      expect(device.requests, isEmpty);
    },
  );

  testWidgets(
    'services off is independent of granted location and opens location settings',
    (tester) async {
      final device = _Device()
        ..value = _state(location: PermissionStatus.granted, services: false);
      await _pump(tester, device);
      await _tap(tester, 'Turn on location services');
      expect(device.locationSettings, 1);
      expect(device.appSettings, 0);
      expect(device.requests, isEmpty);
    },
  );

  testWidgets('resume reflects grants and revocations without requesting', (
    tester,
  ) async {
    final device = _Device();
    await _pump(tester, device);
    device.value = _state(
      camera: PermissionStatus.granted,
      location: PermissionStatus.granted,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start trip'));
    expect(find.text('Start trip'), findsOneWidget);
    device.value = _state();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Start trip'),
          )
          .onPressed,
      isNull,
    );
    expect(device.requests, isEmpty);
  });

  testWidgets('request and resume serialize and recheck after the prompt', (
    tester,
  ) async {
    final device = _Device()..requestPending = Completer<void>();
    await _pump(tester, device);
    await tester.ensureVisible(find.text('Allow camera'));
    await tester.tap(find.text('Allow camera'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(device.checks, 1);
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Allow camera'),
          )
          .onPressed,
      isNull,
    );
    device.value = _state(camera: PermissionStatus.permanentlyDenied);
    device.requestPending!.complete();
    await tester.pumpAndSettle();
    expect(device.checks, 2);
    expect(find.text('Open camera settings'), findsOneWidget);
  });

  testWidgets('a late native check after disposal is harmless', (tester) async {
    final device = _Device()..checkPending = Completer<DeviceReadiness>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: DeviceReadinessPage(service: device),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    device.checkPending!.complete(_state());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed checks clear stale ready state and can be retried', (
    tester,
  ) async {
    final device = _Device()
      ..value = _state(
        camera: PermissionStatus.granted,
        location: PermissionStatus.granted,
      );
    await _pump(tester, device);
    device.fails = true;
    await _tap(tester, 'Check again');
    expect(find.textContaining('Could not check device'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Start trip'),
          )
          .onPressed,
      isNull,
    );
    device.fails = false;
    await _tap(tester, 'Check again');
    expect(find.textContaining('Could not check device'), findsNothing);
    expect(find.text('Start trip'), findsOneWidget);
  });

  testWidgets(
    'settings launch failure gives manual recovery, not a silent no-op',
    (tester) async {
      final device = _Device()
        ..opensSettings = false
        ..value = _state(camera: PermissionStatus.permanentlyDenied);
      await _pump(tester, device);
      await _tap(tester, 'Open camera settings');
      expect(find.textContaining('Could not check device'), findsOneWidget);
    },
  );

  testWidgets(
    'restricted access explains policy and does not offer an ineffective prompt',
    (tester) async {
      final device = _Device()
        ..value = _state(camera: PermissionStatus.restricted);
      await _pump(tester, device, beforeTrip: false);
      expect(
        find.textContaining('Restricted by device policy'),
        findsOneWidget,
      );
      expect(find.text('Allow camera'), findsNothing);
      expect(find.text('Start trip'), findsNothing);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'small screen, large text, ${dark ? 'dark' : 'light'} theme remains scrollable',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pump(tester, _Device(), dark: dark, textScale: 2);
        await tester.ensureVisible(find.text('Start trip'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('leaving readiness requires explicit acknowledgement to start', (
    tester,
  ) async {
    bool? result;
    final device = _Device();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) =>
                        DeviceReadinessPage(service: device, beforeTrip: true),
                  ),
                );
              },
              child: const Text('Review'),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, 'Review');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(result, isNull);
    device.value = _state(location: PermissionStatus.granted);
    await _tap(tester, 'Review');
    await _tap(tester, 'Start with code boarding');
    expect(result, isTrue);
    expect(device.checks, 3); // Open twice, plus a fresh check on Start.
  });

  test(
    'native adapter checks without requesting or starting hardware; requests only foreground location',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final calls = <MethodCall>[];
      const permissions = MethodChannel(
        'flutter.baseflow.com/permissions/methods',
      );
      const location = MethodChannel('flutter.baseflow.com/geolocator');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(permissions, (call) async {
        calls.add(call);
        if (call.method == 'checkPermissionStatus') {
          return PermissionStatus.granted.index;
        }
        if (call.method == 'requestPermissions') {
          return {
            Permission.locationWhenInUse.value: PermissionStatus.granted.index,
          };
        }
        throw StateError('Unexpected permission method ${call.method}');
      });
      messenger.setMockMethodCallHandler(location, (call) async {
        calls.add(call);
        if (call.method == 'isLocationServiceEnabled') return true;
        throw StateError('Unexpected location method ${call.method}');
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(permissions, null);
        messenger.setMockMethodCallHandler(location, null);
      });
      const service = NativeDeviceReadinessService();
      expect((await service.check()).canStartTrip, isTrue);
      expect(calls.map((c) => c.method), [
        'checkPermissionStatus',
        'checkPermissionStatus',
        'isLocationServiceEnabled',
      ]);
      expect(calls.take(2).map((c) => c.arguments), [
        Permission.camera.value,
        Permission.locationWhenInUse.value,
      ]);
      await service.request(DevicePermission.location);
      expect(calls.last.arguments, [Permission.locationWhenInUse.value]);
    },
  );
}
