// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_initiation_collection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefundInitiationCollection extends RefundInitiationCollection {
  @override
  final BuiltList<RefundInitiation> items;

  factory _$RefundInitiationCollection(
          [void Function(RefundInitiationCollectionBuilder)? updates]) =>
      (RefundInitiationCollectionBuilder()..update(updates))._build();

  _$RefundInitiationCollection._({required this.items}) : super._();
  @override
  RefundInitiationCollection rebuild(
          void Function(RefundInitiationCollectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefundInitiationCollectionBuilder toBuilder() =>
      RefundInitiationCollectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefundInitiationCollection && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefundInitiationCollection')
          ..add('items', items))
        .toString();
  }
}

class RefundInitiationCollectionBuilder
    implements
        Builder<RefundInitiationCollection, RefundInitiationCollectionBuilder> {
  _$RefundInitiationCollection? _$v;

  ListBuilder<RefundInitiation>? _items;
  ListBuilder<RefundInitiation> get items =>
      _$this._items ??= ListBuilder<RefundInitiation>();
  set items(ListBuilder<RefundInitiation>? items) => _$this._items = items;

  RefundInitiationCollectionBuilder() {
    RefundInitiationCollection._defaults(this);
  }

  RefundInitiationCollectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefundInitiationCollection other) {
    _$v = other as _$RefundInitiationCollection;
  }

  @override
  void update(void Function(RefundInitiationCollectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefundInitiationCollection build() => _build();

  _$RefundInitiationCollection _build() {
    _$RefundInitiationCollection _$result;
    try {
      _$result = _$v ??
          _$RefundInitiationCollection._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefundInitiationCollection', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
