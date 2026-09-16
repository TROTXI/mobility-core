import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';

class MemorySessionStorage implements SessionStorage {
  final values = <String, String>{};
  final reads = <String>[];
  final writes = <String>[];
  final deletes = <String>[];
  bool failWrite = false;
  bool failDelete = false;
  Completer<void>? writeGate;
  Completer<void>? writeEntered;

  @override
  Future<String?> read(String key) async {
    reads.add(key);
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    writes.add(key);
    if (writeEntered?.isCompleted == false) writeEntered!.complete();
    await writeGate?.future;
    if (failWrite) throw StateError('OS write refused');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    deletes.add(key);
    if (failDelete) throw StateError('OS delete refused');
    values.remove(key);
  }
}

SessionScope scope({
  String app = 'driver',
  String realm = 'local-fixture-1',
  String url = 'http://localhost:3000',
}) =>
    SessionScope(baseUrl: url, app: app, realm: realm);

void main() {
  late MemorySessionStorage storage;
  late ScopedTokenStore store;
  setUp(() {
    storage = MemorySessionStorage();
    store = ScopedTokenStore(scope: scope(), storage: storage);
  });

  test(
      'scope separates app, backend and database incarnation, not URL spelling',
      () {
    final keys = [
      scope(),
      scope(app: 'commuter'),
      scope(realm: 'local-fixture-2'),
      scope(url: 'https://staging.example.test'),
      scope(url: 'http://localhost:3000/another-api'),
    ].map((s) => s.storageKey).toSet();
    expect(keys, hasLength(5));
    expect(scope().storageKey, startsWith('trotxi.replacement-v1.session.'));
    expect(scope().storageKey, scope(url: 'http://LOCALHOST:3000/').storageKey);
    expect(scope(url: 'https://a.test').storageKey,
        scope(url: 'https://a.test:443/').storageKey);
  });

  test('ambiguous endpoints and unspecified realms fail before reading storage',
      () {
    for (final url in [
      '',
      '/api',
      'ftp://a.test',
      'https://x:y@a.test',
      'https://a.test?environment=test',
      'https://a.test#fragment'
    ]) {
      expect(() => scope(url: url), throwsArgumentError);
    }
    expect(() => scope(realm: ''), throwsArgumentError);
    expect(() => scope(app: 'ops'), throwsArgumentError);
  });

  test('never reads or imports the old unscoped token pair', () async {
    storage.values
        .addAll({'access_token': 'legacy-a', 'refresh_token': 'legacy-r'});
    expect(await store.getAccessToken(), isNull);
    expect(await store.getRefreshToken(), isNull);
    expect(storage.reads, everyElement(store.scope.storageKey));
    await store.clearTokens();
    expect(storage.values,
        {'access_token': 'legacy-a', 'refresh_token': 'legacy-r'});
  });

  test(
      'one secure write stores the complete pair and survives a new store instance',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    expect(storage.writes, [store.scope.storageKey]);
    expect(jsonDecode(storage.values[store.scope.storageKey]!), {
      'format': 1,
      'accessToken': 'a',
      'refreshToken': 'r',
    });
    final reopened = ScopedTokenStore(scope: scope(), storage: storage);
    expect(await reopened.getAccessToken(), 'a');
    expect(await reopened.getRefreshToken(), 'r');
    expect(
        await ScopedTokenStore(scope: scope(realm: 'other'), storage: storage)
            .getAccessToken(),
        isNull);
  });

  test('failed write leaves the old pair intact and does not poison the queue',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    storage.failWrite = true;
    await expectLater(
        store.saveTokens(accessToken: 'new-a', refreshToken: 'new-r'),
        throwsStateError);
    expect(await store.getAccessToken(), 'a');
    expect(await store.getRefreshToken(), 'r');
    storage.failWrite = false;
    await store.saveTokens(accessToken: 'last-a', refreshToken: 'last-r');
    expect(await store.getAccessToken(), 'last-a');
  });

  test('refresh compare-and-write cannot overwrite or clear the next login',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    // Queue the new identity immediately before the old refresh completes.
    final login =
        store.saveTokens(accessToken: 'other-a', refreshToken: 'other-r');
    final rotation = store.saveTokensIfRefreshMatches(
        expectedRefreshToken: 'r',
        accessToken: 'rotated-a',
        refreshToken: 'rotated-r');
    final clear = store.clearTokensIfRefreshMatches('r');
    await login;
    expect(await rotation, isFalse);
    expect(await clear, isFalse);
    expect(await store.getAccessToken(), 'other-a');
    expect(await store.getRefreshToken(), 'other-r');
    expect(storage.deletes, isEmpty);
  });

  test(
      'rotation preserves identity generation; explicit replacement and clearing change it',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    final generation = store.generation;
    expect(
        await store.saveTokensIfRefreshMatches(
            expectedRefreshToken: 'r', accessToken: 'b', refreshToken: 's'),
        isTrue);
    expect(store.generation, generation);
    expect(await store.clearTokensIfRefreshMatches('s'), isTrue);
    expect(store.generation, generation + 1);
    expect(
        await store.saveTokensIfGenerationMatches(
            expectedGeneration: generation,
            accessToken: 'late-a',
            refreshToken: 'late-r'),
        isFalse);
    expect(await store.getAccessToken(), isNull);
  });

  test('logout takes one pair, clears only its scope, callback sees deletion',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    final other =
        ScopedTokenStore(scope: scope(app: 'commuter'), storage: storage);
    await other.saveTokens(accessToken: 'c', refreshToken: 'd');
    var notified = false;
    store.onCleared = () {
      notified = true;
      expect(storage.values.containsKey(store.scope.storageKey), isFalse);
    };
    final taken = await store.takeSession();
    expect(taken?.accessToken, 'a');
    expect(taken?.refreshToken, 'r');
    expect(notified, isTrue);
    expect(await other.getAccessToken(), 'c');
  });

  test('pending storage writes cannot outlive an already queued logout',
      () async {
    storage.writeGate = Completer<void>();
    final writing = store.saveTokens(accessToken: 'a', refreshToken: 'r');
    final clearing = store.clearTokens();
    storage.writeGate!.complete();
    await writing;
    await clearing;
    expect(await store.getAccessToken(), isNull);
    expect(storage.writes, hasLength(1));
    expect(storage.deletes, hasLength(1));
  });

  test('delete failure is reported, not falsely announced as signed out',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    var notified = false;
    store.onCleared = () => notified = true;
    storage.failDelete = true;
    await expectLater(store.clearTokens(), throwsStateError);
    expect(notified, isFalse);
    expect(await store.getAccessToken(), 'a');
    storage.failDelete = false;
    await store.clearTokens();
    expect(notified, isTrue);
  });

  test(
      'partial or corrupt records fail closed without leaking contents or falling back',
      () async {
    for (final raw in [
      'SECRET-malformed',
      '{"format":1,"accessToken":"SECRET"}',
      '{"format":2,"accessToken":"SECRET","refreshToken":"r"}',
      '{"format":1,"accessToken":"","refreshToken":"r"}'
    ]) {
      storage.values[store.scope.storageKey] = raw;
      await expectLater(
          store.getAccessToken(),
          throwsA(isA<FormatException>().having((e) => e.toString(),
              'sanitized message', isNot(contains('SECRET')))));
    }
    await store.clearTokens();
    expect(await store.getAccessToken(), isNull);
  });

  test('late erasure acknowledgement cannot clear a queued replacement login',
      () async {
    await store.saveTokens(accessToken: 'old', refreshToken: 'old-r');
    final generation = store.generation;
    storage.writeGate = Completer<void>();
    storage.writeEntered = Completer<void>();
    final login = store.saveTokens(accessToken: 'new', refreshToken: 'new-r');
    await storage.writeEntered!.future;
    final clear = store.clearTokensIfGenerationMatches(generation);
    storage.writeGate!.complete();
    await login;
    expect(await clear, isFalse);
    expect(await store.getAccessToken(), 'new');
    expect(storage.deletes, isEmpty);
  });

  test(
      'conditional clear reports OS failure without changing generation or notifying',
      () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    final generation = store.generation;
    var notified = 0;
    store.onCleared = () => notified++;
    storage.failDelete = true;
    await expectLater(
        store.clearTokensIfGenerationMatches(generation), throwsStateError);
    expect(store.generation, generation);
    expect(notified, 0);
    expect(await store.getAccessToken(), 'a');
    storage.failDelete = false;
    expect(await store.clearTokensIfGenerationMatches(generation), isTrue);
    expect(notified, 1);
    expect(await store.getAccessToken(), isNull);
  });

  test('empty token cannot replace a valid pair', () async {
    await store.saveTokens(accessToken: 'a', refreshToken: 'r');
    await expectLater(store.saveTokens(accessToken: '', refreshToken: 'r2'),
        throwsArgumentError);
    expect(await store.getAccessToken(), 'a');
  });
}
