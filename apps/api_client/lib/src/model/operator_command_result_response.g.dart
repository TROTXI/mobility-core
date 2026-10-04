// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_command_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperatorCommandResultResponse extends OperatorCommandResultResponse {
  @override
  final OperatorCommandResult data;

  factory _$OperatorCommandResultResponse(
          [void Function(OperatorCommandResultResponseBuilder)? updates]) =>
      (OperatorCommandResultResponseBuilder()..update(updates))._build();

  _$OperatorCommandResultResponse._({required this.data}) : super._();
  @override
  OperatorCommandResultResponse rebuild(
          void Function(OperatorCommandResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperatorCommandResultResponseBuilder toBuilder() =>
      OperatorCommandResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperatorCommandResultResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OperatorCommandResultResponse')
          ..add('data', data))
        .toString();
  }
}

class OperatorCommandResultResponseBuilder
    implements
        Builder<OperatorCommandResultResponse,
            OperatorCommandResultResponseBuilder> {
  _$OperatorCommandResultResponse? _$v;

  OperatorCommandResultBuilder? _data;
  OperatorCommandResultBuilder get data =>
      _$this._data ??= OperatorCommandResultBuilder();
  set data(OperatorCommandResultBuilder? data) => _$this._data = data;

  OperatorCommandResultResponseBuilder() {
    OperatorCommandResultResponse._defaults(this);
  }

  OperatorCommandResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperatorCommandResultResponse other) {
    _$v = other as _$OperatorCommandResultResponse;
  }

  @override
  void update(void Function(OperatorCommandResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperatorCommandResultResponse build() => _build();

  _$OperatorCommandResultResponse _build() {
    _$OperatorCommandResultResponse _$result;
    try {
      _$result = _$v ??
          _$OperatorCommandResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OperatorCommandResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
