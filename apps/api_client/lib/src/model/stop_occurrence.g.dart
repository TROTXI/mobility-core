// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_occurrence.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StopOccurrence extends StopOccurrence {
  @override
  final String id;
  @override
  final String stopId;
  @override
  final int ordinal;
  @override
  final String name;
  @override
  final Point location;

  factory _$StopOccurrence([void Function(StopOccurrenceBuilder)? updates]) =>
      (StopOccurrenceBuilder()..update(updates))._build();

  _$StopOccurrence._(
      {required this.id,
      required this.stopId,
      required this.ordinal,
      required this.name,
      required this.location})
      : super._();
  @override
  StopOccurrence rebuild(void Function(StopOccurrenceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopOccurrenceBuilder toBuilder() => StopOccurrenceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopOccurrence &&
        id == other.id &&
        stopId == other.stopId &&
        ordinal == other.ordinal &&
        name == other.name &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, stopId.hashCode);
    _$hash = $jc(_$hash, ordinal.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StopOccurrence')
          ..add('id', id)
          ..add('stopId', stopId)
          ..add('ordinal', ordinal)
          ..add('name', name)
          ..add('location', location))
        .toString();
  }
}

class StopOccurrenceBuilder
    implements Builder<StopOccurrence, StopOccurrenceBuilder> {
  _$StopOccurrence? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _stopId;
  String? get stopId => _$this._stopId;
  set stopId(String? stopId) => _$this._stopId = stopId;

  int? _ordinal;
  int? get ordinal => _$this._ordinal;
  set ordinal(int? ordinal) => _$this._ordinal = ordinal;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  StopOccurrenceBuilder() {
    StopOccurrence._defaults(this);
  }

  StopOccurrenceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _stopId = $v.stopId;
      _ordinal = $v.ordinal;
      _name = $v.name;
      _location = $v.location.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopOccurrence other) {
    _$v = other as _$StopOccurrence;
  }

  @override
  void update(void Function(StopOccurrenceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopOccurrence build() => _build();

  _$StopOccurrence _build() {
    _$StopOccurrence _$result;
    try {
      _$result = _$v ??
          _$StopOccurrence._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'StopOccurrence', 'id'),
            stopId: BuiltValueNullFieldError.checkNotNull(
                stopId, r'StopOccurrence', 'stopId'),
            ordinal: BuiltValueNullFieldError.checkNotNull(
                ordinal, r'StopOccurrence', 'ordinal'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'StopOccurrence', 'name'),
            location: location.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StopOccurrence', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
