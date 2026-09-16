// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_input_departure_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ScheduleInputDepartureOneOfKindEnum
    _$scheduleInputDepartureOneOfKindEnum_new_ =
    const ScheduleInputDepartureOneOfKindEnum._('new_');

ScheduleInputDepartureOneOfKindEnum
    _$scheduleInputDepartureOneOfKindEnumValueOf(String name) {
  switch (name) {
    case 'new_':
      return _$scheduleInputDepartureOneOfKindEnum_new_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleInputDepartureOneOfKindEnum>
    _$scheduleInputDepartureOneOfKindEnumValues = BuiltSet<
        ScheduleInputDepartureOneOfKindEnum>(const <ScheduleInputDepartureOneOfKindEnum>[
  _$scheduleInputDepartureOneOfKindEnum_new_,
]);

Serializer<ScheduleInputDepartureOneOfKindEnum>
    _$scheduleInputDepartureOneOfKindEnumSerializer =
    _$ScheduleInputDepartureOneOfKindEnumSerializer();

class _$ScheduleInputDepartureOneOfKindEnumSerializer
    implements PrimitiveSerializer<ScheduleInputDepartureOneOfKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'new_': 'new',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'new': 'new_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ScheduleInputDepartureOneOfKindEnum
  ];
  @override
  final String wireName = 'ScheduleInputDepartureOneOfKindEnum';

  @override
  Object serialize(
          Serializers serializers, ScheduleInputDepartureOneOfKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleInputDepartureOneOfKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleInputDepartureOneOfKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleInputDepartureOneOf extends ScheduleInputDepartureOneOf {
  @override
  final ScheduleInputDepartureOneOfKindEnum kind;

  factory _$ScheduleInputDepartureOneOf(
          [void Function(ScheduleInputDepartureOneOfBuilder)? updates]) =>
      (ScheduleInputDepartureOneOfBuilder()..update(updates))._build();

  _$ScheduleInputDepartureOneOf._({required this.kind}) : super._();
  @override
  ScheduleInputDepartureOneOf rebuild(
          void Function(ScheduleInputDepartureOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleInputDepartureOneOfBuilder toBuilder() =>
      ScheduleInputDepartureOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduleInputDepartureOneOf && kind == other.kind;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScheduleInputDepartureOneOf')
          ..add('kind', kind))
        .toString();
  }
}

class ScheduleInputDepartureOneOfBuilder
    implements
        Builder<ScheduleInputDepartureOneOf,
            ScheduleInputDepartureOneOfBuilder> {
  _$ScheduleInputDepartureOneOf? _$v;

  ScheduleInputDepartureOneOfKindEnum? _kind;
  ScheduleInputDepartureOneOfKindEnum? get kind => _$this._kind;
  set kind(ScheduleInputDepartureOneOfKindEnum? kind) => _$this._kind = kind;

  ScheduleInputDepartureOneOfBuilder() {
    ScheduleInputDepartureOneOf._defaults(this);
  }

  ScheduleInputDepartureOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduleInputDepartureOneOf other) {
    _$v = other as _$ScheduleInputDepartureOneOf;
  }

  @override
  void update(void Function(ScheduleInputDepartureOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScheduleInputDepartureOneOf build() => _build();

  _$ScheduleInputDepartureOneOf _build() {
    final _$result = _$v ??
        _$ScheduleInputDepartureOneOf._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ScheduleInputDepartureOneOf', 'kind'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
