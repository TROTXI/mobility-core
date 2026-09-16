// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_input_departure_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ScheduleInputDepartureOneOf1KindEnum
    _$scheduleInputDepartureOneOf1KindEnum_existing =
    const ScheduleInputDepartureOneOf1KindEnum._('existing');

ScheduleInputDepartureOneOf1KindEnum
    _$scheduleInputDepartureOneOf1KindEnumValueOf(String name) {
  switch (name) {
    case 'existing':
      return _$scheduleInputDepartureOneOf1KindEnum_existing;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleInputDepartureOneOf1KindEnum>
    _$scheduleInputDepartureOneOf1KindEnumValues = BuiltSet<
        ScheduleInputDepartureOneOf1KindEnum>(const <ScheduleInputDepartureOneOf1KindEnum>[
  _$scheduleInputDepartureOneOf1KindEnum_existing,
]);

Serializer<ScheduleInputDepartureOneOf1KindEnum>
    _$scheduleInputDepartureOneOf1KindEnumSerializer =
    _$ScheduleInputDepartureOneOf1KindEnumSerializer();

class _$ScheduleInputDepartureOneOf1KindEnumSerializer
    implements PrimitiveSerializer<ScheduleInputDepartureOneOf1KindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'existing': 'existing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'existing': 'existing',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ScheduleInputDepartureOneOf1KindEnum
  ];
  @override
  final String wireName = 'ScheduleInputDepartureOneOf1KindEnum';

  @override
  Object serialize(
          Serializers serializers, ScheduleInputDepartureOneOf1KindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleInputDepartureOneOf1KindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleInputDepartureOneOf1KindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleInputDepartureOneOf1 extends ScheduleInputDepartureOneOf1 {
  @override
  final ScheduleInputDepartureOneOf1KindEnum kind;
  @override
  final String departureId;

  factory _$ScheduleInputDepartureOneOf1(
          [void Function(ScheduleInputDepartureOneOf1Builder)? updates]) =>
      (ScheduleInputDepartureOneOf1Builder()..update(updates))._build();

  _$ScheduleInputDepartureOneOf1._(
      {required this.kind, required this.departureId})
      : super._();
  @override
  ScheduleInputDepartureOneOf1 rebuild(
          void Function(ScheduleInputDepartureOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleInputDepartureOneOf1Builder toBuilder() =>
      ScheduleInputDepartureOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduleInputDepartureOneOf1 &&
        kind == other.kind &&
        departureId == other.departureId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, departureId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScheduleInputDepartureOneOf1')
          ..add('kind', kind)
          ..add('departureId', departureId))
        .toString();
  }
}

class ScheduleInputDepartureOneOf1Builder
    implements
        Builder<ScheduleInputDepartureOneOf1,
            ScheduleInputDepartureOneOf1Builder> {
  _$ScheduleInputDepartureOneOf1? _$v;

  ScheduleInputDepartureOneOf1KindEnum? _kind;
  ScheduleInputDepartureOneOf1KindEnum? get kind => _$this._kind;
  set kind(ScheduleInputDepartureOneOf1KindEnum? kind) => _$this._kind = kind;

  String? _departureId;
  String? get departureId => _$this._departureId;
  set departureId(String? departureId) => _$this._departureId = departureId;

  ScheduleInputDepartureOneOf1Builder() {
    ScheduleInputDepartureOneOf1._defaults(this);
  }

  ScheduleInputDepartureOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _departureId = $v.departureId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduleInputDepartureOneOf1 other) {
    _$v = other as _$ScheduleInputDepartureOneOf1;
  }

  @override
  void update(void Function(ScheduleInputDepartureOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScheduleInputDepartureOneOf1 build() => _build();

  _$ScheduleInputDepartureOneOf1 _build() {
    final _$result = _$v ??
        _$ScheduleInputDepartureOneOf1._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ScheduleInputDepartureOneOf1', 'kind'),
          departureId: BuiltValueNullFieldError.checkNotNull(
              departureId, r'ScheduleInputDepartureOneOf1', 'departureId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
