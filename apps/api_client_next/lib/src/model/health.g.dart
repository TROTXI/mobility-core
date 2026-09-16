// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HealthStatusEnum _$healthStatusEnum_ok = const HealthStatusEnum._('ok');
const HealthStatusEnum _$healthStatusEnum_unavailable =
    const HealthStatusEnum._('unavailable');

HealthStatusEnum _$healthStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$healthStatusEnum_ok;
    case 'unavailable':
      return _$healthStatusEnum_unavailable;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HealthStatusEnum> _$healthStatusEnumValues =
    BuiltSet<HealthStatusEnum>(const <HealthStatusEnum>[
  _$healthStatusEnum_ok,
  _$healthStatusEnum_unavailable,
]);

Serializer<HealthStatusEnum> _$healthStatusEnumSerializer =
    _$HealthStatusEnumSerializer();

class _$HealthStatusEnumSerializer
    implements PrimitiveSerializer<HealthStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'unavailable': 'unavailable',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'unavailable': 'unavailable',
  };

  @override
  final Iterable<Type> types = const <Type>[HealthStatusEnum];
  @override
  final String wireName = 'HealthStatusEnum';

  @override
  Object serialize(Serializers serializers, HealthStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HealthStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HealthStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Health extends Health {
  @override
  final HealthStatusEnum status;

  factory _$Health([void Function(HealthBuilder)? updates]) =>
      (HealthBuilder()..update(updates))._build();

  _$Health._({required this.status}) : super._();
  @override
  Health rebuild(void Function(HealthBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HealthBuilder toBuilder() => HealthBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Health && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Health')..add('status', status))
        .toString();
  }
}

class HealthBuilder implements Builder<Health, HealthBuilder> {
  _$Health? _$v;

  HealthStatusEnum? _status;
  HealthStatusEnum? get status => _$this._status;
  set status(HealthStatusEnum? status) => _$this._status = status;

  HealthBuilder() {
    Health._defaults(this);
  }

  HealthBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Health other) {
    _$v = other as _$Health;
  }

  @override
  void update(void Function(HealthBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Health build() => _build();

  _$Health _build() {
    final _$result = _$v ??
        _$Health._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Health', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
