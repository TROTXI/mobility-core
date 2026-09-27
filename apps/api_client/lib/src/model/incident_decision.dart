//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_decision.g.dart';

/// IncidentDecision
///
/// Properties:
<<<<<<< HEAD
/// * [status] 
/// * [resolution] 
@BuiltValue()
abstract class IncidentDecision implements Built<IncidentDecision, IncidentDecisionBuilder> {
=======
/// * [status]
/// * [resolution]
@BuiltValue()
abstract class IncidentDecision
    implements Built<IncidentDecision, IncidentDecisionBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'status')
  IncidentDecisionStatusEnum get status;
  // enum statusEnum {  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String get resolution;

  IncidentDecision._();

<<<<<<< HEAD
  factory IncidentDecision([void updates(IncidentDecisionBuilder b)]) = _$IncidentDecision;
=======
  factory IncidentDecision([void updates(IncidentDecisionBuilder b)]) =
      _$IncidentDecision;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentDecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<IncidentDecision> get serializer => _$IncidentDecisionSerializer();
}

class _$IncidentDecisionSerializer implements PrimitiveSerializer<IncidentDecision> {
=======
  static Serializer<IncidentDecision> get serializer =>
      _$IncidentDecisionSerializer();
}

class _$IncidentDecisionSerializer
    implements PrimitiveSerializer<IncidentDecision> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [IncidentDecision, _$IncidentDecision];

  @override
  final String wireName = r'IncidentDecision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(IncidentDecisionStatusEnum),
    );
    yield r'resolution';
    yield serializers.serialize(
      object.resolution,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentDecisionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentDecisionStatusEnum),
          ) as IncidentDecisionStatusEnum;
          result.status = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resolution = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IncidentDecision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentDecisionBuilder();
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

class IncidentDecisionStatusEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const IncidentDecisionStatusEnum acknowledged = _$incidentDecisionStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const IncidentDecisionStatusEnum resolved = _$incidentDecisionStatusEnum_resolved;

  static Serializer<IncidentDecisionStatusEnum> get serializer => _$incidentDecisionStatusEnumSerializer;

  const IncidentDecisionStatusEnum._(String name): super(name);

  static BuiltSet<IncidentDecisionStatusEnum> get values => _$incidentDecisionStatusEnumValues;
  static IncidentDecisionStatusEnum valueOf(String name) => _$incidentDecisionStatusEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const IncidentDecisionStatusEnum acknowledged =
      _$incidentDecisionStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const IncidentDecisionStatusEnum resolved =
      _$incidentDecisionStatusEnum_resolved;

  static Serializer<IncidentDecisionStatusEnum> get serializer =>
      _$incidentDecisionStatusEnumSerializer;

  const IncidentDecisionStatusEnum._(String name) : super(name);

  static BuiltSet<IncidentDecisionStatusEnum> get values =>
      _$incidentDecisionStatusEnumValues;
  static IncidentDecisionStatusEnum valueOf(String name) =>
      _$incidentDecisionStatusEnumValueOf(name);
}
>>>>>>> origin/main
