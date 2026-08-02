// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_manifest_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingManifestGet200Response extends BoardingManifestGet200Response {
  @override
  final String tripId;
  @override
  final BuiltList<BoardingManifestGet200ResponseRidersInner> riders;

  factory _$BoardingManifestGet200Response(
          [void Function(BoardingManifestGet200ResponseBuilder)? updates]) =>
      (BoardingManifestGet200ResponseBuilder()..update(updates))._build();

  _$BoardingManifestGet200Response._(
      {required this.tripId, required this.riders})
      : super._();
  @override
  BoardingManifestGet200Response rebuild(
          void Function(BoardingManifestGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingManifestGet200ResponseBuilder toBuilder() =>
      BoardingManifestGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingManifestGet200Response &&
        tripId == other.tripId &&
        riders == other.riders;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, riders.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingManifestGet200Response')
          ..add('tripId', tripId)
          ..add('riders', riders))
        .toString();
  }
}

class BoardingManifestGet200ResponseBuilder
    implements
        Builder<BoardingManifestGet200Response,
            BoardingManifestGet200ResponseBuilder> {
  _$BoardingManifestGet200Response? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  ListBuilder<BoardingManifestGet200ResponseRidersInner>? _riders;
  ListBuilder<BoardingManifestGet200ResponseRidersInner> get riders =>
      _$this._riders ??=
          ListBuilder<BoardingManifestGet200ResponseRidersInner>();
  set riders(ListBuilder<BoardingManifestGet200ResponseRidersInner>? riders) =>
      _$this._riders = riders;

  BoardingManifestGet200ResponseBuilder() {
    BoardingManifestGet200Response._defaults(this);
  }

  BoardingManifestGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _riders = $v.riders.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingManifestGet200Response other) {
    _$v = other as _$BoardingManifestGet200Response;
  }

  @override
  void update(void Function(BoardingManifestGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingManifestGet200Response build() => _build();

  _$BoardingManifestGet200Response _build() {
    _$BoardingManifestGet200Response _$result;
    try {
      _$result = _$v ??
          _$BoardingManifestGet200Response._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'BoardingManifestGet200Response', 'tripId'),
            riders: riders.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'riders';
        riders.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BoardingManifestGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
