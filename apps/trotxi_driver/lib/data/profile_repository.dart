import 'dart:typed_data';

import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';

/// The driver's own account, and the one picture attached to it.
///
/// The photo is read from the account rather than `GET /v1/me/avatar`, which
/// answers 404 when there is none. An account read says "no photo" with a null
/// field instead, and the profile needs the account anyway.
class DriverProfileRepository {
  DriverProfileRepository(this.api);
  final DriverApi api;

  /// Accepted by the server, which reads the file's own header and refuses a
  /// declaration that disagrees with it.
  static const accepted = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  Future<wire.Account> account() async => (await api.get(
    '/v1/me',
    wire.AccountResponse.serializer,
  )).data;

  /// Replace the photo and return the new signed URL.
  ///
  /// The URL expires, so hold it for the screen that drew it and read the
  /// account again rather than caching it across a session.
  Future<String> uploadPhoto(
    Uint8List bytes, {
    required String contentType,
    required String filename,
  }) async {
    final avatar = await api.upload(
      '/v1/me/avatar',
      wire.AvatarResponse.serializer,
      bytes: bytes,
      contentType: contentType,
      filename: filename,
    );
    return avatar.data.url;
  }
}
