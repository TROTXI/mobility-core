// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_no_show_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_ok =
    const BoardingNoShowPost200ResponseReasonEnum._('ok');
const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_notFound =
    const BoardingNoShowPost200ResponseReasonEnum._('notFound');
const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_alreadyBoarded =
    const BoardingNoShowPost200ResponseReasonEnum._('alreadyBoarded');
const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_alreadyNoShow =
    const BoardingNoShowPost200ResponseReasonEnum._('alreadyNoShow');
const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_notBoardable =
    const BoardingNoShowPost200ResponseReasonEnum._('notBoardable');
const BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnum_forbidden =
    const BoardingNoShowPost200ResponseReasonEnum._('forbidden');

BoardingNoShowPost200ResponseReasonEnum
    _$boardingNoShowPost200ResponseReasonEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$boardingNoShowPost200ResponseReasonEnum_ok;
    case 'notFound':
      return _$boardingNoShowPost200ResponseReasonEnum_notFound;
    case 'alreadyBoarded':
      return _$boardingNoShowPost200ResponseReasonEnum_alreadyBoarded;
    case 'alreadyNoShow':
      return _$boardingNoShowPost200ResponseReasonEnum_alreadyNoShow;
    case 'notBoardable':
      return _$boardingNoShowPost200ResponseReasonEnum_notBoardable;
    case 'forbidden':
      return _$boardingNoShowPost200ResponseReasonEnum_forbidden;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingNoShowPost200ResponseReasonEnum>
    _$boardingNoShowPost200ResponseReasonEnumValues = BuiltSet<
        BoardingNoShowPost200ResponseReasonEnum>(const <BoardingNoShowPost200ResponseReasonEnum>[
  _$boardingNoShowPost200ResponseReasonEnum_ok,
  _$boardingNoShowPost200ResponseReasonEnum_notFound,
  _$boardingNoShowPost200ResponseReasonEnum_alreadyBoarded,
  _$boardingNoShowPost200ResponseReasonEnum_alreadyNoShow,
  _$boardingNoShowPost200ResponseReasonEnum_notBoardable,
  _$boardingNoShowPost200ResponseReasonEnum_forbidden,
]);

Serializer<BoardingNoShowPost200ResponseReasonEnum>
    _$boardingNoShowPost200ResponseReasonEnumSerializer =
    _$BoardingNoShowPost200ResponseReasonEnumSerializer();

class _$BoardingNoShowPost200ResponseReasonEnumSerializer
    implements PrimitiveSerializer<BoardingNoShowPost200ResponseReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'notFound': 'not_found',
    'alreadyBoarded': 'already_boarded',
    'alreadyNoShow': 'already_no_show',
    'notBoardable': 'not_boardable',
    'forbidden': 'forbidden',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'not_found': 'notFound',
    'already_boarded': 'alreadyBoarded',
    'already_no_show': 'alreadyNoShow',
    'not_boardable': 'notBoardable',
    'forbidden': 'forbidden',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingNoShowPost200ResponseReasonEnum
  ];
  @override
  final String wireName = 'BoardingNoShowPost200ResponseReasonEnum';

  @override
  Object serialize(Serializers serializers,
          BoardingNoShowPost200ResponseReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingNoShowPost200ResponseReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingNoShowPost200ResponseReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingNoShowPost200Response extends BoardingNoShowPost200Response {
  @override
  final String? riderId;
  @override
  final BoardingNoShowPost200ResponseReasonEnum reason;
  @override
  final bool deducted;

  factory _$BoardingNoShowPost200Response(
          [void Function(BoardingNoShowPost200ResponseBuilder)? updates]) =>
      (BoardingNoShowPost200ResponseBuilder()..update(updates))._build();

  _$BoardingNoShowPost200Response._(
      {this.riderId, required this.reason, required this.deducted})
      : super._();
  @override
  BoardingNoShowPost200Response rebuild(
          void Function(BoardingNoShowPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingNoShowPost200ResponseBuilder toBuilder() =>
      BoardingNoShowPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingNoShowPost200Response &&
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
    return (newBuiltValueToStringHelper(r'BoardingNoShowPost200Response')
          ..add('riderId', riderId)
          ..add('reason', reason)
          ..add('deducted', deducted))
        .toString();
  }
}

class BoardingNoShowPost200ResponseBuilder
    implements
        Builder<BoardingNoShowPost200Response,
            BoardingNoShowPost200ResponseBuilder> {
  _$BoardingNoShowPost200Response? _$v;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  BoardingNoShowPost200ResponseReasonEnum? _reason;
  BoardingNoShowPost200ResponseReasonEnum? get reason => _$this._reason;
  set reason(BoardingNoShowPost200ResponseReasonEnum? reason) =>
      _$this._reason = reason;

  bool? _deducted;
  bool? get deducted => _$this._deducted;
  set deducted(bool? deducted) => _$this._deducted = deducted;

  BoardingNoShowPost200ResponseBuilder() {
    BoardingNoShowPost200Response._defaults(this);
  }

  BoardingNoShowPost200ResponseBuilder get _$this {
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
  void replace(BoardingNoShowPost200Response other) {
    _$v = other as _$BoardingNoShowPost200Response;
  }

  @override
  void update(void Function(BoardingNoShowPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingNoShowPost200Response build() => _build();

  _$BoardingNoShowPost200Response _build() {
    final _$result = _$v ??
        _$BoardingNoShowPost200Response._(
          riderId: riderId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'BoardingNoShowPost200Response', 'reason'),
          deducted: BuiltValueNullFieldError.checkNotNull(
              deducted, r'BoardingNoShowPost200Response', 'deducted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
