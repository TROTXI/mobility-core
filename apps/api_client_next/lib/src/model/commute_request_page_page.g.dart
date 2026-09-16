// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_request_page_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteRequestPagePage extends CommuteRequestPagePage {
  @override
  final String? nextCursor;

  factory _$CommuteRequestPagePage(
          [void Function(CommuteRequestPagePageBuilder)? updates]) =>
      (CommuteRequestPagePageBuilder()..update(updates))._build();

  _$CommuteRequestPagePage._({this.nextCursor}) : super._();
  @override
  CommuteRequestPagePage rebuild(
          void Function(CommuteRequestPagePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteRequestPagePageBuilder toBuilder() =>
      CommuteRequestPagePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteRequestPagePage && nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteRequestPagePage')
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class CommuteRequestPagePageBuilder
    implements Builder<CommuteRequestPagePage, CommuteRequestPagePageBuilder> {
  _$CommuteRequestPagePage? _$v;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  CommuteRequestPagePageBuilder() {
    CommuteRequestPagePage._defaults(this);
  }

  CommuteRequestPagePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteRequestPagePage other) {
    _$v = other as _$CommuteRequestPagePage;
  }

  @override
  void update(void Function(CommuteRequestPagePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteRequestPagePage build() => _build();

  _$CommuteRequestPagePage _build() {
    final _$result = _$v ??
        _$CommuteRequestPagePage._(
          nextCursor: nextCursor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
