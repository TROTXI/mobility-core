// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_leg_view.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteLegViewDirectionEnum _$commuteLegViewDirectionEnum_outbound =
    const CommuteLegViewDirectionEnum._('outbound');
const CommuteLegViewDirectionEnum _$commuteLegViewDirectionEnum_return_ =
    const CommuteLegViewDirectionEnum._('return_');

CommuteLegViewDirectionEnum _$commuteLegViewDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$commuteLegViewDirectionEnum_outbound;
    case 'return_':
      return _$commuteLegViewDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteLegViewDirectionEnum>
    _$commuteLegViewDirectionEnumValues =
    BuiltSet<CommuteLegViewDirectionEnum>(const <CommuteLegViewDirectionEnum>[
  _$commuteLegViewDirectionEnum_outbound,
  _$commuteLegViewDirectionEnum_return_,
]);

const CommuteLegViewTimeZoneEnum _$commuteLegViewTimeZoneEnum_africaSlashAccra =
    const CommuteLegViewTimeZoneEnum._('africaSlashAccra');

CommuteLegViewTimeZoneEnum _$commuteLegViewTimeZoneEnumValueOf(String name) {
  switch (name) {
    case 'africaSlashAccra':
      return _$commuteLegViewTimeZoneEnum_africaSlashAccra;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteLegViewTimeZoneEnum> _$commuteLegViewTimeZoneEnumValues =
    BuiltSet<CommuteLegViewTimeZoneEnum>(const <CommuteLegViewTimeZoneEnum>[
  _$commuteLegViewTimeZoneEnum_africaSlashAccra,
]);

Serializer<CommuteLegViewDirectionEnum>
    _$commuteLegViewDirectionEnumSerializer =
    _$CommuteLegViewDirectionEnumSerializer();
Serializer<CommuteLegViewTimeZoneEnum> _$commuteLegViewTimeZoneEnumSerializer =
    _$CommuteLegViewTimeZoneEnumSerializer();

class _$CommuteLegViewDirectionEnumSerializer
    implements PrimitiveSerializer<CommuteLegViewDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteLegViewDirectionEnum];
  @override
  final String wireName = 'CommuteLegViewDirectionEnum';

  @override
  Object serialize(Serializers serializers, CommuteLegViewDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteLegViewDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteLegViewDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteLegViewTimeZoneEnumSerializer
    implements PrimitiveSerializer<CommuteLegViewTimeZoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'africaSlashAccra': 'Africa/Accra',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Africa/Accra': 'africaSlashAccra',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteLegViewTimeZoneEnum];
  @override
  final String wireName = 'CommuteLegViewTimeZoneEnum';

  @override
  Object serialize(Serializers serializers, CommuteLegViewTimeZoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteLegViewTimeZoneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteLegViewTimeZoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteLegView extends CommuteLegView {
  @override
  final CommuteLegViewDirectionEnum direction;
  @override
  final String scheduleId;
  @override
  final String patternVersionId;
  @override
  final String pickupOccurrenceId;
  @override
  final String dropoffOccurrenceId;
  @override
  final String localDeparture;
  @override
  final CommuteLegViewTimeZoneEnum timeZone;
  @override
  final String pickupName;
  @override
  final String dropoffName;

  factory _$CommuteLegView([void Function(CommuteLegViewBuilder)? updates]) =>
      (CommuteLegViewBuilder()..update(updates))._build();

  _$CommuteLegView._(
      {required this.direction,
      required this.scheduleId,
      required this.patternVersionId,
      required this.pickupOccurrenceId,
      required this.dropoffOccurrenceId,
      required this.localDeparture,
      required this.timeZone,
      required this.pickupName,
      required this.dropoffName})
      : super._();
  @override
  CommuteLegView rebuild(void Function(CommuteLegViewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteLegViewBuilder toBuilder() => CommuteLegViewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteLegView &&
        direction == other.direction &&
        scheduleId == other.scheduleId &&
        patternVersionId == other.patternVersionId &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId &&
        localDeparture == other.localDeparture &&
        timeZone == other.timeZone &&
        pickupName == other.pickupName &&
        dropoffName == other.dropoffName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jc(_$hash, localDeparture.hashCode);
    _$hash = $jc(_$hash, timeZone.hashCode);
    _$hash = $jc(_$hash, pickupName.hashCode);
    _$hash = $jc(_$hash, dropoffName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteLegView')
          ..add('direction', direction)
          ..add('scheduleId', scheduleId)
          ..add('patternVersionId', patternVersionId)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId)
          ..add('localDeparture', localDeparture)
          ..add('timeZone', timeZone)
          ..add('pickupName', pickupName)
          ..add('dropoffName', dropoffName))
        .toString();
  }
}

class CommuteLegViewBuilder
    implements Builder<CommuteLegView, CommuteLegViewBuilder> {
  _$CommuteLegView? _$v;

  CommuteLegViewDirectionEnum? _direction;
  CommuteLegViewDirectionEnum? get direction => _$this._direction;
  set direction(CommuteLegViewDirectionEnum? direction) =>
      _$this._direction = direction;

  String? _scheduleId;
  String? get scheduleId => _$this._scheduleId;
  set scheduleId(String? scheduleId) => _$this._scheduleId = scheduleId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  String? _pickupOccurrenceId;
  String? get pickupOccurrenceId => _$this._pickupOccurrenceId;
  set pickupOccurrenceId(String? pickupOccurrenceId) =>
      _$this._pickupOccurrenceId = pickupOccurrenceId;

  String? _dropoffOccurrenceId;
  String? get dropoffOccurrenceId => _$this._dropoffOccurrenceId;
  set dropoffOccurrenceId(String? dropoffOccurrenceId) =>
      _$this._dropoffOccurrenceId = dropoffOccurrenceId;

  String? _localDeparture;
  String? get localDeparture => _$this._localDeparture;
  set localDeparture(String? localDeparture) =>
      _$this._localDeparture = localDeparture;

  CommuteLegViewTimeZoneEnum? _timeZone;
  CommuteLegViewTimeZoneEnum? get timeZone => _$this._timeZone;
  set timeZone(CommuteLegViewTimeZoneEnum? timeZone) =>
      _$this._timeZone = timeZone;

  String? _pickupName;
  String? get pickupName => _$this._pickupName;
  set pickupName(String? pickupName) => _$this._pickupName = pickupName;

  String? _dropoffName;
  String? get dropoffName => _$this._dropoffName;
  set dropoffName(String? dropoffName) => _$this._dropoffName = dropoffName;

  CommuteLegViewBuilder() {
    CommuteLegView._defaults(this);
  }

  CommuteLegViewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _scheduleId = $v.scheduleId;
      _patternVersionId = $v.patternVersionId;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _localDeparture = $v.localDeparture;
      _timeZone = $v.timeZone;
      _pickupName = $v.pickupName;
      _dropoffName = $v.dropoffName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteLegView other) {
    _$v = other as _$CommuteLegView;
  }

  @override
  void update(void Function(CommuteLegViewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteLegView build() => _build();

  _$CommuteLegView _build() {
    final _$result = _$v ??
        _$CommuteLegView._(
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'CommuteLegView', 'direction'),
          scheduleId: BuiltValueNullFieldError.checkNotNull(
              scheduleId, r'CommuteLegView', 'scheduleId'),
          patternVersionId: BuiltValueNullFieldError.checkNotNull(
              patternVersionId, r'CommuteLegView', 'patternVersionId'),
          pickupOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              pickupOccurrenceId, r'CommuteLegView', 'pickupOccurrenceId'),
          dropoffOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              dropoffOccurrenceId, r'CommuteLegView', 'dropoffOccurrenceId'),
          localDeparture: BuiltValueNullFieldError.checkNotNull(
              localDeparture, r'CommuteLegView', 'localDeparture'),
          timeZone: BuiltValueNullFieldError.checkNotNull(
              timeZone, r'CommuteLegView', 'timeZone'),
          pickupName: BuiltValueNullFieldError.checkNotNull(
              pickupName, r'CommuteLegView', 'pickupName'),
          dropoffName: BuiltValueNullFieldError.checkNotNull(
              dropoffName, r'CommuteLegView', 'dropoffName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
