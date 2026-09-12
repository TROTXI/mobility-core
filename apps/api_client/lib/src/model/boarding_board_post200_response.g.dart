// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_board_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnum_ok =
    const BoardingBoardPost200ResponseReasonEnum._('ok');
const BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnum_notFound =
    const BoardingBoardPost200ResponseReasonEnum._('notFound');
const BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnum_alreadyBoarded =
    const BoardingBoardPost200ResponseReasonEnum._('alreadyBoarded');
const BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnum_notBoardable =
    const BoardingBoardPost200ResponseReasonEnum._('notBoardable');
const BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnum_forbidden =
    const BoardingBoardPost200ResponseReasonEnum._('forbidden');

BoardingBoardPost200ResponseReasonEnum
    _$boardingBoardPost200ResponseReasonEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$boardingBoardPost200ResponseReasonEnum_ok;
    case 'notFound':
      return _$boardingBoardPost200ResponseReasonEnum_notFound;
    case 'alreadyBoarded':
      return _$boardingBoardPost200ResponseReasonEnum_alreadyBoarded;
    case 'notBoardable':
      return _$boardingBoardPost200ResponseReasonEnum_notBoardable;
    case 'forbidden':
      return _$boardingBoardPost200ResponseReasonEnum_forbidden;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingBoardPost200ResponseReasonEnum>
    _$boardingBoardPost200ResponseReasonEnumValues = BuiltSet<
        BoardingBoardPost200ResponseReasonEnum>(const <BoardingBoardPost200ResponseReasonEnum>[
  _$boardingBoardPost200ResponseReasonEnum_ok,
  _$boardingBoardPost200ResponseReasonEnum_notFound,
  _$boardingBoardPost200ResponseReasonEnum_alreadyBoarded,
  _$boardingBoardPost200ResponseReasonEnum_notBoardable,
  _$boardingBoardPost200ResponseReasonEnum_forbidden,
]);

Serializer<BoardingBoardPost200ResponseReasonEnum>
    _$boardingBoardPost200ResponseReasonEnumSerializer =
    _$BoardingBoardPost200ResponseReasonEnumSerializer();

class _$BoardingBoardPost200ResponseReasonEnumSerializer
    implements PrimitiveSerializer<BoardingBoardPost200ResponseReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'notFound': 'not_found',
    'alreadyBoarded': 'already_boarded',
    'notBoardable': 'not_boardable',
    'forbidden': 'forbidden',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'not_found': 'notFound',
    'already_boarded': 'alreadyBoarded',
    'not_boardable': 'notBoardable',
    'forbidden': 'forbidden',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingBoardPost200ResponseReasonEnum
  ];
  @override
  final String wireName = 'BoardingBoardPost200ResponseReasonEnum';

  @override
  Object serialize(Serializers serializers,
          BoardingBoardPost200ResponseReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingBoardPost200ResponseReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingBoardPost200ResponseReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingBoardPost200Response extends BoardingBoardPost200Response {
  @override
  final String? riderId;
  @override
  final BoardingBoardPost200ResponseReasonEnum reason;
  @override
  final bool deducted;

  factory _$BoardingBoardPost200Response(
          [void Function(BoardingBoardPost200ResponseBuilder)? updates]) =>
      (BoardingBoardPost200ResponseBuilder()..update(updates))._build();

  _$BoardingBoardPost200Response._(
      {this.riderId, required this.reason, required this.deducted})
      : super._();
  @override
  BoardingBoardPost200Response rebuild(
          void Function(BoardingBoardPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingBoardPost200ResponseBuilder toBuilder() =>
      BoardingBoardPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingBoardPost200Response &&
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
    return (newBuiltValueToStringHelper(r'BoardingBoardPost200Response')
          ..add('riderId', riderId)
          ..add('reason', reason)
          ..add('deducted', deducted))
        .toString();
  }
}

class BoardingBoardPost200ResponseBuilder
    implements
        Builder<BoardingBoardPost200Response,
            BoardingBoardPost200ResponseBuilder> {
  _$BoardingBoardPost200Response? _$v;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  BoardingBoardPost200ResponseReasonEnum? _reason;
  BoardingBoardPost200ResponseReasonEnum? get reason => _$this._reason;
  set reason(BoardingBoardPost200ResponseReasonEnum? reason) =>
      _$this._reason = reason;

  bool? _deducted;
  bool? get deducted => _$this._deducted;
  set deducted(bool? deducted) => _$this._deducted = deducted;

  BoardingBoardPost200ResponseBuilder() {
    BoardingBoardPost200Response._defaults(this);
  }

  BoardingBoardPost200ResponseBuilder get _$this {
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
  void replace(BoardingBoardPost200Response other) {
    _$v = other as _$BoardingBoardPost200Response;
  }

  @override
  void update(void Function(BoardingBoardPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingBoardPost200Response build() => _build();

  _$BoardingBoardPost200Response _build() {
    final _$result = _$v ??
        _$BoardingBoardPost200Response._(
          riderId: riderId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'BoardingBoardPost200Response', 'reason'),
          deducted: BuiltValueNullFieldError.checkNotNull(
              deducted, r'BoardingBoardPost200Response', 'deducted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
