// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkRequestInputKindEnum _$workRequestInputKindEnum_leave =
    const WorkRequestInputKindEnum._('leave');

WorkRequestInputKindEnum _$workRequestInputKindEnumValueOf(String name) {
  switch (name) {
    case 'leave':
      return _$workRequestInputKindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkRequestInputKindEnum> _$workRequestInputKindEnumValues =
    BuiltSet<WorkRequestInputKindEnum>(const <WorkRequestInputKindEnum>[
  _$workRequestInputKindEnum_leave,
]);

Serializer<WorkRequestInputKindEnum> _$workRequestInputKindEnumSerializer =
    _$WorkRequestInputKindEnumSerializer();

class _$WorkRequestInputKindEnumSerializer
    implements PrimitiveSerializer<WorkRequestInputKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'leave': 'leave',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'leave': 'leave',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkRequestInputKindEnum];
  @override
  final String wireName = 'WorkRequestInputKindEnum';

  @override
  Object serialize(Serializers serializers, WorkRequestInputKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkRequestInputKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkRequestInputKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkRequestInput extends WorkRequestInput {
  @override
  final OneOf oneOf;

  factory _$WorkRequestInput(
          [void Function(WorkRequestInputBuilder)? updates]) =>
      (WorkRequestInputBuilder()..update(updates))._build();

  _$WorkRequestInput._({required this.oneOf}) : super._();
  @override
  WorkRequestInput rebuild(void Function(WorkRequestInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestInputBuilder toBuilder() =>
      WorkRequestInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequestInput && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'WorkRequestInput')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class WorkRequestInputBuilder
    implements Builder<WorkRequestInput, WorkRequestInputBuilder> {
  _$WorkRequestInput? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  WorkRequestInputBuilder() {
    WorkRequestInput._defaults(this);
  }

  WorkRequestInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequestInput other) {
    _$v = other as _$WorkRequestInput;
  }

  @override
  void update(void Function(WorkRequestInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequestInput build() => _build();

  _$WorkRequestInput _build() {
    final _$result = _$v ??
        _$WorkRequestInput._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'WorkRequestInput', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
