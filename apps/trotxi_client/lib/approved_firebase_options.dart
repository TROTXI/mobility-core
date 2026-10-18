/// Reviewed public Firebase client identities, not server credentials.
/// Keep these independent of build-time overrides so typos and cross-app
/// configuration swaps fail before optional Firebase initialization.
class MobileFirebaseAppPolicy {
  const MobileFirebaseAppPolicy(
      {required this.iosBundleId,
      required this.iosAppId,
      required this.iosApiKey});
  final String iosBundleId;
  final String iosAppId;
  final String iosApiKey;
}

const stagingFirebaseApps = <String, MobileFirebaseAppPolicy>{
  'trotxi_commuter': MobileFirebaseAppPolicy(
    iosBundleId: 'com.trotxi.trotxiCommuter',
    iosAppId: '1:431341307838:ios:4d867ba4b6f60dd1ff1bef',
    iosApiKey: 'AIzaSyA4tqnxHVIbYDj_aqB4toHgmpSK23mbbY8',
  ),
  'trotxi_driver': MobileFirebaseAppPolicy(
    iosBundleId: 'com.trotxi.trotxiDriver',
    iosAppId: '1:431341307838:ios:2bd968c3c2c9d369ff1bef',
    iosApiKey: 'AIzaSyA4tqnxHVIbYDj_aqB4toHgmpSK23mbbY8',
  ),
};
