// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_command_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperatorCommandResult extends OperatorCommandResult {
  @override
  final String id;

  factory _$OperatorCommandResult(
          [void Function(OperatorCommandResultBuilder)? updates]) =>
      (OperatorCommandResultBuilder()..update(updates))._build();

  _$OperatorCommandResult._({required this.id}) : super._();
  @override
  OperatorCommandResult rebuild(
          void Function(OperatorCommandResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperatorCommandResultBuilder toBuilder() =>
      OperatorCommandResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperatorCommandResult && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OperatorCommandResult')
          ..add('id', id))
        .toString();
  }
}

class OperatorCommandResultBuilder
    implements Builder<OperatorCommandResult, OperatorCommandResultBuilder> {
  _$OperatorCommandResult? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OperatorCommandResultBuilder() {
    OperatorCommandResult._defaults(this);
  }

  OperatorCommandResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperatorCommandResult other) {
    _$v = other as _$OperatorCommandResult;
  }

  @override
  void update(void Function(OperatorCommandResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperatorCommandResult build() => _build();

  _$OperatorCommandResult _build() {
    final _$result = _$v ??
        _$OperatorCommandResult._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OperatorCommandResult', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
