// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_initiation_collection_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefundInitiationCollectionResponse
    extends RefundInitiationCollectionResponse {
  @override
  final RefundInitiationCollection data;

  factory _$RefundInitiationCollectionResponse(
          [void Function(RefundInitiationCollectionResponseBuilder)?
              updates]) =>
      (RefundInitiationCollectionResponseBuilder()..update(updates))._build();

  _$RefundInitiationCollectionResponse._({required this.data}) : super._();
  @override
  RefundInitiationCollectionResponse rebuild(
          void Function(RefundInitiationCollectionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefundInitiationCollectionResponseBuilder toBuilder() =>
      RefundInitiationCollectionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefundInitiationCollectionResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RefundInitiationCollectionResponse')
          ..add('data', data))
        .toString();
  }
}

class RefundInitiationCollectionResponseBuilder
    implements
        Builder<RefundInitiationCollectionResponse,
            RefundInitiationCollectionResponseBuilder> {
  _$RefundInitiationCollectionResponse? _$v;

  RefundInitiationCollectionBuilder? _data;
  RefundInitiationCollectionBuilder get data =>
      _$this._data ??= RefundInitiationCollectionBuilder();
  set data(RefundInitiationCollectionBuilder? data) => _$this._data = data;

  RefundInitiationCollectionResponseBuilder() {
    RefundInitiationCollectionResponse._defaults(this);
  }

  RefundInitiationCollectionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefundInitiationCollectionResponse other) {
    _$v = other as _$RefundInitiationCollectionResponse;
  }

  @override
  void update(
      void Function(RefundInitiationCollectionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefundInitiationCollectionResponse build() => _build();

  _$RefundInitiationCollectionResponse _build() {
    _$RefundInitiationCollectionResponse _$result;
    try {
      _$result = _$v ??
          _$RefundInitiationCollectionResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefundInitiationCollectionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
