// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_min_versions_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminMinVersionsGet200ResponseInnerPlatformEnum
    _$adminMinVersionsGet200ResponseInnerPlatformEnum_ios =
    const AdminMinVersionsGet200ResponseInnerPlatformEnum._('ios');
const AdminMinVersionsGet200ResponseInnerPlatformEnum
    _$adminMinVersionsGet200ResponseInnerPlatformEnum_android =
    const AdminMinVersionsGet200ResponseInnerPlatformEnum._('android');

AdminMinVersionsGet200ResponseInnerPlatformEnum
    _$adminMinVersionsGet200ResponseInnerPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$adminMinVersionsGet200ResponseInnerPlatformEnum_ios;
    case 'android':
      return _$adminMinVersionsGet200ResponseInnerPlatformEnum_android;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminMinVersionsGet200ResponseInnerPlatformEnum>
    _$adminMinVersionsGet200ResponseInnerPlatformEnumValues = BuiltSet<
        AdminMinVersionsGet200ResponseInnerPlatformEnum>(const <AdminMinVersionsGet200ResponseInnerPlatformEnum>[
  _$adminMinVersionsGet200ResponseInnerPlatformEnum_ios,
  _$adminMinVersionsGet200ResponseInnerPlatformEnum_android,
]);

Serializer<AdminMinVersionsGet200ResponseInnerPlatformEnum>
    _$adminMinVersionsGet200ResponseInnerPlatformEnumSerializer =
    _$AdminMinVersionsGet200ResponseInnerPlatformEnumSerializer();

class _$AdminMinVersionsGet200ResponseInnerPlatformEnumSerializer
    implements
        PrimitiveSerializer<AdminMinVersionsGet200ResponseInnerPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminMinVersionsGet200ResponseInnerPlatformEnum
  ];
  @override
  final String wireName = 'AdminMinVersionsGet200ResponseInnerPlatformEnum';

  @override
  Object serialize(Serializers serializers,
          AdminMinVersionsGet200ResponseInnerPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminMinVersionsGet200ResponseInnerPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminMinVersionsGet200ResponseInnerPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminMinVersionsGet200ResponseInner
    extends AdminMinVersionsGet200ResponseInner {
  @override
  final AdminMinVersionsGet200ResponseInnerPlatformEnum platform;
  @override
  final String version;
  @override
  final DateTime updatedAt;

  factory _$AdminMinVersionsGet200ResponseInner(
          [void Function(AdminMinVersionsGet200ResponseInnerBuilder)?
              updates]) =>
      (AdminMinVersionsGet200ResponseInnerBuilder()..update(updates))._build();

  _$AdminMinVersionsGet200ResponseInner._(
      {required this.platform, required this.version, required this.updatedAt})
      : super._();
  @override
  AdminMinVersionsGet200ResponseInner rebuild(
          void Function(AdminMinVersionsGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminMinVersionsGet200ResponseInnerBuilder toBuilder() =>
      AdminMinVersionsGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMinVersionsGet200ResponseInner &&
        platform == other.platform &&
        version == other.version &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminMinVersionsGet200ResponseInner')
          ..add('platform', platform)
          ..add('version', version)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AdminMinVersionsGet200ResponseInnerBuilder
    implements
        Builder<AdminMinVersionsGet200ResponseInner,
            AdminMinVersionsGet200ResponseInnerBuilder> {
  _$AdminMinVersionsGet200ResponseInner? _$v;

  AdminMinVersionsGet200ResponseInnerPlatformEnum? _platform;
  AdminMinVersionsGet200ResponseInnerPlatformEnum? get platform =>
      _$this._platform;
  set platform(AdminMinVersionsGet200ResponseInnerPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AdminMinVersionsGet200ResponseInnerBuilder() {
    AdminMinVersionsGet200ResponseInner._defaults(this);
  }

  AdminMinVersionsGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _platform = $v.platform;
      _version = $v.version;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminMinVersionsGet200ResponseInner other) {
    _$v = other as _$AdminMinVersionsGet200ResponseInner;
  }

  @override
  void update(
      void Function(AdminMinVersionsGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminMinVersionsGet200ResponseInner build() => _build();

  _$AdminMinVersionsGet200ResponseInner _build() {
    final _$result = _$v ??
        _$AdminMinVersionsGet200ResponseInner._(
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'AdminMinVersionsGet200ResponseInner', 'platform'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'AdminMinVersionsGet200ResponseInner', 'version'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'AdminMinVersionsGet200ResponseInner', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
