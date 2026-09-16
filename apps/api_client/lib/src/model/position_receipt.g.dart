// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_receipt.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PositionReceipt extends PositionReceipt {
  @override
  final String clientFixId;
  @override
  final DateTime receivedAt;
  @override
  final DateTime capturedAt;
  @override
  final DateTime effectiveCapturedAt;
  @override
  final bool acceptedForLive;
  @override
  final bool clockAdjusted;

  factory _$PositionReceipt([void Function(PositionReceiptBuilder)? updates]) =>
      (PositionReceiptBuilder()..update(updates))._build();

  _$PositionReceipt._(
      {required this.clientFixId,
      required this.receivedAt,
      required this.capturedAt,
      required this.effectiveCapturedAt,
      required this.acceptedForLive,
      required this.clockAdjusted})
      : super._();
  @override
  PositionReceipt rebuild(void Function(PositionReceiptBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PositionReceiptBuilder toBuilder() => PositionReceiptBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PositionReceipt &&
        clientFixId == other.clientFixId &&
        receivedAt == other.receivedAt &&
        capturedAt == other.capturedAt &&
        effectiveCapturedAt == other.effectiveCapturedAt &&
        acceptedForLive == other.acceptedForLive &&
        clockAdjusted == other.clockAdjusted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientFixId.hashCode);
    _$hash = $jc(_$hash, receivedAt.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, effectiveCapturedAt.hashCode);
    _$hash = $jc(_$hash, acceptedForLive.hashCode);
    _$hash = $jc(_$hash, clockAdjusted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PositionReceipt')
          ..add('clientFixId', clientFixId)
          ..add('receivedAt', receivedAt)
          ..add('capturedAt', capturedAt)
          ..add('effectiveCapturedAt', effectiveCapturedAt)
          ..add('acceptedForLive', acceptedForLive)
          ..add('clockAdjusted', clockAdjusted))
        .toString();
  }
}

class PositionReceiptBuilder
    implements Builder<PositionReceipt, PositionReceiptBuilder> {
  _$PositionReceipt? _$v;

  String? _clientFixId;
  String? get clientFixId => _$this._clientFixId;
  set clientFixId(String? clientFixId) => _$this._clientFixId = clientFixId;

  DateTime? _receivedAt;
  DateTime? get receivedAt => _$this._receivedAt;
  set receivedAt(DateTime? receivedAt) => _$this._receivedAt = receivedAt;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  DateTime? _effectiveCapturedAt;
  DateTime? get effectiveCapturedAt => _$this._effectiveCapturedAt;
  set effectiveCapturedAt(DateTime? effectiveCapturedAt) =>
      _$this._effectiveCapturedAt = effectiveCapturedAt;

  bool? _acceptedForLive;
  bool? get acceptedForLive => _$this._acceptedForLive;
  set acceptedForLive(bool? acceptedForLive) =>
      _$this._acceptedForLive = acceptedForLive;

  bool? _clockAdjusted;
  bool? get clockAdjusted => _$this._clockAdjusted;
  set clockAdjusted(bool? clockAdjusted) =>
      _$this._clockAdjusted = clockAdjusted;

  PositionReceiptBuilder() {
    PositionReceipt._defaults(this);
  }

  PositionReceiptBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientFixId = $v.clientFixId;
      _receivedAt = $v.receivedAt;
      _capturedAt = $v.capturedAt;
      _effectiveCapturedAt = $v.effectiveCapturedAt;
      _acceptedForLive = $v.acceptedForLive;
      _clockAdjusted = $v.clockAdjusted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PositionReceipt other) {
    _$v = other as _$PositionReceipt;
  }

  @override
  void update(void Function(PositionReceiptBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PositionReceipt build() => _build();

  _$PositionReceipt _build() {
    final _$result = _$v ??
        _$PositionReceipt._(
          clientFixId: BuiltValueNullFieldError.checkNotNull(
              clientFixId, r'PositionReceipt', 'clientFixId'),
          receivedAt: BuiltValueNullFieldError.checkNotNull(
              receivedAt, r'PositionReceipt', 'receivedAt'),
          capturedAt: BuiltValueNullFieldError.checkNotNull(
              capturedAt, r'PositionReceipt', 'capturedAt'),
          effectiveCapturedAt: BuiltValueNullFieldError.checkNotNull(
              effectiveCapturedAt, r'PositionReceipt', 'effectiveCapturedAt'),
          acceptedForLive: BuiltValueNullFieldError.checkNotNull(
              acceptedForLive, r'PositionReceipt', 'acceptedForLive'),
          clockAdjusted: BuiltValueNullFieldError.checkNotNull(
              clockAdjusted, r'PositionReceipt', 'clockAdjusted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
