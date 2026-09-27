import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

import 'driver_photo_test.dart' as fixtures;

class _Auth implements DriverAuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Picker extends ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile.fromData(Uint8List.fromList([1, 2, 3]), path: 'driver.png');
}

void main() {
  testWidgets('a late account read cannot replace an uploaded photo', (
    tester,
  ) async {
    const location = MethodChannel('flutter.baseflow.com/geolocator');
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      location,
      (call) async => call.method == 'checkPermission' ? 2 : true,
    );
    addTearDown(() => messenger.setMockMethodCallHandler(location, null));

    final oldAccount = Completer<(int, Object?)>();
    final adapter = fixtures.Adapter((request) {
      if (request.path == '/v1/me') return oldAccount.future;
      return (
        200,
        {
          'data': {
            'url': 'https://example.test/new.png',
            'expiresAt': '2026-09-28T06:35:00Z',
          },
        },
      );
    });
    final published = <String?>[];
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DriverApi>.value(value: fixtures.withAdapter(adapter)),
          ChangeNotifierProvider(
            create: (_) => SessionController(auth: _Auth()),
          ),
          ChangeNotifierProvider(create: (_) => AppThemeController()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ProfilePage(
              imagePicker: _Picker(),
              onPhotoChanged: published.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(adapter.requests.single.path, '/v1/me');
    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from library'));
    await tester.pumpAndSettle();
    expect(published, ['https://example.test/new.png']);

    oldAccount.complete((
      200,
      fixtures.account(avatarUrl: 'https://example.test/old.png'),
    ));
    await tester.pumpAndSettle();
    expect(published, ['https://example.test/new.png']);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, 'https://example.test/new.png');
    expect(tester.takeException(), isNull);
  });
}
