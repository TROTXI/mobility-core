// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideEntryReasonEnum _$rideEntryReasonEnum_allocation =
    const RideEntryReasonEnum._('allocation');
const RideEntryReasonEnum _$rideEntryReasonEnum_boarding =
    const RideEntryReasonEnum._('boarding');
const RideEntryReasonEnum _$rideEntryReasonEnum_noShow =
    const RideEntryReasonEnum._('noShow');
const RideEntryReasonEnum _$rideEntryReasonEnum_returned =
    const RideEntryReasonEnum._('returned');
const RideEntryReasonEnum _$rideEntryReasonEnum_refund =
    const RideEntryReasonEnum._('refund');
const RideEntryReasonEnum _$rideEntryReasonEnum_converted =
    const RideEntryReasonEnum._('converted');

RideEntryReasonEnum _$rideEntryReasonEnumValueOf(String name) {
  switch (name) {
    case 'allocation':
      return _$rideEntryReasonEnum_allocation;
    case 'boarding':
      return _$rideEntryReasonEnum_boarding;
    case 'noShow':
      return _$rideEntryReasonEnum_noShow;
    case 'returned':
      return _$rideEntryReasonEnum_returned;
    case 'refund':
      return _$rideEntryReasonEnum_refund;
    case 'converted':
      return _$rideEntryReasonEnum_converted;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideEntryReasonEnum> _$rideEntryReasonEnumValues =
    BuiltSet<RideEntryReasonEnum>(const <RideEntryReasonEnum>[
  _$rideEntryReasonEnum_allocation,
  _$rideEntryReasonEnum_boarding,
  _$rideEntryReasonEnum_noShow,
  _$rideEntryReasonEnum_returned,
  _$rideEntryReasonEnum_refund,
  _$rideEntryReasonEnum_converted,
]);

Serializer<RideEntryReasonEnum> _$rideEntryReasonEnumSerializer =
    _$RideEntryReasonEnumSerializer();

class _$RideEntryReasonEnumSerializer
    implements PrimitiveSerializer<RideEntryReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'allocation': 'allocation',
    'boarding': 'boarding',
    'noShow': 'no_show',
    'returned': 'returned',
    'refund': 'refund',
    'converted': 'converted',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'allocation': 'allocation',
    'boarding': 'boarding',
    'no_show': 'noShow',
    'returned': 'returned',
    'refund': 'refund',
    'converted': 'converted',
  };

  @override
  final Iterable<Type> types = const <Type>[RideEntryReasonEnum];
  @override
  final String wireName = 'RideEntryReasonEnum';

  @override
  Object serialize(Serializers serializers, RideEntryReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RideEntryReasonEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RideEntryReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RideEntry extends RideEntry {
  @override
  final String id;
  @override
  final int deltaRides;
  @override
  final RideEntryReasonEnum reason;
  @override
  final String billingPeriodId;
  @override
  final DateTime createdAt;

  factory _$RideEntry([void Function(RideEntryBuilder)? updates]) =>
      (RideEntryBuilder()..update(updates))._build();

  _$RideEntry._(
      {required this.id,
      required this.deltaRides,
      required this.reason,
      required this.billingPeriodId,
      required this.createdAt})
      : super._();
  @override
  RideEntry rebuild(void Function(RideEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideEntryBuilder toBuilder() => RideEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideEntry &&
        id == other.id &&
        deltaRides == other.deltaRides &&
        reason == other.reason &&
        billingPeriodId == other.billingPeriodId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, deltaRides.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, billingPeriodId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideEntry')
          ..add('id', id)
          ..add('deltaRides', deltaRides)
          ..add('reason', reason)
          ..add('billingPeriodId', billingPeriodId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RideEntryBuilder implements Builder<RideEntry, RideEntryBuilder> {
  _$RideEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _deltaRides;
  int? get deltaRides => _$this._deltaRides;
  set deltaRides(int? deltaRides) => _$this._deltaRides = deltaRides;

  RideEntryReasonEnum? _reason;
  RideEntryReasonEnum? get reason => _$this._reason;
  set reason(RideEntryReasonEnum? reason) => _$this._reason = reason;

  String? _billingPeriodId;
  String? get billingPeriodId => _$this._billingPeriodId;
  set billingPeriodId(String? billingPeriodId) =>
      _$this._billingPeriodId = billingPeriodId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RideEntryBuilder() {
    RideEntry._defaults(this);
  }

  RideEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _deltaRides = $v.deltaRides;
      _reason = $v.reason;
      _billingPeriodId = $v.billingPeriodId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideEntry other) {
    _$v = other as _$RideEntry;
  }

  @override
  void update(void Function(RideEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideEntry build() => _build();

  _$RideEntry _build() {
    final _$result = _$v ??
        _$RideEntry._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'RideEntry', 'id'),
          deltaRides: BuiltValueNullFieldError.checkNotNull(
              deltaRides, r'RideEntry', 'deltaRides'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RideEntry', 'reason'),
          billingPeriodId: BuiltValueNullFieldError.checkNotNull(
              billingPeriodId, r'RideEntry', 'billingPeriodId'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RideEntry', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
