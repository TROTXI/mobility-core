// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_verify_code_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_ok =
    const BoardingVerifyCodePost200ResponseReasonEnum._('ok');
const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_invalid =
    const BoardingVerifyCodePost200ResponseReasonEnum._('invalid');
const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_alreadyBoarded =
    const BoardingVerifyCodePost200ResponseReasonEnum._('alreadyBoarded');
const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_ambiguous =
    const BoardingVerifyCodePost200ResponseReasonEnum._('ambiguous');
const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_forbidden =
    const BoardingVerifyCodePost200ResponseReasonEnum._('forbidden');
const BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnum_notFound =
    const BoardingVerifyCodePost200ResponseReasonEnum._('notFound');

BoardingVerifyCodePost200ResponseReasonEnum
    _$boardingVerifyCodePost200ResponseReasonEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$boardingVerifyCodePost200ResponseReasonEnum_ok;
    case 'invalid':
      return _$boardingVerifyCodePost200ResponseReasonEnum_invalid;
    case 'alreadyBoarded':
      return _$boardingVerifyCodePost200ResponseReasonEnum_alreadyBoarded;
    case 'ambiguous':
      return _$boardingVerifyCodePost200ResponseReasonEnum_ambiguous;
    case 'forbidden':
      return _$boardingVerifyCodePost200ResponseReasonEnum_forbidden;
    case 'notFound':
      return _$boardingVerifyCodePost200ResponseReasonEnum_notFound;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingVerifyCodePost200ResponseReasonEnum>
    _$boardingVerifyCodePost200ResponseReasonEnumValues = BuiltSet<
        BoardingVerifyCodePost200ResponseReasonEnum>(const <BoardingVerifyCodePost200ResponseReasonEnum>[
  _$boardingVerifyCodePost200ResponseReasonEnum_ok,
  _$boardingVerifyCodePost200ResponseReasonEnum_invalid,
  _$boardingVerifyCodePost200ResponseReasonEnum_alreadyBoarded,
  _$boardingVerifyCodePost200ResponseReasonEnum_ambiguous,
  _$boardingVerifyCodePost200ResponseReasonEnum_forbidden,
  _$boardingVerifyCodePost200ResponseReasonEnum_notFound,
]);

Serializer<BoardingVerifyCodePost200ResponseReasonEnum>
    _$boardingVerifyCodePost200ResponseReasonEnumSerializer =
    _$BoardingVerifyCodePost200ResponseReasonEnumSerializer();

class _$BoardingVerifyCodePost200ResponseReasonEnumSerializer
    implements
        PrimitiveSerializer<BoardingVerifyCodePost200ResponseReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'invalid': 'invalid',
    'alreadyBoarded': 'already_boarded',
    'ambiguous': 'ambiguous',
    'forbidden': 'forbidden',
    'notFound': 'not_found',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'invalid': 'invalid',
    'already_boarded': 'alreadyBoarded',
    'ambiguous': 'ambiguous',
    'forbidden': 'forbidden',
    'not_found': 'notFound',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingVerifyCodePost200ResponseReasonEnum
  ];
  @override
  final String wireName = 'BoardingVerifyCodePost200ResponseReasonEnum';

  @override
  Object serialize(Serializers serializers,
          BoardingVerifyCodePost200ResponseReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingVerifyCodePost200ResponseReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingVerifyCodePost200ResponseReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingVerifyCodePost200Response
    extends BoardingVerifyCodePost200Response {
  @override
  final String? riderId;
  @override
  final BoardingVerifyCodePost200ResponseReasonEnum reason;
  @override
  final bool deducted;

  factory _$BoardingVerifyCodePost200Response(
          [void Function(BoardingVerifyCodePost200ResponseBuilder)? updates]) =>
      (BoardingVerifyCodePost200ResponseBuilder()..update(updates))._build();

  _$BoardingVerifyCodePost200Response._(
      {this.riderId, required this.reason, required this.deducted})
      : super._();
  @override
  BoardingVerifyCodePost200Response rebuild(
          void Function(BoardingVerifyCodePost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingVerifyCodePost200ResponseBuilder toBuilder() =>
      BoardingVerifyCodePost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingVerifyCodePost200Response &&
        riderId == other.riderId &&
        reason == other.reason &&
        deducted == other.deducted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, deducted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingVerifyCodePost200Response')
          ..add('riderId', riderId)
          ..add('reason', reason)
          ..add('deducted', deducted))
        .toString();
  }
}

class BoardingVerifyCodePost200ResponseBuilder
    implements
        Builder<BoardingVerifyCodePost200Response,
            BoardingVerifyCodePost200ResponseBuilder> {
  _$BoardingVerifyCodePost200Response? _$v;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  BoardingVerifyCodePost200ResponseReasonEnum? _reason;
  BoardingVerifyCodePost200ResponseReasonEnum? get reason => _$this._reason;
  set reason(BoardingVerifyCodePost200ResponseReasonEnum? reason) =>
      _$this._reason = reason;

  bool? _deducted;
  bool? get deducted => _$this._deducted;
  set deducted(bool? deducted) => _$this._deducted = deducted;

  BoardingVerifyCodePost200ResponseBuilder() {
    BoardingVerifyCodePost200Response._defaults(this);
  }

  BoardingVerifyCodePost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _riderId = $v.riderId;
      _reason = $v.reason;
      _deducted = $v.deducted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingVerifyCodePost200Response other) {
    _$v = other as _$BoardingVerifyCodePost200Response;
  }

  @override
  void update(
      void Function(BoardingVerifyCodePost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingVerifyCodePost200Response build() => _build();

  _$BoardingVerifyCodePost200Response _build() {
    final _$result = _$v ??
        _$BoardingVerifyCodePost200Response._(
          riderId: riderId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'BoardingVerifyCodePost200Response', 'reason'),
          deducted: BuiltValueNullFieldError.checkNotNull(
              deducted, r'BoardingVerifyCodePost200Response', 'deducted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
