//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_entry.g.dart';

/// RideEntry
///
/// Properties:
/// * [id] 
/// * [deltaRides] 
/// * [reason] 
/// * [billingPeriodId] 
/// * [createdAt] 
@BuiltValue()
abstract class RideEntry implements Built<RideEntry, RideEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'deltaRides')
  int get deltaRides;

  @BuiltValueField(wireName: r'reason')
  RideEntryReasonEnum get reason;
  // enum reasonEnum {  allocation,  boarding,  no_show,  returned,  refund,  converted,  };

  @BuiltValueField(wireName: r'billingPeriodId')
  String get billingPeriodId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  RideEntry._();

  factory RideEntry([void updates(RideEntryBuilder b)]) = _$RideEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideEntry> get serializer => _$RideEntrySerializer();
}

class _$RideEntrySerializer implements PrimitiveSerializer<RideEntry> {
  @override
  final Iterable<Type> types = const [RideEntry, _$RideEntry];

  @override
  final String wireName = r'RideEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'deltaRides';
    yield serializers.serialize(
      object.deltaRides,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(RideEntryReasonEnum),
    );
    yield r'billingPeriodId';
    yield serializers.serialize(
      object.billingPeriodId,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RideEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'deltaRides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deltaRides = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideEntryReasonEnum),
          ) as RideEntryReasonEnum;
          result.reason = valueDes;
          break;
        case r'billingPeriodId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.billingPeriodId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideEntryBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class RideEntryReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'allocation')
  static const RideEntryReasonEnum allocation = _$rideEntryReasonEnum_allocation;
  @BuiltValueEnumConst(wireName: r'boarding')
  static const RideEntryReasonEnum boarding = _$rideEntryReasonEnum_boarding;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const RideEntryReasonEnum noShow = _$rideEntryReasonEnum_noShow;
  @BuiltValueEnumConst(wireName: r'returned')
  static const RideEntryReasonEnum returned = _$rideEntryReasonEnum_returned;
  @BuiltValueEnumConst(wireName: r'refund')
  static const RideEntryReasonEnum refund = _$rideEntryReasonEnum_refund;
  @BuiltValueEnumConst(wireName: r'converted')
  static const RideEntryReasonEnum converted = _$rideEntryReasonEnum_converted;

  static Serializer<RideEntryReasonEnum> get serializer => _$rideEntryReasonEnumSerializer;

  const RideEntryReasonEnum._(String name): super(name);

  static BuiltSet<RideEntryReasonEnum> get values => _$rideEntryReasonEnumValues;
  static RideEntryReasonEnum valueOf(String name) => _$rideEntryReasonEnumValueOf(name);
}

