/// Push is optional. A provider failure must not prevent sign-in or trip access.
/// Never log the provider exception: it can contain device tokens or URLs.
Future<bool> initializeOptionalService(
  Future<void> Function() initialize, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    await initialize().timeout(timeout);
    return true;
  } catch (_) {
    return false;
  }
}
