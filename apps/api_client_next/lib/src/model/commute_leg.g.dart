// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_leg.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteLegDirectionEnum _$commuteLegDirectionEnum_outbound =
    const CommuteLegDirectionEnum._('outbound');
const CommuteLegDirectionEnum _$commuteLegDirectionEnum_return_ =
    const CommuteLegDirectionEnum._('return_');

CommuteLegDirectionEnum _$commuteLegDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$commuteLegDirectionEnum_outbound;
    case 'return_':
      return _$commuteLegDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteLegDirectionEnum> _$commuteLegDirectionEnumValues =
    BuiltSet<CommuteLegDirectionEnum>(const <CommuteLegDirectionEnum>[
  _$commuteLegDirectionEnum_outbound,
  _$commuteLegDirectionEnum_return_,
]);

Serializer<CommuteLegDirectionEnum> _$commuteLegDirectionEnumSerializer =
    _$CommuteLegDirectionEnumSerializer();

class _$CommuteLegDirectionEnumSerializer
    implements PrimitiveSerializer<CommuteLegDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteLegDirectionEnum];
  @override
  final String wireName = 'CommuteLegDirectionEnum';

  @override
  Object serialize(Serializers serializers, CommuteLegDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteLegDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteLegDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteLeg extends CommuteLeg {
  @override
  final CommuteLegDirectionEnum direction;
  @override
  final String scheduleId;
  @override
  final String patternVersionId;
  @override
  final String pickupOccurrenceId;
  @override
  final String dropoffOccurrenceId;

  factory _$CommuteLeg([void Function(CommuteLegBuilder)? updates]) =>
      (CommuteLegBuilder()..update(updates))._build();

  _$CommuteLeg._(
      {required this.direction,
      required this.scheduleId,
      required this.patternVersionId,
      required this.pickupOccurrenceId,
      required this.dropoffOccurrenceId})
      : super._();
  @override
  CommuteLeg rebuild(void Function(CommuteLegBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteLegBuilder toBuilder() => CommuteLegBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteLeg &&
        direction == other.direction &&
        scheduleId == other.scheduleId &&
        patternVersionId == other.patternVersionId &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteLeg')
          ..add('direction', direction)
          ..add('scheduleId', scheduleId)
          ..add('patternVersionId', patternVersionId)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId))
        .toString();
  }
}

class CommuteLegBuilder implements Builder<CommuteLeg, CommuteLegBuilder> {
  _$CommuteLeg? _$v;

  CommuteLegDirectionEnum? _direction;
  CommuteLegDirectionEnum? get direction => _$this._direction;
  set direction(CommuteLegDirectionEnum? direction) =>
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

  CommuteLegBuilder() {
    CommuteLeg._defaults(this);
  }

  CommuteLegBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _scheduleId = $v.scheduleId;
      _patternVersionId = $v.patternVersionId;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteLeg other) {
    _$v = other as _$CommuteLeg;
  }

  @override
  void update(void Function(CommuteLegBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteLeg build() => _build();

  _$CommuteLeg _build() {
    final _$result = _$v ??
        _$CommuteLeg._(
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'CommuteLeg', 'direction'),
          scheduleId: BuiltValueNullFieldError.checkNotNull(
              scheduleId, r'CommuteLeg', 'scheduleId'),
          patternVersionId: BuiltValueNullFieldError.checkNotNull(
              patternVersionId, r'CommuteLeg', 'patternVersionId'),
          pickupOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              pickupOccurrenceId, r'CommuteLeg', 'pickupOccurrenceId'),
          dropoffOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              dropoffOccurrenceId, r'CommuteLeg', 'dropoffOccurrenceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
