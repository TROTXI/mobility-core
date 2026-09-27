//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trace_hold.g.dart';

/// TraceHold
///
/// Properties:
/// * [incidentId] 
/// * [tripId] 
/// * [receivedFrom] 
/// * [receivedTo] 
/// * [reason] 
/// * [reviewAt] 
/// * [id] 
/// * [state] 
/// * [editToken] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class TraceHold implements Built<TraceHold, TraceHoldBuilder> {
  @BuiltValueField(wireName: r'incidentId')
  String get incidentId;

  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'receivedFrom')
  DateTime get receivedFrom;

  @BuiltValueField(wireName: r'receivedTo')
  DateTime get receivedTo;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'reviewAt')
  DateTime get reviewAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'state')
  TraceHoldStateEnum get state;
  // enum stateEnum {  active,  released,  };

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  TraceHold._();

  factory TraceHold([void updates(TraceHoldBuilder b)]) = _$TraceHold;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TraceHoldBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TraceHold> get serializer => _$TraceHoldSerializer();
}

class _$TraceHoldSerializer implements PrimitiveSerializer<TraceHold> {
  @override
  final Iterable<Type> types = const [TraceHold, _$TraceHold];

  @override
  final String wireName = r'TraceHold';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TraceHold object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'incidentId';
    yield serializers.serialize(
      object.incidentId,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'receivedFrom';
    yield serializers.serialize(
      object.receivedFrom,
      specifiedType: const FullType(DateTime),
    );
    yield r'receivedTo';
    yield serializers.serialize(
      object.receivedTo,
      specifiedType: const FullType(DateTime),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'reviewAt';
    yield serializers.serialize(
      object.reviewAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(TraceHoldStateEnum),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
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
    TraceHold object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TraceHoldBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'incidentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.incidentId = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'receivedFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedFrom = valueDes;
          break;
        case r'receivedTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedTo = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'reviewAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.reviewAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TraceHoldStateEnum),
          ) as TraceHoldStateEnum;
          result.state = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
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
  TraceHold deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TraceHoldBuilder();
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

class TraceHoldStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const TraceHoldStateEnum active = _$traceHoldStateEnum_active;
  @BuiltValueEnumConst(wireName: r'released')
  static const TraceHoldStateEnum released = _$traceHoldStateEnum_released;

  static Serializer<TraceHoldStateEnum> get serializer => _$traceHoldStateEnumSerializer;

  const TraceHoldStateEnum._(String name): super(name);

  static BuiltSet<TraceHoldStateEnum> get values => _$traceHoldStateEnumValues;
  static TraceHoldStateEnum valueOf(String name) => _$traceHoldStateEnumValueOf(name);
}

