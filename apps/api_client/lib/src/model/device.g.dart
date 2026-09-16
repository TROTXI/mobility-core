// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DevicePlatformEnum _$devicePlatformEnum_ios =
    const DevicePlatformEnum._('ios');
const DevicePlatformEnum _$devicePlatformEnum_android =
    const DevicePlatformEnum._('android');

DevicePlatformEnum _$devicePlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$devicePlatformEnum_ios;
    case 'android':
      return _$devicePlatformEnum_android;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DevicePlatformEnum> _$devicePlatformEnumValues =
    BuiltSet<DevicePlatformEnum>(const <DevicePlatformEnum>[
  _$devicePlatformEnum_ios,
  _$devicePlatformEnum_android,
]);

Serializer<DevicePlatformEnum> _$devicePlatformEnumSerializer =
    _$DevicePlatformEnumSerializer();

class _$DevicePlatformEnumSerializer
    implements PrimitiveSerializer<DevicePlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
  };

  @override
  final Iterable<Type> types = const <Type>[DevicePlatformEnum];
  @override
  final String wireName = 'DevicePlatformEnum';

  @override
  Object serialize(Serializers serializers, DevicePlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DevicePlatformEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DevicePlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Device extends Device {
  @override
  final String id;
  @override
  final DevicePlatformEnum platform;
  @override
  final DateTime updatedAt;

  factory _$Device([void Function(DeviceBuilder)? updates]) =>
      (DeviceBuilder()..update(updates))._build();

  _$Device._(
      {required this.id, required this.platform, required this.updatedAt})
      : super._();
  @override
  Device rebuild(void Function(DeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceBuilder toBuilder() => DeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Device &&
        id == other.id &&
        platform == other.platform &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Device')
          ..add('id', id)
          ..add('platform', platform)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class DeviceBuilder implements Builder<Device, DeviceBuilder> {
  _$Device? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DevicePlatformEnum? _platform;
  DevicePlatformEnum? get platform => _$this._platform;
  set platform(DevicePlatformEnum? platform) => _$this._platform = platform;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DeviceBuilder() {
    Device._defaults(this);
  }

  DeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _platform = $v.platform;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Device other) {
    _$v = other as _$Device;
  }

  @override
  void update(void Function(DeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Device build() => _build();

  _$Device _build() {
    final _$result = _$v ??
        _$Device._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Device', 'id'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'Device', 'platform'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Device', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
