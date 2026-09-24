// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimum_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MinimumVersionAppEnum _$minimumVersionAppEnum_commuter =
    const MinimumVersionAppEnum._('commuter');
const MinimumVersionAppEnum _$minimumVersionAppEnum_driver =
    const MinimumVersionAppEnum._('driver');

MinimumVersionAppEnum _$minimumVersionAppEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$minimumVersionAppEnum_commuter;
    case 'driver':
      return _$minimumVersionAppEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MinimumVersionAppEnum> _$minimumVersionAppEnumValues =
    BuiltSet<MinimumVersionAppEnum>(const <MinimumVersionAppEnum>[
  _$minimumVersionAppEnum_commuter,
  _$minimumVersionAppEnum_driver,
]);

const MinimumVersionPlatformEnum _$minimumVersionPlatformEnum_ios =
    const MinimumVersionPlatformEnum._('ios');
const MinimumVersionPlatformEnum _$minimumVersionPlatformEnum_android =
    const MinimumVersionPlatformEnum._('android');

MinimumVersionPlatformEnum _$minimumVersionPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$minimumVersionPlatformEnum_ios;
    case 'android':
      return _$minimumVersionPlatformEnum_android;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MinimumVersionPlatformEnum> _$minimumVersionPlatformEnumValues =
    BuiltSet<MinimumVersionPlatformEnum>(const <MinimumVersionPlatformEnum>[
  _$minimumVersionPlatformEnum_ios,
  _$minimumVersionPlatformEnum_android,
]);

const MinimumVersionApiMajorEnum _$minimumVersionApiMajorEnum_number1 =
    const MinimumVersionApiMajorEnum._('number1');

MinimumVersionApiMajorEnum _$minimumVersionApiMajorEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$minimumVersionApiMajorEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MinimumVersionApiMajorEnum> _$minimumVersionApiMajorEnumValues =
    BuiltSet<MinimumVersionApiMajorEnum>(const <MinimumVersionApiMajorEnum>[
  _$minimumVersionApiMajorEnum_number1,
]);

Serializer<MinimumVersionAppEnum> _$minimumVersionAppEnumSerializer =
    _$MinimumVersionAppEnumSerializer();
Serializer<MinimumVersionPlatformEnum> _$minimumVersionPlatformEnumSerializer =
    _$MinimumVersionPlatformEnumSerializer();
Serializer<MinimumVersionApiMajorEnum> _$minimumVersionApiMajorEnumSerializer =
    _$MinimumVersionApiMajorEnumSerializer();

class _$MinimumVersionAppEnumSerializer
    implements PrimitiveSerializer<MinimumVersionAppEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'commuter': 'commuter',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'commuter': 'commuter',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[MinimumVersionAppEnum];
  @override
  final String wireName = 'MinimumVersionAppEnum';

  @override
  Object serialize(Serializers serializers, MinimumVersionAppEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MinimumVersionAppEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MinimumVersionAppEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MinimumVersionPlatformEnumSerializer
    implements PrimitiveSerializer<MinimumVersionPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
  };

  @override
  final Iterable<Type> types = const <Type>[MinimumVersionPlatformEnum];
  @override
  final String wireName = 'MinimumVersionPlatformEnum';

  @override
  Object serialize(Serializers serializers, MinimumVersionPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MinimumVersionPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MinimumVersionPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MinimumVersionApiMajorEnumSerializer
    implements PrimitiveSerializer<MinimumVersionApiMajorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[MinimumVersionApiMajorEnum];
  @override
  final String wireName = 'MinimumVersionApiMajorEnum';

  @override
  Object serialize(Serializers serializers, MinimumVersionApiMajorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MinimumVersionApiMajorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MinimumVersionApiMajorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MinimumVersion extends MinimumVersion {
  @override
  final MinimumVersionAppEnum app;
  @override
  final MinimumVersionPlatformEnum platform;
  @override
  final int minSupportedBuild;
  @override
  final MinimumVersionApiMajorEnum apiMajor;
  @override
  final String storeUrl;
  @override
  final int version;

  factory _$MinimumVersion([void Function(MinimumVersionBuilder)? updates]) =>
      (MinimumVersionBuilder()..update(updates))._build();

  _$MinimumVersion._(
      {required this.app,
      required this.platform,
      required this.minSupportedBuild,
      required this.apiMajor,
      required this.storeUrl,
      required this.version})
      : super._();
  @override
  MinimumVersion rebuild(void Function(MinimumVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MinimumVersionBuilder toBuilder() => MinimumVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MinimumVersion &&
        app == other.app &&
        platform == other.platform &&
        minSupportedBuild == other.minSupportedBuild &&
        apiMajor == other.apiMajor &&
        storeUrl == other.storeUrl &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, app.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, minSupportedBuild.hashCode);
    _$hash = $jc(_$hash, apiMajor.hashCode);
    _$hash = $jc(_$hash, storeUrl.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MinimumVersion')
          ..add('app', app)
          ..add('platform', platform)
          ..add('minSupportedBuild', minSupportedBuild)
          ..add('apiMajor', apiMajor)
          ..add('storeUrl', storeUrl)
          ..add('version', version))
        .toString();
  }
}

class MinimumVersionBuilder
    implements Builder<MinimumVersion, MinimumVersionBuilder> {
  _$MinimumVersion? _$v;

  MinimumVersionAppEnum? _app;
  MinimumVersionAppEnum? get app => _$this._app;
  set app(MinimumVersionAppEnum? app) => _$this._app = app;

  MinimumVersionPlatformEnum? _platform;
  MinimumVersionPlatformEnum? get platform => _$this._platform;
  set platform(MinimumVersionPlatformEnum? platform) =>
      _$this._platform = platform;

  int? _minSupportedBuild;
  int? get minSupportedBuild => _$this._minSupportedBuild;
  set minSupportedBuild(int? minSupportedBuild) =>
      _$this._minSupportedBuild = minSupportedBuild;

  MinimumVersionApiMajorEnum? _apiMajor;
  MinimumVersionApiMajorEnum? get apiMajor => _$this._apiMajor;
  set apiMajor(MinimumVersionApiMajorEnum? apiMajor) =>
      _$this._apiMajor = apiMajor;

  String? _storeUrl;
  String? get storeUrl => _$this._storeUrl;
  set storeUrl(String? storeUrl) => _$this._storeUrl = storeUrl;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  MinimumVersionBuilder() {
    MinimumVersion._defaults(this);
  }

  MinimumVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _app = $v.app;
      _platform = $v.platform;
      _minSupportedBuild = $v.minSupportedBuild;
      _apiMajor = $v.apiMajor;
      _storeUrl = $v.storeUrl;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MinimumVersion other) {
    _$v = other as _$MinimumVersion;
  }

  @override
  void update(void Function(MinimumVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MinimumVersion build() => _build();

  _$MinimumVersion _build() {
    final _$result = _$v ??
        _$MinimumVersion._(
          app: BuiltValueNullFieldError.checkNotNull(
              app, r'MinimumVersion', 'app'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'MinimumVersion', 'platform'),
          minSupportedBuild: BuiltValueNullFieldError.checkNotNull(
              minSupportedBuild, r'MinimumVersion', 'minSupportedBuild'),
          apiMajor: BuiltValueNullFieldError.checkNotNull(
              apiMajor, r'MinimumVersion', 'apiMajor'),
          storeUrl: BuiltValueNullFieldError.checkNotNull(
              storeUrl, r'MinimumVersion', 'storeUrl'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'MinimumVersion', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
