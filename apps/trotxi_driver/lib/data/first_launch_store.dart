import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists whether this installation has completed the driver introduction.
///
/// This is device state, not account state. A shared depot handset should not
/// replay the product tour every time one driver signs out and another signs
/// in, while a fresh installation should see it before credentials are asked
/// for.
abstract interface class FirstLaunchStore {
  Future<bool> hasCompleted();
  Future<void> complete();
}

class SecureFirstLaunchStore implements FirstLaunchStore {
  const SecureFirstLaunchStore({this.storage = const FlutterSecureStorage()});

  static const _key = 'driver_first_launch_completed_v1';
  final FlutterSecureStorage storage;

  @override
  Future<bool> hasCompleted() async => await storage.read(key: _key) == '1';

  @override
  Future<void> complete() => storage.write(key: _key, value: '1');
}
