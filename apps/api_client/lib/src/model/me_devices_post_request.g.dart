// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_devices_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeDevicesPostRequestPlatformEnum
    _$meDevicesPostRequestPlatformEnum_android =
    const MeDevicesPostRequestPlatformEnum._('android');
const MeDevicesPostRequestPlatformEnum _$meDevicesPostRequestPlatformEnum_ios =
    const MeDevicesPostRequestPlatformEnum._('ios');
const MeDevicesPostRequestPlatformEnum _$meDevicesPostRequestPlatformEnum_web =
    const MeDevicesPostRequestPlatformEnum._('web');

MeDevicesPostRequestPlatformEnum _$meDevicesPostRequestPlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'android':
      return _$meDevicesPostRequestPlatformEnum_android;
    case 'ios':
      return _$meDevicesPostRequestPlatformEnum_ios;
    case 'web':
      return _$meDevicesPostRequestPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeDevicesPostRequestPlatformEnum>
    _$meDevicesPostRequestPlatformEnumValues = BuiltSet<
        MeDevicesPostRequestPlatformEnum>(const <MeDevicesPostRequestPlatformEnum>[
  _$meDevicesPostRequestPlatformEnum_android,
  _$meDevicesPostRequestPlatformEnum_ios,
  _$meDevicesPostRequestPlatformEnum_web,
]);

Serializer<MeDevicesPostRequestPlatformEnum>
    _$meDevicesPostRequestPlatformEnumSerializer =
    _$MeDevicesPostRequestPlatformEnumSerializer();

class _$MeDevicesPostRequestPlatformEnumSerializer
    implements PrimitiveSerializer<MeDevicesPostRequestPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[MeDevicesPostRequestPlatformEnum];
  @override
  final String wireName = 'MeDevicesPostRequestPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, MeDevicesPostRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeDevicesPostRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeDevicesPostRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeDevicesPostRequest extends MeDevicesPostRequest {
  @override
  final String fcmToken;
  @override
  final MeDevicesPostRequestPlatformEnum platform;

  factory _$MeDevicesPostRequest(
          [void Function(MeDevicesPostRequestBuilder)? updates]) =>
      (MeDevicesPostRequestBuilder()..update(updates))._build();

  _$MeDevicesPostRequest._({required this.fcmToken, required this.platform})
      : super._();
  @override
  MeDevicesPostRequest rebuild(
          void Function(MeDevicesPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeDevicesPostRequestBuilder toBuilder() =>
      MeDevicesPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeDevicesPostRequest &&
        fcmToken == other.fcmToken &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fcmToken.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeDevicesPostRequest')
          ..add('fcmToken', fcmToken)
          ..add('platform', platform))
        .toString();
  }
}

class MeDevicesPostRequestBuilder
    implements Builder<MeDevicesPostRequest, MeDevicesPostRequestBuilder> {
  _$MeDevicesPostRequest? _$v;

  String? _fcmToken;
  String? get fcmToken => _$this._fcmToken;
  set fcmToken(String? fcmToken) => _$this._fcmToken = fcmToken;

  MeDevicesPostRequestPlatformEnum? _platform;
  MeDevicesPostRequestPlatformEnum? get platform => _$this._platform;
  set platform(MeDevicesPostRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  MeDevicesPostRequestBuilder() {
    MeDevicesPostRequest._defaults(this);
  }

  MeDevicesPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fcmToken = $v.fcmToken;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeDevicesPostRequest other) {
    _$v = other as _$MeDevicesPostRequest;
  }

  @override
  void update(void Function(MeDevicesPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeDevicesPostRequest build() => _build();

  _$MeDevicesPostRequest _build() {
    final _$result = _$v ??
        _$MeDevicesPostRequest._(
          fcmToken: BuiltValueNullFieldError.checkNotNull(
              fcmToken, r'MeDevicesPostRequest', 'fcmToken'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'MeDevicesPostRequest', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
