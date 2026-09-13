import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum DevicePermission { camera, location }

class DeviceReadiness {
  const DeviceReadiness({
    required this.camera,
    required this.location,
    required this.locationServices,
  });

  final PermissionStatus camera;
  final PermissionStatus location;
  final bool locationServices;

  // Permissions are not proof of a camera, GPS fix, or network connectivity.
  bool get canStartTrip => location.isGranted && locationServices;
}

/// Local permission checks only: no API calls, camera session or GPS stream.
/// Separate from position publishing so a pre-trip check never starts tracking.
abstract interface class DeviceReadinessService {
  Future<DeviceReadiness> check();
  Future<void> request(DevicePermission permission);
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class NativeDeviceReadinessService implements DeviceReadinessService {
  const NativeDeviceReadinessService();

  @override
  Future<DeviceReadiness> check() async => DeviceReadiness(
    camera: await Permission.camera.status,
    location: await Permission.locationWhenInUse.status,
    locationServices: await Geolocator.isLocationServiceEnabled(),
  );

  @override
  Future<void> request(DevicePermission permission) async {
    await switch (permission) {
      DevicePermission.camera => Permission.camera.request(),
      DevicePermission.location => Permission.locationWhenInUse.request(),
    };
  }

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
