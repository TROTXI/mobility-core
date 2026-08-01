// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MePatchRequest extends MePatchRequest {
  @override
  final String displayName;

  factory _$MePatchRequest([void Function(MePatchRequestBuilder)? updates]) =>
      (MePatchRequestBuilder()..update(updates))._build();

  _$MePatchRequest._({required this.displayName}) : super._();
  @override
  MePatchRequest rebuild(void Function(MePatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MePatchRequestBuilder toBuilder() => MePatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MePatchRequest && displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MePatchRequest')
          ..add('displayName', displayName))
        .toString();
  }
}

class MePatchRequestBuilder
    implements Builder<MePatchRequest, MePatchRequestBuilder> {
  _$MePatchRequest? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  MePatchRequestBuilder() {
    MePatchRequest._defaults(this);
  }

  MePatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MePatchRequest other) {
    _$v = other as _$MePatchRequest;
  }

  @override
  void update(void Function(MePatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MePatchRequest build() => _build();

  _$MePatchRequest _build() {
    final _$result = _$v ??
        _$MePatchRequest._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'MePatchRequest', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
