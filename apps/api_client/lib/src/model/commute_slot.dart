//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_leg.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_slot.g.dart';

/// CommuteSlot
///
/// Properties:
/// * [routeId] 
/// * [legs] 
/// * [availableFrom] 
/// * [id] 
/// * [editToken] 
/// * [state] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class CommuteSlot implements Built<CommuteSlot, CommuteSlotBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLeg> get legs;

  @BuiltValueField(wireName: r'availableFrom')
  Date get availableFrom;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  @BuiltValueField(wireName: r'state')
  CommuteSlotStateEnum get state;
  // enum stateEnum {  available,  held,  assigned,  retired,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  CommuteSlot._();

  factory CommuteSlot([void updates(CommuteSlotBuilder b)]) = _$CommuteSlot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteSlotBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteSlot> get serializer => _$CommuteSlotSerializer();
}

class _$CommuteSlotSerializer implements PrimitiveSerializer<CommuteSlot> {
  @override
  final Iterable<Type> types = const [CommuteSlot, _$CommuteSlot];

  @override
  final String wireName = r'CommuteSlot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteSlot object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
    );
    yield r'availableFrom';
    yield serializers.serialize(
      object.availableFrom,
      specifiedType: const FullType(Date),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(CommuteSlotStateEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteSlot object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteSlotBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
          ) as BuiltList<CommuteLeg>;
          result.legs.replace(valueDes);
          break;
        case r'availableFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.availableFrom = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteSlotStateEnum),
          ) as CommuteSlotStateEnum;
          result.state = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteSlot deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteSlotBuilder();
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

class CommuteSlotStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'available')
  static const CommuteSlotStateEnum available = _$commuteSlotStateEnum_available;
  @BuiltValueEnumConst(wireName: r'held')
  static const CommuteSlotStateEnum held = _$commuteSlotStateEnum_held;
  @BuiltValueEnumConst(wireName: r'assigned')
  static const CommuteSlotStateEnum assigned = _$commuteSlotStateEnum_assigned;
  @BuiltValueEnumConst(wireName: r'retired')
  static const CommuteSlotStateEnum retired = _$commuteSlotStateEnum_retired;

  static Serializer<CommuteSlotStateEnum> get serializer => _$commuteSlotStateEnumSerializer;

  const CommuteSlotStateEnum._(String name): super(name);

  static BuiltSet<CommuteSlotStateEnum> get values => _$commuteSlotStateEnumValues;
  static CommuteSlotStateEnum valueOf(String name) => _$commuteSlotStateEnumValueOf(name);
}

