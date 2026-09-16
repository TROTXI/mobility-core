// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationDecisionDirectionEnum
    _$reservationDecisionDirectionEnum_outbound =
    const ReservationDecisionDirectionEnum._('outbound');
const ReservationDecisionDirectionEnum
    _$reservationDecisionDirectionEnum_return_ =
    const ReservationDecisionDirectionEnum._('return_');

ReservationDecisionDirectionEnum _$reservationDecisionDirectionEnumValueOf(
    String name) {
  switch (name) {
    case 'outbound':
      return _$reservationDecisionDirectionEnum_outbound;
    case 'return_':
      return _$reservationDecisionDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDecisionDirectionEnum>
    _$reservationDecisionDirectionEnumValues = BuiltSet<
        ReservationDecisionDirectionEnum>(const <ReservationDecisionDirectionEnum>[
  _$reservationDecisionDirectionEnum_outbound,
  _$reservationDecisionDirectionEnum_return_,
]);

const ReservationDecisionDecisionEnum
    _$reservationDecisionDecisionEnum_confirm =
    const ReservationDecisionDecisionEnum._('confirm');
const ReservationDecisionDecisionEnum
    _$reservationDecisionDecisionEnum_decline =
    const ReservationDecisionDecisionEnum._('decline');

ReservationDecisionDecisionEnum _$reservationDecisionDecisionEnumValueOf(
    String name) {
  switch (name) {
    case 'confirm':
      return _$reservationDecisionDecisionEnum_confirm;
    case 'decline':
      return _$reservationDecisionDecisionEnum_decline;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDecisionDecisionEnum>
    _$reservationDecisionDecisionEnumValues = BuiltSet<
        ReservationDecisionDecisionEnum>(const <ReservationDecisionDecisionEnum>[
  _$reservationDecisionDecisionEnum_confirm,
  _$reservationDecisionDecisionEnum_decline,
]);

Serializer<ReservationDecisionDirectionEnum>
    _$reservationDecisionDirectionEnumSerializer =
    _$ReservationDecisionDirectionEnumSerializer();
Serializer<ReservationDecisionDecisionEnum>
    _$reservationDecisionDecisionEnumSerializer =
    _$ReservationDecisionDecisionEnumSerializer();

class _$ReservationDecisionDirectionEnumSerializer
    implements PrimitiveSerializer<ReservationDecisionDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationDecisionDirectionEnum];
  @override
  final String wireName = 'ReservationDecisionDirectionEnum';

  @override
  Object serialize(
          Serializers serializers, ReservationDecisionDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDecisionDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDecisionDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationDecisionDecisionEnumSerializer
    implements PrimitiveSerializer<ReservationDecisionDecisionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'confirm': 'confirm',
    'decline': 'decline',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'confirm': 'confirm',
    'decline': 'decline',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationDecisionDecisionEnum];
  @override
  final String wireName = 'ReservationDecisionDecisionEnum';

  @override
  Object serialize(
          Serializers serializers, ReservationDecisionDecisionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDecisionDecisionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDecisionDecisionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationDecision extends ReservationDecision {
  @override
  final Date travelDate;
  @override
  final ReservationDecisionDirectionEnum direction;
  @override
  final ReservationDecisionDecisionEnum decision;
  @override
  final String? tripId;

  factory _$ReservationDecision(
          [void Function(ReservationDecisionBuilder)? updates]) =>
      (ReservationDecisionBuilder()..update(updates))._build();

  _$ReservationDecision._(
      {required this.travelDate,
      required this.direction,
      required this.decision,
      this.tripId})
      : super._();
  @override
  ReservationDecision rebuild(
          void Function(ReservationDecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDecisionBuilder toBuilder() =>
      ReservationDecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDecision &&
        travelDate == other.travelDate &&
        direction == other.direction &&
        decision == other.decision &&
        tripId == other.tripId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, travelDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, decision.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDecision')
          ..add('travelDate', travelDate)
          ..add('direction', direction)
          ..add('decision', decision)
          ..add('tripId', tripId))
        .toString();
  }
}

class ReservationDecisionBuilder
    implements Builder<ReservationDecision, ReservationDecisionBuilder> {
  _$ReservationDecision? _$v;

  Date? _travelDate;
  Date? get travelDate => _$this._travelDate;
  set travelDate(Date? travelDate) => _$this._travelDate = travelDate;

  ReservationDecisionDirectionEnum? _direction;
  ReservationDecisionDirectionEnum? get direction => _$this._direction;
  set direction(ReservationDecisionDirectionEnum? direction) =>
      _$this._direction = direction;

  ReservationDecisionDecisionEnum? _decision;
  ReservationDecisionDecisionEnum? get decision => _$this._decision;
  set decision(ReservationDecisionDecisionEnum? decision) =>
      _$this._decision = decision;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  ReservationDecisionBuilder() {
    ReservationDecision._defaults(this);
  }

  ReservationDecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _travelDate = $v.travelDate;
      _direction = $v.direction;
      _decision = $v.decision;
      _tripId = $v.tripId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDecision other) {
    _$v = other as _$ReservationDecision;
  }

  @override
  void update(void Function(ReservationDecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDecision build() => _build();

  _$ReservationDecision _build() {
    final _$result = _$v ??
        _$ReservationDecision._(
          travelDate: BuiltValueNullFieldError.checkNotNull(
              travelDate, r'ReservationDecision', 'travelDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'ReservationDecision', 'direction'),
          decision: BuiltValueNullFieldError.checkNotNull(
              decision, r'ReservationDecision', 'decision'),
          tripId: tripId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
