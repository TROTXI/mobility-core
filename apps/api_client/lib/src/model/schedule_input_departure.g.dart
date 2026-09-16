// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_input_departure.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ScheduleInputDepartureKindEnum _$scheduleInputDepartureKindEnum_existing =
    const ScheduleInputDepartureKindEnum._('existing');

ScheduleInputDepartureKindEnum _$scheduleInputDepartureKindEnumValueOf(
    String name) {
  switch (name) {
    case 'existing':
      return _$scheduleInputDepartureKindEnum_existing;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleInputDepartureKindEnum>
    _$scheduleInputDepartureKindEnumValues = BuiltSet<
        ScheduleInputDepartureKindEnum>(const <ScheduleInputDepartureKindEnum>[
  _$scheduleInputDepartureKindEnum_existing,
]);

Serializer<ScheduleInputDepartureKindEnum>
    _$scheduleInputDepartureKindEnumSerializer =
    _$ScheduleInputDepartureKindEnumSerializer();

class _$ScheduleInputDepartureKindEnumSerializer
    implements PrimitiveSerializer<ScheduleInputDepartureKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'existing': 'existing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'existing': 'existing',
  };

  @override
  final Iterable<Type> types = const <Type>[ScheduleInputDepartureKindEnum];
  @override
  final String wireName = 'ScheduleInputDepartureKindEnum';

  @override
  Object serialize(
          Serializers serializers, ScheduleInputDepartureKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleInputDepartureKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleInputDepartureKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleInputDeparture extends ScheduleInputDeparture {
  @override
  final OneOf oneOf;

  factory _$ScheduleInputDeparture(
          [void Function(ScheduleInputDepartureBuilder)? updates]) =>
      (ScheduleInputDepartureBuilder()..update(updates))._build();

  _$ScheduleInputDeparture._({required this.oneOf}) : super._();
  @override
  ScheduleInputDeparture rebuild(
          void Function(ScheduleInputDepartureBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleInputDepartureBuilder toBuilder() =>
      ScheduleInputDepartureBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduleInputDeparture && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScheduleInputDeparture')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ScheduleInputDepartureBuilder
    implements Builder<ScheduleInputDeparture, ScheduleInputDepartureBuilder> {
  _$ScheduleInputDeparture? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ScheduleInputDepartureBuilder() {
    ScheduleInputDeparture._defaults(this);
  }

  ScheduleInputDepartureBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduleInputDeparture other) {
    _$v = other as _$ScheduleInputDeparture;
  }

  @override
  void update(void Function(ScheduleInputDepartureBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScheduleInputDeparture build() => _build();

  _$ScheduleInputDeparture _build() {
    final _$result = _$v ??
        _$ScheduleInputDeparture._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'ScheduleInputDeparture', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
