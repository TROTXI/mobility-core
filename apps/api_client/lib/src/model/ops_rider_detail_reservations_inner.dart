//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_detail_reservations_inner.g.dart';

/// OpsRiderDetailReservationsInner
///
/// Properties:
/// * [id] 
/// * [serviceDate] 
/// * [direction] 
/// * [status] 
/// * [routeName] 
/// * [scheduledAt] 
@BuiltValue()
abstract class OpsRiderDetailReservationsInner implements Built<OpsRiderDetailReservationsInner, OpsRiderDetailReservationsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'serviceDate')
  Date get serviceDate;

  @BuiltValueField(wireName: r'direction')
  OpsRiderDetailReservationsInnerDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'routeName')
  String? get routeName;

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime? get scheduledAt;

  OpsRiderDetailReservationsInner._();

  factory OpsRiderDetailReservationsInner([void updates(OpsRiderDetailReservationsInnerBuilder b)]) = _$OpsRiderDetailReservationsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderDetailReservationsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderDetailReservationsInner> get serializer => _$OpsRiderDetailReservationsInnerSerializer();
}

class _$OpsRiderDetailReservationsInnerSerializer implements PrimitiveSerializer<OpsRiderDetailReservationsInner> {
  @override
  final Iterable<Type> types = const [OpsRiderDetailReservationsInner, _$OpsRiderDetailReservationsInner];

  @override
  final String wireName = r'OpsRiderDetailReservationsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderDetailReservationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'serviceDate';
    yield serializers.serialize(
      object.serviceDate,
      specifiedType: const FullType(Date),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(OpsRiderDetailReservationsInnerDirectionEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'routeName';
    yield object.routeName == null ? null : serializers.serialize(
      object.routeName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'scheduledAt';
    yield object.scheduledAt == null ? null : serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderDetailReservationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderDetailReservationsInnerBuilder result,
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
        case r'serviceDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.serviceDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRiderDetailReservationsInnerDirectionEnum),
          ) as OpsRiderDetailReservationsInnerDirectionEnum;
          result.direction = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'routeName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeName = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.scheduledAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsRiderDetailReservationsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderDetailReservationsInnerBuilder();
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

class OpsRiderDetailReservationsInnerDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const OpsRiderDetailReservationsInnerDirectionEnum outbound = _$opsRiderDetailReservationsInnerDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const OpsRiderDetailReservationsInnerDirectionEnum return_ = _$opsRiderDetailReservationsInnerDirectionEnum_return_;

  static Serializer<OpsRiderDetailReservationsInnerDirectionEnum> get serializer => _$opsRiderDetailReservationsInnerDirectionEnumSerializer;

  const OpsRiderDetailReservationsInnerDirectionEnum._(String name): super(name);

  static BuiltSet<OpsRiderDetailReservationsInnerDirectionEnum> get values => _$opsRiderDetailReservationsInnerDirectionEnumValues;
  static OpsRiderDetailReservationsInnerDirectionEnum valueOf(String name) => _$opsRiderDetailReservationsInnerDirectionEnumValueOf(name);
}

