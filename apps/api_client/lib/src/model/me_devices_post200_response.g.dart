// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_devices_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeDevicesPost200Response extends MeDevicesPost200Response {
  @override
  final bool registered;

  factory _$MeDevicesPost200Response(
          [void Function(MeDevicesPost200ResponseBuilder)? updates]) =>
      (MeDevicesPost200ResponseBuilder()..update(updates))._build();

  _$MeDevicesPost200Response._({required this.registered}) : super._();
  @override
  MeDevicesPost200Response rebuild(
          void Function(MeDevicesPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeDevicesPost200ResponseBuilder toBuilder() =>
      MeDevicesPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeDevicesPost200Response && registered == other.registered;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registered.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeDevicesPost200Response')
          ..add('registered', registered))
        .toString();
  }
}

class MeDevicesPost200ResponseBuilder
    implements
        Builder<MeDevicesPost200Response, MeDevicesPost200ResponseBuilder> {
  _$MeDevicesPost200Response? _$v;

  bool? _registered;
  bool? get registered => _$this._registered;
  set registered(bool? registered) => _$this._registered = registered;

  MeDevicesPost200ResponseBuilder() {
    MeDevicesPost200Response._defaults(this);
  }

  MeDevicesPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registered = $v.registered;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeDevicesPost200Response other) {
    _$v = other as _$MeDevicesPost200Response;
  }

  @override
  void update(void Function(MeDevicesPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeDevicesPost200Response build() => _build();

  _$MeDevicesPost200Response _build() {
    final _$result = _$v ??
        _$MeDevicesPost200Response._(
          registered: BuiltValueNullFieldError.checkNotNull(
              registered, r'MeDevicesPost200Response', 'registered'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
