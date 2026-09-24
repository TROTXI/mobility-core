// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PatternInputDirectionEnum _$patternInputDirectionEnum_outbound =
    const PatternInputDirectionEnum._('outbound');
const PatternInputDirectionEnum _$patternInputDirectionEnum_return_ =
    const PatternInputDirectionEnum._('return_');

PatternInputDirectionEnum _$patternInputDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$patternInputDirectionEnum_outbound;
    case 'return_':
      return _$patternInputDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PatternInputDirectionEnum> _$patternInputDirectionEnumValues =
    BuiltSet<PatternInputDirectionEnum>(const <PatternInputDirectionEnum>[
  _$patternInputDirectionEnum_outbound,
  _$patternInputDirectionEnum_return_,
]);

Serializer<PatternInputDirectionEnum> _$patternInputDirectionEnumSerializer =
    _$PatternInputDirectionEnumSerializer();

class _$PatternInputDirectionEnumSerializer
    implements PrimitiveSerializer<PatternInputDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[PatternInputDirectionEnum];
  @override
  final String wireName = 'PatternInputDirectionEnum';

  @override
  Object serialize(Serializers serializers, PatternInputDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatternInputDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PatternInputDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PatternInput extends PatternInput {
  @override
  final String routeId;
  @override
  final PatternInputDirectionEnum direction;

  factory _$PatternInput([void Function(PatternInputBuilder)? updates]) =>
      (PatternInputBuilder()..update(updates))._build();

  _$PatternInput._({required this.routeId, required this.direction})
      : super._();
  @override
  PatternInput rebuild(void Function(PatternInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternInputBuilder toBuilder() => PatternInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternInput &&
        routeId == other.routeId &&
        direction == other.direction;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatternInput')
          ..add('routeId', routeId)
          ..add('direction', direction))
        .toString();
  }
}

class PatternInputBuilder
    implements Builder<PatternInput, PatternInputBuilder> {
  _$PatternInput? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  PatternInputDirectionEnum? _direction;
  PatternInputDirectionEnum? get direction => _$this._direction;
  set direction(PatternInputDirectionEnum? direction) =>
      _$this._direction = direction;

  PatternInputBuilder() {
    PatternInput._defaults(this);
  }

  PatternInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _direction = $v.direction;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternInput other) {
    _$v = other as _$PatternInput;
  }

  @override
  void update(void Function(PatternInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternInput build() => _build();

  _$PatternInput _build() {
    final _$result = _$v ??
        _$PatternInput._(
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'PatternInput', 'routeId'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'PatternInput', 'direction'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
