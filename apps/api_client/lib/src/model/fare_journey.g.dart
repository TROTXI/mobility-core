// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_journey.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FareJourneyDirectionEnum _$fareJourneyDirectionEnum_outbound =
    const FareJourneyDirectionEnum._('outbound');
const FareJourneyDirectionEnum _$fareJourneyDirectionEnum_return_ =
    const FareJourneyDirectionEnum._('return_');

FareJourneyDirectionEnum _$fareJourneyDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$fareJourneyDirectionEnum_outbound;
    case 'return_':
      return _$fareJourneyDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FareJourneyDirectionEnum> _$fareJourneyDirectionEnumValues =
    BuiltSet<FareJourneyDirectionEnum>(const <FareJourneyDirectionEnum>[
  _$fareJourneyDirectionEnum_outbound,
  _$fareJourneyDirectionEnum_return_,
]);

Serializer<FareJourneyDirectionEnum> _$fareJourneyDirectionEnumSerializer =
    _$FareJourneyDirectionEnumSerializer();

class _$FareJourneyDirectionEnumSerializer
    implements PrimitiveSerializer<FareJourneyDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[FareJourneyDirectionEnum];
  @override
  final String wireName = 'FareJourneyDirectionEnum';

  @override
  Object serialize(Serializers serializers, FareJourneyDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FareJourneyDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FareJourneyDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FareJourney extends FareJourney {
  @override
  final String pickup;
  @override
  final String dropoff;
  @override
  final FareJourneyDirectionEnum direction;

  factory _$FareJourney([void Function(FareJourneyBuilder)? updates]) =>
      (FareJourneyBuilder()..update(updates))._build();

  _$FareJourney._(
      {required this.pickup, required this.dropoff, required this.direction})
      : super._();
  @override
  FareJourney rebuild(void Function(FareJourneyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareJourneyBuilder toBuilder() => FareJourneyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareJourney &&
        pickup == other.pickup &&
        dropoff == other.dropoff &&
        direction == other.direction;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pickup.hashCode);
    _$hash = $jc(_$hash, dropoff.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareJourney')
          ..add('pickup', pickup)
          ..add('dropoff', dropoff)
          ..add('direction', direction))
        .toString();
  }
}

class FareJourneyBuilder implements Builder<FareJourney, FareJourneyBuilder> {
  _$FareJourney? _$v;

  String? _pickup;
  String? get pickup => _$this._pickup;
  set pickup(String? pickup) => _$this._pickup = pickup;

  String? _dropoff;
  String? get dropoff => _$this._dropoff;
  set dropoff(String? dropoff) => _$this._dropoff = dropoff;

  FareJourneyDirectionEnum? _direction;
  FareJourneyDirectionEnum? get direction => _$this._direction;
  set direction(FareJourneyDirectionEnum? direction) =>
      _$this._direction = direction;

  FareJourneyBuilder() {
    FareJourney._defaults(this);
  }

  FareJourneyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pickup = $v.pickup;
      _dropoff = $v.dropoff;
      _direction = $v.direction;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareJourney other) {
    _$v = other as _$FareJourney;
  }

  @override
  void update(void Function(FareJourneyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareJourney build() => _build();

  _$FareJourney _build() {
    final _$result = _$v ??
        _$FareJourney._(
          pickup: BuiltValueNullFieldError.checkNotNull(
              pickup, r'FareJourney', 'pickup'),
          dropoff: BuiltValueNullFieldError.checkNotNull(
              dropoff, r'FareJourney', 'dropoff'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'FareJourney', 'direction'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
