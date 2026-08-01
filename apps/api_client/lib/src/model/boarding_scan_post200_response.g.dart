// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_scan_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingScanPost200ResponseReasonEnum
    _$boardingScanPost200ResponseReasonEnum_ok =
    const BoardingScanPost200ResponseReasonEnum._('ok');
const BoardingScanPost200ResponseReasonEnum
    _$boardingScanPost200ResponseReasonEnum_invalid =
    const BoardingScanPost200ResponseReasonEnum._('invalid');
const BoardingScanPost200ResponseReasonEnum
    _$boardingScanPost200ResponseReasonEnum_expired =
    const BoardingScanPost200ResponseReasonEnum._('expired');
const BoardingScanPost200ResponseReasonEnum
    _$boardingScanPost200ResponseReasonEnum_reused =
    const BoardingScanPost200ResponseReasonEnum._('reused');

BoardingScanPost200ResponseReasonEnum
    _$boardingScanPost200ResponseReasonEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$boardingScanPost200ResponseReasonEnum_ok;
    case 'invalid':
      return _$boardingScanPost200ResponseReasonEnum_invalid;
    case 'expired':
      return _$boardingScanPost200ResponseReasonEnum_expired;
    case 'reused':
      return _$boardingScanPost200ResponseReasonEnum_reused;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingScanPost200ResponseReasonEnum>
    _$boardingScanPost200ResponseReasonEnumValues = BuiltSet<
        BoardingScanPost200ResponseReasonEnum>(const <BoardingScanPost200ResponseReasonEnum>[
  _$boardingScanPost200ResponseReasonEnum_ok,
  _$boardingScanPost200ResponseReasonEnum_invalid,
  _$boardingScanPost200ResponseReasonEnum_expired,
  _$boardingScanPost200ResponseReasonEnum_reused,
]);

Serializer<BoardingScanPost200ResponseReasonEnum>
    _$boardingScanPost200ResponseReasonEnumSerializer =
    _$BoardingScanPost200ResponseReasonEnumSerializer();

class _$BoardingScanPost200ResponseReasonEnumSerializer
    implements PrimitiveSerializer<BoardingScanPost200ResponseReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'invalid': 'invalid',
    'expired': 'expired',
    'reused': 'reused',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'invalid': 'invalid',
    'expired': 'expired',
    'reused': 'reused',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingScanPost200ResponseReasonEnum
  ];
  @override
  final String wireName = 'BoardingScanPost200ResponseReasonEnum';

  @override
  Object serialize(
          Serializers serializers, BoardingScanPost200ResponseReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingScanPost200ResponseReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingScanPost200ResponseReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingScanPost200Response extends BoardingScanPost200Response {
  @override
  final bool valid;
  @override
  final String? riderId;
  @override
  final BoardingScanPost200ResponseReasonEnum reason;
  @override
  final bool deducted;

  factory _$BoardingScanPost200Response(
          [void Function(BoardingScanPost200ResponseBuilder)? updates]) =>
      (BoardingScanPost200ResponseBuilder()..update(updates))._build();

  _$BoardingScanPost200Response._(
      {required this.valid,
      this.riderId,
      required this.reason,
      required this.deducted})
      : super._();
  @override
  BoardingScanPost200Response rebuild(
          void Function(BoardingScanPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingScanPost200ResponseBuilder toBuilder() =>
      BoardingScanPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingScanPost200Response &&
        valid == other.valid &&
        riderId == other.riderId &&
        reason == other.reason &&
        deducted == other.deducted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, valid.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, deducted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingScanPost200Response')
          ..add('valid', valid)
          ..add('riderId', riderId)
          ..add('reason', reason)
          ..add('deducted', deducted))
        .toString();
  }
}

class BoardingScanPost200ResponseBuilder
    implements
        Builder<BoardingScanPost200Response,
            BoardingScanPost200ResponseBuilder> {
  _$BoardingScanPost200Response? _$v;

  bool? _valid;
  bool? get valid => _$this._valid;
  set valid(bool? valid) => _$this._valid = valid;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  BoardingScanPost200ResponseReasonEnum? _reason;
  BoardingScanPost200ResponseReasonEnum? get reason => _$this._reason;
  set reason(BoardingScanPost200ResponseReasonEnum? reason) =>
      _$this._reason = reason;

  bool? _deducted;
  bool? get deducted => _$this._deducted;
  set deducted(bool? deducted) => _$this._deducted = deducted;

  BoardingScanPost200ResponseBuilder() {
    BoardingScanPost200Response._defaults(this);
  }

  BoardingScanPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _valid = $v.valid;
      _riderId = $v.riderId;
      _reason = $v.reason;
      _deducted = $v.deducted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingScanPost200Response other) {
    _$v = other as _$BoardingScanPost200Response;
  }

  @override
  void update(void Function(BoardingScanPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingScanPost200Response build() => _build();

  _$BoardingScanPost200Response _build() {
    final _$result = _$v ??
        _$BoardingScanPost200Response._(
          valid: BuiltValueNullFieldError.checkNotNull(
              valid, r'BoardingScanPost200Response', 'valid'),
          riderId: riderId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'BoardingScanPost200Response', 'reason'),
          deducted: BuiltValueNullFieldError.checkNotNull(
              deducted, r'BoardingScanPost200Response', 'deducted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
