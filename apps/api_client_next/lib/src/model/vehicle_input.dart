//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_input.g.dart';

/// VehicleInput
///
/// Properties:
/// * [plate] 
/// * [label] 
/// * [make] 
/// * [colour] 
/// * [capacity] 
@BuiltValue()
abstract class VehicleInput implements Built<VehicleInput, VehicleInputBuilder> {
  @BuiltValueField(wireName: r'plate')
  String get plate;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'make')
  String? get make;

  @BuiltValueField(wireName: r'colour')
  String? get colour;

  @BuiltValueField(wireName: r'capacity')
  int get capacity;

  VehicleInput._();

  factory VehicleInput([void updates(VehicleInputBuilder b)]) = _$VehicleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleInput> get serializer => _$VehicleInputSerializer();
}

class _$VehicleInputSerializer implements PrimitiveSerializer<VehicleInput> {
  @override
  final Iterable<Type> types = const [VehicleInput, _$VehicleInput];

  @override
  final String wireName = r'VehicleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plate';
    yield serializers.serialize(
      object.plate,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield object.label == null ? null : serializers.serialize(
      object.label,
      specifiedType: const FullType.nullable(String),
    );
    yield r'make';
    yield object.make == null ? null : serializers.serialize(
      object.make,
      specifiedType: const FullType.nullable(String),
    );
    yield r'colour';
    yield object.colour == null ? null : serializers.serialize(
      object.colour,
      specifiedType: const FullType.nullable(String),
    );
    yield r'capacity';
    yield serializers.serialize(
      object.capacity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehicleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plate = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.make = valueDes;
          break;
        case r'colour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.colour = valueDes;
          break;
        case r'capacity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.capacity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleInputBuilder();
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

