import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for SelfApi
void main() {
  final instance = TrotxiApiClient().getSelfApi();

  group(SelfApi, () {
    // erase Account
    //
    //Future eraseAccount(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test eraseAccount', () async {
      // TODO
    });

    // get Account
    //
    //Future<AccountResponse> getAccount(String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getAccount', () async {
      // TODO
    });

    // get Avatar
    //
    //Future<AvatarResponse> getAvatar(String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getAvatar', () async {
      // TODO
    });

    // list Sessions
    //
    //Future<SessionPage> listSessions(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listSessions', () async {
      // TODO
    });

    // register Device
    //
    //Future<DeviceResponse> registerDevice(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, DeviceInput deviceInput, { String xTrotxiPlatform }) async
    test('test registerDevice', () async {
      // TODO
    });

    // revoke Session
    //
    //Future revokeSession(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test revokeSession', () async {
      // TODO
    });

    // update Account
    //
    //Future<AccountResponse> updateAccount(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ProfileUpdate profileUpdate, { String xTrotxiPlatform }) async
    test('test updateAccount', () async {
      // TODO
    });

    // upload Avatar
    //
    //Future<AvatarResponse> uploadAvatar(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, MultipartFile file, { String xTrotxiPlatform }) async
    test('test uploadAvatar', () async {
      // TODO
    });

  });
}
