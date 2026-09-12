import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for UsersApi
void main() {
  final instance = TrotxiApiClient().getUsersApi();

  group(UsersApi, () {
    // Delete my account (erases personal data; keeps financial records)
    //
    // Revokes every session, unregisters push devices, unlinks sign-in providers, deletes the avatar, and clears personal data. Payment and ride-ledger rows are retained in anonymised form because they are accounting records. Signing in again creates a new account.
    //
    //Future<String> meDelete() async
    test('test meDelete', () async {
      // TODO
    });

  });
}
