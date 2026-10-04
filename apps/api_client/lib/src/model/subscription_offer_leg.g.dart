// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_offer_leg.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SubscriptionOfferLegDirectionEnum
    _$subscriptionOfferLegDirectionEnum_outbound =
    const SubscriptionOfferLegDirectionEnum._('outbound');
const SubscriptionOfferLegDirectionEnum
    _$subscriptionOfferLegDirectionEnum_return_ =
    const SubscriptionOfferLegDirectionEnum._('return_');

SubscriptionOfferLegDirectionEnum _$subscriptionOfferLegDirectionEnumValueOf(
    String name) {
  switch (name) {
    case 'outbound':
      return _$subscriptionOfferLegDirectionEnum_outbound;
    case 'return_':
      return _$subscriptionOfferLegDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SubscriptionOfferLegDirectionEnum>
    _$subscriptionOfferLegDirectionEnumValues = BuiltSet<
        SubscriptionOfferLegDirectionEnum>(const <SubscriptionOfferLegDirectionEnum>[
  _$subscriptionOfferLegDirectionEnum_outbound,
  _$subscriptionOfferLegDirectionEnum_return_,
]);

Serializer<SubscriptionOfferLegDirectionEnum>
    _$subscriptionOfferLegDirectionEnumSerializer =
    _$SubscriptionOfferLegDirectionEnumSerializer();

class _$SubscriptionOfferLegDirectionEnumSerializer
    implements PrimitiveSerializer<SubscriptionOfferLegDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[SubscriptionOfferLegDirectionEnum];
  @override
  final String wireName = 'SubscriptionOfferLegDirectionEnum';

  @override
  Object serialize(
          Serializers serializers, SubscriptionOfferLegDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SubscriptionOfferLegDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SubscriptionOfferLegDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SubscriptionOfferLeg extends SubscriptionOfferLeg {
  @override
  final SubscriptionOfferLegDirectionEnum direction;
  @override
  final String scheduleId;
  @override
  final String patternVersionId;
  @override
  final String pickupOccurrenceId;
  @override
  final String dropoffOccurrenceId;
  @override
  final String pickupName;
  @override
  final String dropoffName;
  @override
  final String fareId;
  @override
  final Money fare;
  @override
  final int ridesGranted;
  @override
  final BuiltList<int> travelDays;
  @override
  final Money creditPerUnusedRide;

  factory _$SubscriptionOfferLeg(
          [void Function(SubscriptionOfferLegBuilder)? updates]) =>
      (SubscriptionOfferLegBuilder()..update(updates))._build();

  _$SubscriptionOfferLeg._(
      {required this.direction,
      required this.scheduleId,
      required this.patternVersionId,
      required this.pickupOccurrenceId,
      required this.dropoffOccurrenceId,
      required this.pickupName,
      required this.dropoffName,
      required this.fareId,
      required this.fare,
      required this.ridesGranted,
      required this.travelDays,
      required this.creditPerUnusedRide})
      : super._();
  @override
  SubscriptionOfferLeg rebuild(
          void Function(SubscriptionOfferLegBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubscriptionOfferLegBuilder toBuilder() =>
      SubscriptionOfferLegBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionOfferLeg &&
        direction == other.direction &&
        scheduleId == other.scheduleId &&
        patternVersionId == other.patternVersionId &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId &&
        pickupName == other.pickupName &&
        dropoffName == other.dropoffName &&
        fareId == other.fareId &&
        fare == other.fare &&
        ridesGranted == other.ridesGranted &&
        travelDays == other.travelDays &&
        creditPerUnusedRide == other.creditPerUnusedRide;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jc(_$hash, pickupName.hashCode);
    _$hash = $jc(_$hash, dropoffName.hashCode);
    _$hash = $jc(_$hash, fareId.hashCode);
    _$hash = $jc(_$hash, fare.hashCode);
    _$hash = $jc(_$hash, ridesGranted.hashCode);
    _$hash = $jc(_$hash, travelDays.hashCode);
    _$hash = $jc(_$hash, creditPerUnusedRide.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionOfferLeg')
          ..add('direction', direction)
          ..add('scheduleId', scheduleId)
          ..add('patternVersionId', patternVersionId)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId)
          ..add('pickupName', pickupName)
          ..add('dropoffName', dropoffName)
          ..add('fareId', fareId)
          ..add('fare', fare)
          ..add('ridesGranted', ridesGranted)
          ..add('travelDays', travelDays)
          ..add('creditPerUnusedRide', creditPerUnusedRide))
        .toString();
  }
}

class SubscriptionOfferLegBuilder
    implements Builder<SubscriptionOfferLeg, SubscriptionOfferLegBuilder> {
  _$SubscriptionOfferLeg? _$v;

  SubscriptionOfferLegDirectionEnum? _direction;
  SubscriptionOfferLegDirectionEnum? get direction => _$this._direction;
  set direction(SubscriptionOfferLegDirectionEnum? direction) =>
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

  String? _pickupName;
  String? get pickupName => _$this._pickupName;
  set pickupName(String? pickupName) => _$this._pickupName = pickupName;

  String? _dropoffName;
  String? get dropoffName => _$this._dropoffName;
  set dropoffName(String? dropoffName) => _$this._dropoffName = dropoffName;

  String? _fareId;
  String? get fareId => _$this._fareId;
  set fareId(String? fareId) => _$this._fareId = fareId;

  MoneyBuilder? _fare;
  MoneyBuilder get fare => _$this._fare ??= MoneyBuilder();
  set fare(MoneyBuilder? fare) => _$this._fare = fare;

  int? _ridesGranted;
  int? get ridesGranted => _$this._ridesGranted;
  set ridesGranted(int? ridesGranted) => _$this._ridesGranted = ridesGranted;

  ListBuilder<int>? _travelDays;
  ListBuilder<int> get travelDays => _$this._travelDays ??= ListBuilder<int>();
  set travelDays(ListBuilder<int>? travelDays) =>
      _$this._travelDays = travelDays;

  MoneyBuilder? _creditPerUnusedRide;
  MoneyBuilder get creditPerUnusedRide =>
      _$this._creditPerUnusedRide ??= MoneyBuilder();
  set creditPerUnusedRide(MoneyBuilder? creditPerUnusedRide) =>
      _$this._creditPerUnusedRide = creditPerUnusedRide;

  SubscriptionOfferLegBuilder() {
    SubscriptionOfferLeg._defaults(this);
  }

  SubscriptionOfferLegBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _scheduleId = $v.scheduleId;
      _patternVersionId = $v.patternVersionId;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _pickupName = $v.pickupName;
      _dropoffName = $v.dropoffName;
      _fareId = $v.fareId;
      _fare = $v.fare.toBuilder();
      _ridesGranted = $v.ridesGranted;
      _travelDays = $v.travelDays.toBuilder();
      _creditPerUnusedRide = $v.creditPerUnusedRide.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionOfferLeg other) {
    _$v = other as _$SubscriptionOfferLeg;
  }

  @override
  void update(void Function(SubscriptionOfferLegBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionOfferLeg build() => _build();

  _$SubscriptionOfferLeg _build() {
    _$SubscriptionOfferLeg _$result;
    try {
      _$result = _$v ??
          _$SubscriptionOfferLeg._(
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'SubscriptionOfferLeg', 'direction'),
            scheduleId: BuiltValueNullFieldError.checkNotNull(
                scheduleId, r'SubscriptionOfferLeg', 'scheduleId'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'SubscriptionOfferLeg', 'patternVersionId'),
            pickupOccurrenceId: BuiltValueNullFieldError.checkNotNull(
                pickupOccurrenceId,
                r'SubscriptionOfferLeg',
                'pickupOccurrenceId'),
            dropoffOccurrenceId: BuiltValueNullFieldError.checkNotNull(
                dropoffOccurrenceId,
                r'SubscriptionOfferLeg',
                'dropoffOccurrenceId'),
            pickupName: BuiltValueNullFieldError.checkNotNull(
                pickupName, r'SubscriptionOfferLeg', 'pickupName'),
            dropoffName: BuiltValueNullFieldError.checkNotNull(
                dropoffName, r'SubscriptionOfferLeg', 'dropoffName'),
            fareId: BuiltValueNullFieldError.checkNotNull(
                fareId, r'SubscriptionOfferLeg', 'fareId'),
            fare: fare.build(),
            ridesGranted: BuiltValueNullFieldError.checkNotNull(
                ridesGranted, r'SubscriptionOfferLeg', 'ridesGranted'),
            travelDays: travelDays.build(),
            creditPerUnusedRide: creditPerUnusedRide.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fare';
        fare.build();

        _$failedField = 'travelDays';
        travelDays.build();
        _$failedField = 'creditPerUnusedRide';
        creditPerUnusedRide.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SubscriptionOfferLeg', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
