// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_applications_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BootstrapApplicationsInnerAppEnum
    _$bootstrapApplicationsInnerAppEnum_commuter =
    const BootstrapApplicationsInnerAppEnum._('commuter');
const BootstrapApplicationsInnerAppEnum
    _$bootstrapApplicationsInnerAppEnum_driver =
    const BootstrapApplicationsInnerAppEnum._('driver');

BootstrapApplicationsInnerAppEnum _$bootstrapApplicationsInnerAppEnumValueOf(
    String name) {
  switch (name) {
    case 'commuter':
      return _$bootstrapApplicationsInnerAppEnum_commuter;
    case 'driver':
      return _$bootstrapApplicationsInnerAppEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BootstrapApplicationsInnerAppEnum>
    _$bootstrapApplicationsInnerAppEnumValues = BuiltSet<
        BootstrapApplicationsInnerAppEnum>(const <BootstrapApplicationsInnerAppEnum>[
  _$bootstrapApplicationsInnerAppEnum_commuter,
  _$bootstrapApplicationsInnerAppEnum_driver,
]);

const BootstrapApplicationsInnerPlatformEnum
    _$bootstrapApplicationsInnerPlatformEnum_ios =
    const BootstrapApplicationsInnerPlatformEnum._('ios');
const BootstrapApplicationsInnerPlatformEnum
    _$bootstrapApplicationsInnerPlatformEnum_android =
    const BootstrapApplicationsInnerPlatformEnum._('android');

BootstrapApplicationsInnerPlatformEnum
    _$bootstrapApplicationsInnerPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$bootstrapApplicationsInnerPlatformEnum_ios;
    case 'android':
      return _$bootstrapApplicationsInnerPlatformEnum_android;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BootstrapApplicationsInnerPlatformEnum>
    _$bootstrapApplicationsInnerPlatformEnumValues = BuiltSet<
        BootstrapApplicationsInnerPlatformEnum>(const <BootstrapApplicationsInnerPlatformEnum>[
  _$bootstrapApplicationsInnerPlatformEnum_ios,
  _$bootstrapApplicationsInnerPlatformEnum_android,
]);

const BootstrapApplicationsInnerApiMajorEnum
    _$bootstrapApplicationsInnerApiMajorEnum_number1 =
    const BootstrapApplicationsInnerApiMajorEnum._('number1');

BootstrapApplicationsInnerApiMajorEnum
    _$bootstrapApplicationsInnerApiMajorEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$bootstrapApplicationsInnerApiMajorEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BootstrapApplicationsInnerApiMajorEnum>
    _$bootstrapApplicationsInnerApiMajorEnumValues = BuiltSet<
        BootstrapApplicationsInnerApiMajorEnum>(const <BootstrapApplicationsInnerApiMajorEnum>[
  _$bootstrapApplicationsInnerApiMajorEnum_number1,
]);

Serializer<BootstrapApplicationsInnerAppEnum>
    _$bootstrapApplicationsInnerAppEnumSerializer =
    _$BootstrapApplicationsInnerAppEnumSerializer();
Serializer<BootstrapApplicationsInnerPlatformEnum>
    _$bootstrapApplicationsInnerPlatformEnumSerializer =
    _$BootstrapApplicationsInnerPlatformEnumSerializer();
Serializer<BootstrapApplicationsInnerApiMajorEnum>
    _$bootstrapApplicationsInnerApiMajorEnumSerializer =
    _$BootstrapApplicationsInnerApiMajorEnumSerializer();

class _$BootstrapApplicationsInnerAppEnumSerializer
    implements PrimitiveSerializer<BootstrapApplicationsInnerAppEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'commuter': 'commuter',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'commuter': 'commuter',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[BootstrapApplicationsInnerAppEnum];
  @override
  final String wireName = 'BootstrapApplicationsInnerAppEnum';

  @override
  Object serialize(
          Serializers serializers, BootstrapApplicationsInnerAppEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BootstrapApplicationsInnerAppEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BootstrapApplicationsInnerAppEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BootstrapApplicationsInnerPlatformEnumSerializer
    implements PrimitiveSerializer<BootstrapApplicationsInnerPlatformEnum> {
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
    BootstrapApplicationsInnerPlatformEnum
  ];
  @override
  final String wireName = 'BootstrapApplicationsInnerPlatformEnum';

  @override
  Object serialize(Serializers serializers,
          BootstrapApplicationsInnerPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BootstrapApplicationsInnerPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BootstrapApplicationsInnerPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BootstrapApplicationsInnerApiMajorEnumSerializer
    implements PrimitiveSerializer<BootstrapApplicationsInnerApiMajorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BootstrapApplicationsInnerApiMajorEnum
  ];
  @override
  final String wireName = 'BootstrapApplicationsInnerApiMajorEnum';

  @override
  Object serialize(Serializers serializers,
          BootstrapApplicationsInnerApiMajorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BootstrapApplicationsInnerApiMajorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BootstrapApplicationsInnerApiMajorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BootstrapApplicationsInner extends BootstrapApplicationsInner {
  @override
  final BootstrapApplicationsInnerAppEnum app;
  @override
  final BootstrapApplicationsInnerPlatformEnum platform;
  @override
  final int minSupportedBuild;
  @override
  final String? storeUrl;
  @override
  final BootstrapApplicationsInnerApiMajorEnum apiMajor;

  factory _$BootstrapApplicationsInner(
          [void Function(BootstrapApplicationsInnerBuilder)? updates]) =>
      (BootstrapApplicationsInnerBuilder()..update(updates))._build();

  _$BootstrapApplicationsInner._(
      {required this.app,
      required this.platform,
      required this.minSupportedBuild,
      this.storeUrl,
      required this.apiMajor})
      : super._();
  @override
  BootstrapApplicationsInner rebuild(
          void Function(BootstrapApplicationsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapApplicationsInnerBuilder toBuilder() =>
      BootstrapApplicationsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapApplicationsInner &&
        app == other.app &&
        platform == other.platform &&
        minSupportedBuild == other.minSupportedBuild &&
        storeUrl == other.storeUrl &&
        apiMajor == other.apiMajor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, app.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, minSupportedBuild.hashCode);
    _$hash = $jc(_$hash, storeUrl.hashCode);
    _$hash = $jc(_$hash, apiMajor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrapApplicationsInner')
          ..add('app', app)
          ..add('platform', platform)
          ..add('minSupportedBuild', minSupportedBuild)
          ..add('storeUrl', storeUrl)
          ..add('apiMajor', apiMajor))
        .toString();
  }
}

class BootstrapApplicationsInnerBuilder
    implements
        Builder<BootstrapApplicationsInner, BootstrapApplicationsInnerBuilder> {
  _$BootstrapApplicationsInner? _$v;

  BootstrapApplicationsInnerAppEnum? _app;
  BootstrapApplicationsInnerAppEnum? get app => _$this._app;
  set app(BootstrapApplicationsInnerAppEnum? app) => _$this._app = app;

  BootstrapApplicationsInnerPlatformEnum? _platform;
  BootstrapApplicationsInnerPlatformEnum? get platform => _$this._platform;
  set platform(BootstrapApplicationsInnerPlatformEnum? platform) =>
      _$this._platform = platform;

  int? _minSupportedBuild;
  int? get minSupportedBuild => _$this._minSupportedBuild;
  set minSupportedBuild(int? minSupportedBuild) =>
      _$this._minSupportedBuild = minSupportedBuild;

  String? _storeUrl;
  String? get storeUrl => _$this._storeUrl;
  set storeUrl(String? storeUrl) => _$this._storeUrl = storeUrl;

  BootstrapApplicationsInnerApiMajorEnum? _apiMajor;
  BootstrapApplicationsInnerApiMajorEnum? get apiMajor => _$this._apiMajor;
  set apiMajor(BootstrapApplicationsInnerApiMajorEnum? apiMajor) =>
      _$this._apiMajor = apiMajor;

  BootstrapApplicationsInnerBuilder() {
    BootstrapApplicationsInner._defaults(this);
  }

  BootstrapApplicationsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _app = $v.app;
      _platform = $v.platform;
      _minSupportedBuild = $v.minSupportedBuild;
      _storeUrl = $v.storeUrl;
      _apiMajor = $v.apiMajor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapApplicationsInner other) {
    _$v = other as _$BootstrapApplicationsInner;
  }

  @override
  void update(void Function(BootstrapApplicationsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapApplicationsInner build() => _build();

  _$BootstrapApplicationsInner _build() {
    final _$result = _$v ??
        _$BootstrapApplicationsInner._(
          app: BuiltValueNullFieldError.checkNotNull(
              app, r'BootstrapApplicationsInner', 'app'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'BootstrapApplicationsInner', 'platform'),
          minSupportedBuild: BuiltValueNullFieldError.checkNotNull(
              minSupportedBuild,
              r'BootstrapApplicationsInner',
              'minSupportedBuild'),
          storeUrl: storeUrl,
          apiMajor: BuiltValueNullFieldError.checkNotNull(
              apiMajor, r'BootstrapApplicationsInner', 'apiMajor'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
