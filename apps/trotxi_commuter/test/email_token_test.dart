import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/email_auth_pages.dart';

void main() {
  final token = List.generate(43, (i) => 'abcXYZ_-019'[i % 11]).join();

  test('accepts the bare token or a pasted link/message', () {
    expect(extractEmailToken(token), token);
    expect(extractEmailToken('  $token\n'), token);
    expect(extractEmailToken('https://trotxi.app/reset#token=$token'), token);
    expect(extractEmailToken('Reset here: https://x.test/?t=$token. Thanks'), token);
  });

  test('rejects text without a 43-character token', () {
    expect(extractEmailToken(''), isNull);
    expect(extractEmailToken('short'), isNull);
    expect(extractEmailToken('${token}x'), isNull);
    expect(extractEmailToken('https://trotxi.app/reset'), isNull);
  });
}
