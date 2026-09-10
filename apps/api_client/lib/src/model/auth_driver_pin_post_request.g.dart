// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_driver_pin_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthDriverPinPostRequest extends AuthDriverPinPostRequest {
  @override
  final String currentPin;
  @override
  final String newPin;

  factory _$AuthDriverPinPostRequest(
          [void Function(AuthDriverPinPostRequestBuilder)? updates]) =>
      (AuthDriverPinPostRequestBuilder()..update(updates))._build();

  _$AuthDriverPinPostRequest._({required this.currentPin, required this.newPin})
      : super._();
  @override
  AuthDriverPinPostRequest rebuild(
          void Function(AuthDriverPinPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthDriverPinPostRequestBuilder toBuilder() =>
      AuthDriverPinPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthDriverPinPostRequest &&
        currentPin == other.currentPin &&
        newPin == other.newPin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPin.hashCode);
    _$hash = $jc(_$hash, newPin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthDriverPinPostRequest')
          ..add('currentPin', currentPin)
          ..add('newPin', newPin))
        .toString();
  }
}

class AuthDriverPinPostRequestBuilder
    implements
        Builder<AuthDriverPinPostRequest, AuthDriverPinPostRequestBuilder> {
  _$AuthDriverPinPostRequest? _$v;

  String? _currentPin;
  String? get currentPin => _$this._currentPin;
  set currentPin(String? currentPin) => _$this._currentPin = currentPin;

  String? _newPin;
  String? get newPin => _$this._newPin;
  set newPin(String? newPin) => _$this._newPin = newPin;

  AuthDriverPinPostRequestBuilder() {
    AuthDriverPinPostRequest._defaults(this);
  }

  AuthDriverPinPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPin = $v.currentPin;
      _newPin = $v.newPin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthDriverPinPostRequest other) {
    _$v = other as _$AuthDriverPinPostRequest;
  }

  @override
  void update(void Function(AuthDriverPinPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthDriverPinPostRequest build() => _build();

  _$AuthDriverPinPostRequest _build() {
    final _$result = _$v ??
        _$AuthDriverPinPostRequest._(
          currentPin: BuiltValueNullFieldError.checkNotNull(
              currentPin, r'AuthDriverPinPostRequest', 'currentPin'),
          newPin: BuiltValueNullFieldError.checkNotNull(
              newPin, r'AuthDriverPinPostRequest', 'newPin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
