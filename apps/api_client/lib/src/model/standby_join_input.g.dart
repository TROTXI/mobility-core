// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_join_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyJoinInput extends StandbyJoinInput {
  @override
  final PurchaseInput selection;
  @override
  final BuiltList<int> travelDays;

  factory _$StandbyJoinInput(
          [void Function(StandbyJoinInputBuilder)? updates]) =>
      (StandbyJoinInputBuilder()..update(updates))._build();

  _$StandbyJoinInput._({required this.selection, required this.travelDays})
      : super._();
  @override
  StandbyJoinInput rebuild(void Function(StandbyJoinInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyJoinInputBuilder toBuilder() =>
      StandbyJoinInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyJoinInput &&
        selection == other.selection &&
        travelDays == other.travelDays;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, selection.hashCode);
    _$hash = $jc(_$hash, travelDays.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyJoinInput')
          ..add('selection', selection)
          ..add('travelDays', travelDays))
        .toString();
  }
}

class StandbyJoinInputBuilder
    implements Builder<StandbyJoinInput, StandbyJoinInputBuilder> {
  _$StandbyJoinInput? _$v;

  PurchaseInputBuilder? _selection;
  PurchaseInputBuilder get selection =>
      _$this._selection ??= PurchaseInputBuilder();
  set selection(PurchaseInputBuilder? selection) =>
      _$this._selection = selection;

  ListBuilder<int>? _travelDays;
  ListBuilder<int> get travelDays => _$this._travelDays ??= ListBuilder<int>();
  set travelDays(ListBuilder<int>? travelDays) =>
      _$this._travelDays = travelDays;

  StandbyJoinInputBuilder() {
    StandbyJoinInput._defaults(this);
  }

  StandbyJoinInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _selection = $v.selection.toBuilder();
      _travelDays = $v.travelDays.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyJoinInput other) {
    _$v = other as _$StandbyJoinInput;
  }

  @override
  void update(void Function(StandbyJoinInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyJoinInput build() => _build();

  _$StandbyJoinInput _build() {
    _$StandbyJoinInput _$result;
    try {
      _$result = _$v ??
          _$StandbyJoinInput._(
            selection: selection.build(),
            travelDays: travelDays.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'selection';
        selection.build();
        _$failedField = 'travelDays';
        travelDays.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandbyJoinInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
