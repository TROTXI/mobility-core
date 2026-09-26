import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';

void main() {
  test(
    'Android active tracking uses a visible location foreground service',
    () {
      final settings =
          PositionPublisher.trackingSettings(TargetPlatform.android)
              as AndroidSettings;
      expect(settings.intervalDuration, const Duration(seconds: 5));
      expect(settings.foregroundNotificationConfig?.enableWakeLock, isTrue);
      expect(settings.foregroundNotificationConfig?.setOngoing, isTrue);
      expect(
        settings.foregroundNotificationConfig?.color,
        AppPrimitiveColors.action,
      );
      expect(
        settings.foregroundNotificationConfig?.notificationText,
        isNot(contains('trip-')),
      );
      expect(
        settings.foregroundNotificationConfig?.notificationTitle,
        contains('Trotxi'),
      );
    },
  );
  test('iOS active tracking enables background updates and indicator', () {
    final settings =
        PositionPublisher.trackingSettings(TargetPlatform.iOS) as AppleSettings;
    expect(settings.allowBackgroundLocationUpdates, isTrue);
    expect(settings.showBackgroundLocationIndicator, isTrue);
    expect(settings.pauseLocationUpdatesAutomatically, isFalse);
  });
}
