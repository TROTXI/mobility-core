// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_scan_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingScanPostRequest extends BoardingScanPostRequest {
  @override
  final String pass;
  @override
  final String? tripId;

  factory _$BoardingScanPostRequest(
          [void Function(BoardingScanPostRequestBuilder)? updates]) =>
      (BoardingScanPostRequestBuilder()..update(updates))._build();

  _$BoardingScanPostRequest._({required this.pass, this.tripId}) : super._();
  @override
  BoardingScanPostRequest rebuild(
          void Function(BoardingScanPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingScanPostRequestBuilder toBuilder() =>
      BoardingScanPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingScanPostRequest &&
        pass == other.pass &&
        tripId == other.tripId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pass.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingScanPostRequest')
          ..add('pass', pass)
          ..add('tripId', tripId))
        .toString();
  }
}

class BoardingScanPostRequestBuilder
    implements
        Builder<BoardingScanPostRequest, BoardingScanPostRequestBuilder> {
  _$BoardingScanPostRequest? _$v;

  String? _pass;
  String? get pass => _$this._pass;
  set pass(String? pass) => _$this._pass = pass;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  BoardingScanPostRequestBuilder() {
    BoardingScanPostRequest._defaults(this);
  }

  BoardingScanPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pass = $v.pass;
      _tripId = $v.tripId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingScanPostRequest other) {
    _$v = other as _$BoardingScanPostRequest;
  }

  @override
  void update(void Function(BoardingScanPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingScanPostRequest build() => _build();

  _$BoardingScanPostRequest _build() {
    final _$result = _$v ??
        _$BoardingScanPostRequest._(
          pass: BuiltValueNullFieldError.checkNotNull(
              pass, r'BoardingScanPostRequest', 'pass'),
          tripId: tripId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
