// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingResultResponse extends BoardingResultResponse {
  @override
  final BoardingResult data;

  factory _$BoardingResultResponse(
          [void Function(BoardingResultResponseBuilder)? updates]) =>
      (BoardingResultResponseBuilder()..update(updates))._build();

  _$BoardingResultResponse._({required this.data}) : super._();
  @override
  BoardingResultResponse rebuild(
          void Function(BoardingResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingResultResponseBuilder toBuilder() =>
      BoardingResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingResultResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingResultResponse')
          ..add('data', data))
        .toString();
  }
}

class BoardingResultResponseBuilder
    implements Builder<BoardingResultResponse, BoardingResultResponseBuilder> {
  _$BoardingResultResponse? _$v;

  BoardingResultBuilder? _data;
  BoardingResultBuilder get data => _$this._data ??= BoardingResultBuilder();
  set data(BoardingResultBuilder? data) => _$this._data = data;

  BoardingResultResponseBuilder() {
    BoardingResultResponse._defaults(this);
  }

  BoardingResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingResultResponse other) {
    _$v = other as _$BoardingResultResponse;
  }

  @override
  void update(void Function(BoardingResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingResultResponse build() => _build();

  _$BoardingResultResponse _build() {
    _$BoardingResultResponse _$result;
    try {
      _$result = _$v ??
          _$BoardingResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BoardingResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
