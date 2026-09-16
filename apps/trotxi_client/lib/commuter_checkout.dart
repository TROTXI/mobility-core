import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'commuter_data_client.dart';
import 'scoped_token_store.dart';
import 'trotxi_client.dart';

bool purchaseUnresolved(Purchase p) => const {
      PurchaseStateEnum.awaitingPayment,
      PurchaseStateEnum.processing,
      PurchaseStateEnum.reviewRequired,
    }.contains(p.state);

/// Only the server's payable state can offer checkout. Opening/returning from
/// a browser never grants rides. Test/live mode is controlled by the backend
/// key, NOT this shared Paystack hostname; no secret belongs in the app.
Uri? paystackCheckoutUri(Purchase p, DateTime now) {
  if (p.state != PurchaseStateEnum.awaitingPayment ||
      !const {
        PurchaseCollectionStateEnum.pending,
        PurchaseCollectionStateEnum.unknown
      }.contains(p.collectionState) ||
      p.checkout == null ||
      (p.checkout!.expiresAt != null && !p.checkout!.expiresAt!.isAfter(now)))
    return null;
  final uri = Uri.tryParse(p.checkout!.url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'checkout.paystack.com' ||
      uri.userInfo.isNotEmpty ||
      uri.port != 443 ||
      uri.hasFragment ||
      uri.path.length < 2) return null;
  return uri;
}

class PurchaseIntent {
  const PurchaseIntent(this.key, this.input, this.purchaseId);
  final String key;
  final PurchaseInput input;
  final String? purchaseId;
}

/// One instance per checkout screen; persistence contains only a retry intent,
/// never provider URLs, card details or payment-success flags. Secure storage is
/// scoped to backend incarnation, application AND authenticated account. Every
/// action checks the original session after awaits. Recovery never posts by itself.
class CommuterCheckout {
  CommuterCheckout._(this.data, this.storage, this.generation, this.storageKey);
  static Future<CommuterCheckout> open(CommuterDataClient data) async {
    final generation = data.sessionGeneration;
    final account = await data.account();
    data.ensureSession(generation);
    final key = _key(data, account.id);
    return CommuterCheckout._(data, data.store.storage, generation, key);
  }

  final CommuterDataClient data;
  final SessionStorage storage;
  final int generation;
  final String storageKey;
  PurchaseIntent? intent;
  List<Purchase> purchases = const [];
  bool _disposed = false;
  static final _queues = Expando<Map<String, Future<void>>>();
  static String _key(CommuterDataClient data, String accountId) =>
      '${data.store.scope.storageKey}.purchase.${sha256.convert(utf8.encode(accountId))}';

  /// After server-acknowledged erasure, drain old writes before deleting ONLY
  /// that account's journal. Logout alone intentionally keeps recovery data.
  static Future<void> clearErasedAccount(
      CommuterDataClient data, String accountId) {
    final storage = data.store.storage, key = _key(data, accountId);
    final queues = _queues[storage] ??= {};
    final result =
        (queues[key] ?? Future<void>.value()).then((_) => storage.delete(key));
    queues[key] =
        result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  void dispose() {
    _disposed = true;
  }

  void _check() {
    data.ensureSession(generation);
    if (_disposed) throw const UnauthorizedException();
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    // Two screens/controllers for the same rider must not overwrite each
    // other's durable intent before either network request reaches the server.
    final queues = _queues[storage] ??= {};
    final result = (queues[storageKey] ?? Future<void>.value()).then((_) {
      _check();
      return action();
    });
    queues[storageKey] =
        result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> _load() async {
    final raw = await storage.read(storageKey);
    _check();
    if (raw == null) {
      intent = null;
      return;
    }
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic> ||
          value['format'] != 1 ||
          value['key'] is! String ||
          !RegExp(r'^[0-9a-f-]{36}$').hasMatch(value['key'] as String) ||
          (value['purchaseId'] != null && value['purchaseId'] is! String))
        throw const FormatException();
      final input = data.client.serializers
          .deserializeWith(PurchaseInput.serializer, value['input']);
      if (input == null) throw const FormatException();
      intent = PurchaseIntent(
          value['key'] as String, input, value['purchaseId'] as String?);
    } catch (_) {
      // Do not overwrite a possibly committed intent because local data broke.
      throw const ApiException(0,
          'Checkout recovery data could not be read. Contact operations before starting another purchase.');
    }
  }

  Future<void> _save(PurchaseIntent value) async {
    _check();
    await storage.write(
        storageKey,
        jsonEncode({
          'format': 1,
          'key': value.key,
          'purchaseId': value.purchaseId,
          'input': data.client.serializers
              .serializeWith(PurchaseInput.serializer, value.input),
        }));
    _check();
    intent = value;
  }

  Future<void> _clear() async {
    _check();
    await storage.delete(storageKey);
    _check();
    intent = null;
  }

  Future<void> _recover() async {
    await _load();
    final rows = await data.purchases(); // No recency cutoff or status guesses.
    _check();
    final id = intent?.purchaseId;
    // The detail read remains authoritative even if a future list is filtered.
    final known = id == null ? null : await data.purchase(id);
    _check();
    purchases = List.unmodifiable([
      if (known != null) known,
      ...rows.where((p) => p.id != id),
    ]);
    if (known != null && !purchaseUnresolved(known)) await _clear();
  }

  Future<void> recover() => _exclusive(_recover);
  Future<Purchase> start(PurchaseInput input) => _exclusive(() async {
        await _recover();
        if (intent != null || purchases.any(purchaseUnresolved)) {
          throw const ApiException(
              409, 'Resolve your existing checkout before starting another.',
              code: 'purchase_unresolved');
        }
        await _save(PurchaseIntent(const Uuid().v4(), input, null));
        return _send();
      });
  Future<Purchase> retry() => _exclusive(() async {
        await _load();
        if (intent == null)
          throw const ApiException(
              409, 'No saved checkout to retry. Refresh purchases.');
        // The server enforces key expiry and input identity. Never replace an
        // expired key automatically: an old provider transaction may still settle.
        return _send();
      });
  Future<Purchase> _send() async {
    final saved = intent!;
    final Purchase result;
    try {
      result = await data.createPurchase(saved.input, key: saved.key);
    } on ApiException catch (e) {
      _check();
      // A validation rejection cannot have committed this command. Uncertain
      // delivery, 409, 429 and provider failure retain the exact original intent.
      if (e.statusCode == 400 || e.statusCode == 422) await _clear();
      rethrow;
    }
    _check();
    if (saved.purchaseId != null && saved.purchaseId != result.id) {
      throw const ApiException(502,
          'Checkout replay returned a different purchase. Contact operations.');
    }
    await _save(PurchaseIntent(saved.key, saved.input, result.id));
    purchases = List.unmodifiable(
        [result, ...purchases.where((p) => p.id != result.id)]);
    if (!purchaseUnresolved(result)) await _clear();
    return result;
  }
}
