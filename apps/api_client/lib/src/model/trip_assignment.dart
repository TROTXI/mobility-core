//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_assignment.g.dart';

/// TripAssignment
///
/// Properties:
<<<<<<< HEAD
/// * [driverId] 
/// * [vehicleId] 
@BuiltValue()
abstract class TripAssignment implements Built<TripAssignment, TripAssignmentBuilder> {
=======
/// * [driverId]
/// * [vehicleId]
@BuiltValue()
abstract class TripAssignment
    implements Built<TripAssignment, TripAssignmentBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'driverId')
  String? get driverId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  TripAssignment._();

<<<<<<< HEAD
  factory TripAssignment([void updates(TripAssignmentBuilder b)]) = _$TripAssignment;
=======
  factory TripAssignment([void updates(TripAssignmentBuilder b)]) =
      _$TripAssignment;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripAssignmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<TripAssignment> get serializer => _$TripAssignmentSerializer();
}

class _$TripAssignmentSerializer implements PrimitiveSerializer<TripAssignment> {
=======
  static Serializer<TripAssignment> get serializer =>
      _$TripAssignmentSerializer();
}

class _$TripAssignmentSerializer
    implements PrimitiveSerializer<TripAssignment> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [TripAssignment, _$TripAssignment];

  @override
  final String wireName = r'TripAssignment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripAssignment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driverId';
<<<<<<< HEAD
    yield object.driverId == null ? null : serializers.serialize(
      object.driverId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'vehicleId';
    yield object.vehicleId == null ? null : serializers.serialize(
      object.vehicleId,
      specifiedType: const FullType.nullable(String),
    );
=======
    yield object.driverId == null
        ? null
        : serializers.serialize(
            object.driverId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'vehicleId';
    yield object.vehicleId == null
        ? null
        : serializers.serialize(
            object.vehicleId,
            specifiedType: const FullType.nullable(String),
          );
>>>>>>> origin/main
  }

  @override
  Object serialize(
    Serializers serializers,
    TripAssignment object, {
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
    required TripAssignmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'vehicleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripAssignment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripAssignmentBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
