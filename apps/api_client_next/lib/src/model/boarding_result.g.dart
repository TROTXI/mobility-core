// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingResultStatusEnum _$boardingResultStatusEnum_boarded =
    const BoardingResultStatusEnum._('boarded');
const BoardingResultStatusEnum _$boardingResultStatusEnum_noShow =
    const BoardingResultStatusEnum._('noShow');

BoardingResultStatusEnum _$boardingResultStatusEnumValueOf(String name) {
  switch (name) {
    case 'boarded':
      return _$boardingResultStatusEnum_boarded;
    case 'noShow':
      return _$boardingResultStatusEnum_noShow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingResultStatusEnum> _$boardingResultStatusEnumValues =
    BuiltSet<BoardingResultStatusEnum>(const <BoardingResultStatusEnum>[
  _$boardingResultStatusEnum_boarded,
  _$boardingResultStatusEnum_noShow,
]);

Serializer<BoardingResultStatusEnum> _$boardingResultStatusEnumSerializer =
    _$BoardingResultStatusEnumSerializer();

class _$BoardingResultStatusEnumSerializer
    implements PrimitiveSerializer<BoardingResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'boarded': 'boarded',
    'noShow': 'no_show',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'boarded': 'boarded',
    'no_show': 'noShow',
  };

  @override
  final Iterable<Type> types = const <Type>[BoardingResultStatusEnum];
  @override
  final String wireName = 'BoardingResultStatusEnum';

  @override
  Object serialize(Serializers serializers, BoardingResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingResultStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingResult extends BoardingResult {
  @override
  final String reservationId;
  @override
  final BoardingResultStatusEnum status;
  @override
  final bool alreadyApplied;
  @override
  final int chargedRides;

  factory _$BoardingResult([void Function(BoardingResultBuilder)? updates]) =>
      (BoardingResultBuilder()..update(updates))._build();

  _$BoardingResult._(
      {required this.reservationId,
      required this.status,
      required this.alreadyApplied,
      required this.chargedRides})
      : super._();
  @override
  BoardingResult rebuild(void Function(BoardingResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingResultBuilder toBuilder() => BoardingResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingResult &&
        reservationId == other.reservationId &&
        status == other.status &&
        alreadyApplied == other.alreadyApplied &&
        chargedRides == other.chargedRides;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, alreadyApplied.hashCode);
    _$hash = $jc(_$hash, chargedRides.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingResult')
          ..add('reservationId', reservationId)
          ..add('status', status)
          ..add('alreadyApplied', alreadyApplied)
          ..add('chargedRides', chargedRides))
        .toString();
  }
}

class BoardingResultBuilder
    implements Builder<BoardingResult, BoardingResultBuilder> {
  _$BoardingResult? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  BoardingResultStatusEnum? _status;
  BoardingResultStatusEnum? get status => _$this._status;
  set status(BoardingResultStatusEnum? status) => _$this._status = status;

  bool? _alreadyApplied;
  bool? get alreadyApplied => _$this._alreadyApplied;
  set alreadyApplied(bool? alreadyApplied) =>
      _$this._alreadyApplied = alreadyApplied;

  int? _chargedRides;
  int? get chargedRides => _$this._chargedRides;
  set chargedRides(int? chargedRides) => _$this._chargedRides = chargedRides;

  BoardingResultBuilder() {
    BoardingResult._defaults(this);
  }

  BoardingResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _status = $v.status;
      _alreadyApplied = $v.alreadyApplied;
      _chargedRides = $v.chargedRides;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingResult other) {
    _$v = other as _$BoardingResult;
  }

  @override
  void update(void Function(BoardingResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingResult build() => _build();

  _$BoardingResult _build() {
    final _$result = _$v ??
        _$BoardingResult._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'BoardingResult', 'reservationId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'BoardingResult', 'status'),
          alreadyApplied: BuiltValueNullFieldError.checkNotNull(
              alreadyApplied, r'BoardingResult', 'alreadyApplied'),
          chargedRides: BuiltValueNullFieldError.checkNotNull(
              chargedRides, r'BoardingResult', 'chargedRides'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
