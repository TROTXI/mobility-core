// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Root extends Root {
  @override
  final String docs;
  @override
  final String health;

  factory _$Root([void Function(RootBuilder)? updates]) =>
      (RootBuilder()..update(updates))._build();

  _$Root._({required this.docs, required this.health}) : super._();
  @override
  Root rebuild(void Function(RootBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RootBuilder toBuilder() => RootBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Root && docs == other.docs && health == other.health;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, docs.hashCode);
    _$hash = $jc(_$hash, health.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Root')
          ..add('docs', docs)
          ..add('health', health))
        .toString();
  }
}

class RootBuilder implements Builder<Root, RootBuilder> {
  _$Root? _$v;

  String? _docs;
  String? get docs => _$this._docs;
  set docs(String? docs) => _$this._docs = docs;

  String? _health;
  String? get health => _$this._health;
  set health(String? health) => _$this._health = health;

  RootBuilder() {
    Root._defaults(this);
  }

  RootBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _docs = $v.docs;
      _health = $v.health;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Root other) {
    _$v = other as _$Root;
  }

  @override
  void update(void Function(RootBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Root build() => _build();

  _$Root _build() {
    final _$result = _$v ??
        _$Root._(
          docs: BuiltValueNullFieldError.checkNotNull(docs, r'Root', 'docs'),
          health:
              BuiltValueNullFieldError.checkNotNull(health, r'Root', 'health'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
