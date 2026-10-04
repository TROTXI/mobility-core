// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_offer_input_credits_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandbyOfferInputCreditsInnerDirectionEnum
    _$standbyOfferInputCreditsInnerDirectionEnum_outbound =
    const StandbyOfferInputCreditsInnerDirectionEnum._('outbound');
const StandbyOfferInputCreditsInnerDirectionEnum
    _$standbyOfferInputCreditsInnerDirectionEnum_return_ =
    const StandbyOfferInputCreditsInnerDirectionEnum._('return_');

StandbyOfferInputCreditsInnerDirectionEnum
    _$standbyOfferInputCreditsInnerDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$standbyOfferInputCreditsInnerDirectionEnum_outbound;
    case 'return_':
      return _$standbyOfferInputCreditsInnerDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandbyOfferInputCreditsInnerDirectionEnum>
    _$standbyOfferInputCreditsInnerDirectionEnumValues = BuiltSet<
        StandbyOfferInputCreditsInnerDirectionEnum>(const <StandbyOfferInputCreditsInnerDirectionEnum>[
  _$standbyOfferInputCreditsInnerDirectionEnum_outbound,
  _$standbyOfferInputCreditsInnerDirectionEnum_return_,
]);

Serializer<StandbyOfferInputCreditsInnerDirectionEnum>
    _$standbyOfferInputCreditsInnerDirectionEnumSerializer =
    _$StandbyOfferInputCreditsInnerDirectionEnumSerializer();

class _$StandbyOfferInputCreditsInnerDirectionEnumSerializer
    implements PrimitiveSerializer<StandbyOfferInputCreditsInnerDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    StandbyOfferInputCreditsInnerDirectionEnum
  ];
  @override
  final String wireName = 'StandbyOfferInputCreditsInnerDirectionEnum';

  @override
  Object serialize(Serializers serializers,
          StandbyOfferInputCreditsInnerDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandbyOfferInputCreditsInnerDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandbyOfferInputCreditsInnerDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StandbyOfferInputCreditsInner extends StandbyOfferInputCreditsInner {
  @override
  final StandbyOfferInputCreditsInnerDirectionEnum direction;
  @override
  final Money creditPerUnusedRide;

  factory _$StandbyOfferInputCreditsInner(
          [void Function(StandbyOfferInputCreditsInnerBuilder)? updates]) =>
      (StandbyOfferInputCreditsInnerBuilder()..update(updates))._build();

  _$StandbyOfferInputCreditsInner._(
      {required this.direction, required this.creditPerUnusedRide})
      : super._();
  @override
  StandbyOfferInputCreditsInner rebuild(
          void Function(StandbyOfferInputCreditsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyOfferInputCreditsInnerBuilder toBuilder() =>
      StandbyOfferInputCreditsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyOfferInputCreditsInner &&
        direction == other.direction &&
        creditPerUnusedRide == other.creditPerUnusedRide;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, creditPerUnusedRide.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyOfferInputCreditsInner')
          ..add('direction', direction)
          ..add('creditPerUnusedRide', creditPerUnusedRide))
        .toString();
  }
}

class StandbyOfferInputCreditsInnerBuilder
    implements
        Builder<StandbyOfferInputCreditsInner,
            StandbyOfferInputCreditsInnerBuilder> {
  _$StandbyOfferInputCreditsInner? _$v;

  StandbyOfferInputCreditsInnerDirectionEnum? _direction;
  StandbyOfferInputCreditsInnerDirectionEnum? get direction =>
      _$this._direction;
  set direction(StandbyOfferInputCreditsInnerDirectionEnum? direction) =>
      _$this._direction = direction;

  MoneyBuilder? _creditPerUnusedRide;
  MoneyBuilder get creditPerUnusedRide =>
      _$this._creditPerUnusedRide ??= MoneyBuilder();
  set creditPerUnusedRide(MoneyBuilder? creditPerUnusedRide) =>
      _$this._creditPerUnusedRide = creditPerUnusedRide;

  StandbyOfferInputCreditsInnerBuilder() {
    StandbyOfferInputCreditsInner._defaults(this);
  }

  StandbyOfferInputCreditsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _creditPerUnusedRide = $v.creditPerUnusedRide.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyOfferInputCreditsInner other) {
    _$v = other as _$StandbyOfferInputCreditsInner;
  }

  @override
  void update(void Function(StandbyOfferInputCreditsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyOfferInputCreditsInner build() => _build();

  _$StandbyOfferInputCreditsInner _build() {
    _$StandbyOfferInputCreditsInner _$result;
    try {
      _$result = _$v ??
          _$StandbyOfferInputCreditsInner._(
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'StandbyOfferInputCreditsInner', 'direction'),
            creditPerUnusedRide: creditPerUnusedRide.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'creditPerUnusedRide';
        creditPerUnusedRide.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandbyOfferInputCreditsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
