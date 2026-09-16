// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceInputPlatformEnum _$deviceInputPlatformEnum_ios =
    const DeviceInputPlatformEnum._('ios');
const DeviceInputPlatformEnum _$deviceInputPlatformEnum_android =
    const DeviceInputPlatformEnum._('android');

DeviceInputPlatformEnum _$deviceInputPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$deviceInputPlatformEnum_ios;
    case 'android':
      return _$deviceInputPlatformEnum_android;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceInputPlatformEnum> _$deviceInputPlatformEnumValues =
    BuiltSet<DeviceInputPlatformEnum>(const <DeviceInputPlatformEnum>[
  _$deviceInputPlatformEnum_ios,
  _$deviceInputPlatformEnum_android,
]);

Serializer<DeviceInputPlatformEnum> _$deviceInputPlatformEnumSerializer =
    _$DeviceInputPlatformEnumSerializer();

class _$DeviceInputPlatformEnumSerializer
    implements PrimitiveSerializer<DeviceInputPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceInputPlatformEnum];
  @override
  final String wireName = 'DeviceInputPlatformEnum';

  @override
  Object serialize(Serializers serializers, DeviceInputPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceInputPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceInputPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceInput extends DeviceInput {
  @override
  final String token;
  @override
  final DeviceInputPlatformEnum platform;

  factory _$DeviceInput([void Function(DeviceInputBuilder)? updates]) =>
      (DeviceInputBuilder()..update(updates))._build();

  _$DeviceInput._({required this.token, required this.platform}) : super._();
  @override
  DeviceInput rebuild(void Function(DeviceInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceInputBuilder toBuilder() => DeviceInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceInput &&
        token == other.token &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceInput')
          ..add('token', token)
          ..add('platform', platform))
        .toString();
  }
}

class DeviceInputBuilder implements Builder<DeviceInput, DeviceInputBuilder> {
  _$DeviceInput? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DeviceInputPlatformEnum? _platform;
  DeviceInputPlatformEnum? get platform => _$this._platform;
  set platform(DeviceInputPlatformEnum? platform) =>
      _$this._platform = platform;

  DeviceInputBuilder() {
    DeviceInput._defaults(this);
  }

  DeviceInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceInput other) {
    _$v = other as _$DeviceInput;
  }

  @override
  void update(void Function(DeviceInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceInput build() => _build();

  _$DeviceInput _build() {
    final _$result = _$v ??
        _$DeviceInput._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'DeviceInput', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'DeviceInput', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
