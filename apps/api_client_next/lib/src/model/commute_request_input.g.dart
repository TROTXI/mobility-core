// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_request_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteRequestInput extends CommuteRequestInput {
  @override
  final String routeId;
  @override
  final BuiltList<CommuteLeg> legs;
  @override
  final Date requestedDate;
  @override
  final bool pauseIfWaitlisted;
  @override
  final String? note;

  factory _$CommuteRequestInput(
          [void Function(CommuteRequestInputBuilder)? updates]) =>
      (CommuteRequestInputBuilder()..update(updates))._build();

  _$CommuteRequestInput._(
      {required this.routeId,
      required this.legs,
      required this.requestedDate,
      required this.pauseIfWaitlisted,
      this.note})
      : super._();
  @override
  CommuteRequestInput rebuild(
          void Function(CommuteRequestInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteRequestInputBuilder toBuilder() =>
      CommuteRequestInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteRequestInput &&
        routeId == other.routeId &&
        legs == other.legs &&
        requestedDate == other.requestedDate &&
        pauseIfWaitlisted == other.pauseIfWaitlisted &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jc(_$hash, requestedDate.hashCode);
    _$hash = $jc(_$hash, pauseIfWaitlisted.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteRequestInput')
          ..add('routeId', routeId)
          ..add('legs', legs)
          ..add('requestedDate', requestedDate)
          ..add('pauseIfWaitlisted', pauseIfWaitlisted)
          ..add('note', note))
        .toString();
  }
}

class CommuteRequestInputBuilder
    implements Builder<CommuteRequestInput, CommuteRequestInputBuilder> {
  _$CommuteRequestInput? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  ListBuilder<CommuteLeg>? _legs;
  ListBuilder<CommuteLeg> get legs =>
      _$this._legs ??= ListBuilder<CommuteLeg>();
  set legs(ListBuilder<CommuteLeg>? legs) => _$this._legs = legs;

  Date? _requestedDate;
  Date? get requestedDate => _$this._requestedDate;
  set requestedDate(Date? requestedDate) =>
      _$this._requestedDate = requestedDate;

  bool? _pauseIfWaitlisted;
  bool? get pauseIfWaitlisted => _$this._pauseIfWaitlisted;
  set pauseIfWaitlisted(bool? pauseIfWaitlisted) =>
      _$this._pauseIfWaitlisted = pauseIfWaitlisted;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteRequestInputBuilder() {
    CommuteRequestInput._defaults(this);
  }

  CommuteRequestInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _legs = $v.legs.toBuilder();
      _requestedDate = $v.requestedDate;
      _pauseIfWaitlisted = $v.pauseIfWaitlisted;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteRequestInput other) {
    _$v = other as _$CommuteRequestInput;
  }

  @override
  void update(void Function(CommuteRequestInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteRequestInput build() => _build();

  _$CommuteRequestInput _build() {
    _$CommuteRequestInput _$result;
    try {
      _$result = _$v ??
          _$CommuteRequestInput._(
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'CommuteRequestInput', 'routeId'),
            legs: legs.build(),
            requestedDate: BuiltValueNullFieldError.checkNotNull(
                requestedDate, r'CommuteRequestInput', 'requestedDate'),
            pauseIfWaitlisted: BuiltValueNullFieldError.checkNotNull(
                pauseIfWaitlisted, r'CommuteRequestInput', 'pauseIfWaitlisted'),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteRequestInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
