import 'dart:async';

import 'package:test/test.dart';
import 'package:trotxi_client/optional_service.dart';

void main() {
  test('provider success allows startup', () async {
    expect(await initializeOptionalService(() async {}), isTrue);
  });

  test('sync and async provider failures do not block startup', () async {
    expect(await initializeOptionalService(() => throw StateError('private')),
        isFalse);
    expect(
        await initializeOptionalService(
            () async => throw StateError('private')),
        isFalse);
  });

  test('a stalled provider cannot block startup indefinitely', () async {
    final pending = Completer<void>();
    expect(
        await initializeOptionalService(() => pending.future,
            timeout: const Duration(milliseconds: 1)),
        isFalse);
    // A late provider failure is still handled, not sent to an error reporter.
    pending.completeError(StateError('private'));
    await Future<void>.delayed(Duration.zero);
  });
}
