// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_access.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MembershipAccess extends MembershipAccess {
  @override
  final bool canReserve;
  @override
  final BuiltList<AccessBlock> blocks;

  factory _$MembershipAccess(
          [void Function(MembershipAccessBuilder)? updates]) =>
      (MembershipAccessBuilder()..update(updates))._build();

  _$MembershipAccess._({required this.canReserve, required this.blocks})
      : super._();
  @override
  MembershipAccess rebuild(void Function(MembershipAccessBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipAccessBuilder toBuilder() =>
      MembershipAccessBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipAccess &&
        canReserve == other.canReserve &&
        blocks == other.blocks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, canReserve.hashCode);
    _$hash = $jc(_$hash, blocks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipAccess')
          ..add('canReserve', canReserve)
          ..add('blocks', blocks))
        .toString();
  }
}

class MembershipAccessBuilder
    implements Builder<MembershipAccess, MembershipAccessBuilder> {
  _$MembershipAccess? _$v;

  bool? _canReserve;
  bool? get canReserve => _$this._canReserve;
  set canReserve(bool? canReserve) => _$this._canReserve = canReserve;

  ListBuilder<AccessBlock>? _blocks;
  ListBuilder<AccessBlock> get blocks =>
      _$this._blocks ??= ListBuilder<AccessBlock>();
  set blocks(ListBuilder<AccessBlock>? blocks) => _$this._blocks = blocks;

  MembershipAccessBuilder() {
    MembershipAccess._defaults(this);
  }

  MembershipAccessBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _canReserve = $v.canReserve;
      _blocks = $v.blocks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipAccess other) {
    _$v = other as _$MembershipAccess;
  }

  @override
  void update(void Function(MembershipAccessBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipAccess build() => _build();

  _$MembershipAccess _build() {
    _$MembershipAccess _$result;
    try {
      _$result = _$v ??
          _$MembershipAccess._(
            canReserve: BuiltValueNullFieldError.checkNotNull(
                canReserve, r'MembershipAccess', 'canReserve'),
            blocks: blocks.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'blocks';
        blocks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MembershipAccess', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
