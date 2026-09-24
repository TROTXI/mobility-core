import 'dart:math';

/// A fresh `Idempotency-Key` for one write attempt.
///
/// The API scopes the key to caller + operation + target and answers 409 when
/// the same key arrives with a different payload, so a caller reuses one key
/// across retries of the *same* request and mints a new one whenever what it
/// is sending changes.
String newIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
