// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_verify_pin_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingVerifyPinPost200ResponseReasonEnum
    _$boardingVerifyPinPost200ResponseReasonEnum_ok =
    const BoardingVerifyPinPost200ResponseReasonEnum._('ok');
const BoardingVerifyPinPost200ResponseReasonEnum
    _$boardingVerifyPinPost200ResponseReasonEnum_invalid =
    const BoardingVerifyPinPost200ResponseReasonEnum._('invalid');
const BoardingVerifyPinPost200ResponseReasonEnum
    _$boardingVerifyPinPost200ResponseReasonEnum_notFound =
    const BoardingVerifyPinPost200ResponseReasonEnum._('notFound');
const BoardingVerifyPinPost200ResponseReasonEnum
    _$boardingVerifyPinPost200ResponseReasonEnum_alreadyBoarded =
    const BoardingVerifyPinPost200ResponseReasonEnum._('alreadyBoarded');

BoardingVerifyPinPost200ResponseReasonEnum
    _$boardingVerifyPinPost200ResponseReasonEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$boardingVerifyPinPost200ResponseReasonEnum_ok;
    case 'invalid':
      return _$boardingVerifyPinPost200ResponseReasonEnum_invalid;
    case 'notFound':
      return _$boardingVerifyPinPost200ResponseReasonEnum_notFound;
    case 'alreadyBoarded':
      return _$boardingVerifyPinPost200ResponseReasonEnum_alreadyBoarded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingVerifyPinPost200ResponseReasonEnum>
    _$boardingVerifyPinPost200ResponseReasonEnumValues = BuiltSet<
        BoardingVerifyPinPost200ResponseReasonEnum>(const <BoardingVerifyPinPost200ResponseReasonEnum>[
  _$boardingVerifyPinPost200ResponseReasonEnum_ok,
  _$boardingVerifyPinPost200ResponseReasonEnum_invalid,
  _$boardingVerifyPinPost200ResponseReasonEnum_notFound,
  _$boardingVerifyPinPost200ResponseReasonEnum_alreadyBoarded,
]);

Serializer<BoardingVerifyPinPost200ResponseReasonEnum>
    _$boardingVerifyPinPost200ResponseReasonEnumSerializer =
    _$BoardingVerifyPinPost200ResponseReasonEnumSerializer();

class _$BoardingVerifyPinPost200ResponseReasonEnumSerializer
    implements PrimitiveSerializer<BoardingVerifyPinPost200ResponseReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'invalid': 'invalid',
    'notFound': 'not_found',
    'alreadyBoarded': 'already_boarded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'invalid': 'invalid',
    'not_found': 'notFound',
    'already_boarded': 'alreadyBoarded',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingVerifyPinPost200ResponseReasonEnum
  ];
  @override
  final String wireName = 'BoardingVerifyPinPost200ResponseReasonEnum';

  @override
  Object serialize(Serializers serializers,
          BoardingVerifyPinPost200ResponseReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingVerifyPinPost200ResponseReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingVerifyPinPost200ResponseReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingVerifyPinPost200Response
    extends BoardingVerifyPinPost200Response {
  @override
  final bool valid;
  @override
  final String? riderId;
  @override
  final BoardingVerifyPinPost200ResponseReasonEnum reason;
  @override
  final bool deducted;

  factory _$BoardingVerifyPinPost200Response(
          [void Function(BoardingVerifyPinPost200ResponseBuilder)? updates]) =>
      (BoardingVerifyPinPost200ResponseBuilder()..update(updates))._build();

  _$BoardingVerifyPinPost200Response._(
      {required this.valid,
      this.riderId,
      required this.reason,
      required this.deducted})
      : super._();
  @override
  BoardingVerifyPinPost200Response rebuild(
          void Function(BoardingVerifyPinPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingVerifyPinPost200ResponseBuilder toBuilder() =>
      BoardingVerifyPinPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingVerifyPinPost200Response &&
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
    return (newBuiltValueToStringHelper(r'BoardingVerifyPinPost200Response')
          ..add('valid', valid)
          ..add('riderId', riderId)
          ..add('reason', reason)
          ..add('deducted', deducted))
        .toString();
  }
}

class BoardingVerifyPinPost200ResponseBuilder
    implements
        Builder<BoardingVerifyPinPost200Response,
            BoardingVerifyPinPost200ResponseBuilder> {
  _$BoardingVerifyPinPost200Response? _$v;

  bool? _valid;
  bool? get valid => _$this._valid;
  set valid(bool? valid) => _$this._valid = valid;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  BoardingVerifyPinPost200ResponseReasonEnum? _reason;
  BoardingVerifyPinPost200ResponseReasonEnum? get reason => _$this._reason;
  set reason(BoardingVerifyPinPost200ResponseReasonEnum? reason) =>
      _$this._reason = reason;

  bool? _deducted;
  bool? get deducted => _$this._deducted;
  set deducted(bool? deducted) => _$this._deducted = deducted;

  BoardingVerifyPinPost200ResponseBuilder() {
    BoardingVerifyPinPost200Response._defaults(this);
  }

  BoardingVerifyPinPost200ResponseBuilder get _$this {
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
  void replace(BoardingVerifyPinPost200Response other) {
    _$v = other as _$BoardingVerifyPinPost200Response;
  }

  @override
  void update(void Function(BoardingVerifyPinPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingVerifyPinPost200Response build() => _build();

  _$BoardingVerifyPinPost200Response _build() {
    final _$result = _$v ??
        _$BoardingVerifyPinPost200Response._(
          valid: BuiltValueNullFieldError.checkNotNull(
              valid, r'BoardingVerifyPinPost200Response', 'valid'),
          riderId: riderId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'BoardingVerifyPinPost200Response', 'reason'),
          deducted: BuiltValueNullFieldError.checkNotNull(
              deducted, r'BoardingVerifyPinPost200Response', 'deducted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
