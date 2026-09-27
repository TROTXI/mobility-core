//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health.g.dart';

/// Health
///
/// Properties:
<<<<<<< HEAD
/// * [status] 
=======
/// * [status]
>>>>>>> origin/main
@BuiltValue()
abstract class Health implements Built<Health, HealthBuilder> {
  @BuiltValueField(wireName: r'status')
  HealthStatusEnum get status;
  // enum statusEnum {  ok,  unavailable,  };

  Health._();

  factory Health([void updates(HealthBuilder b)]) = _$Health;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Health> get serializer => _$HealthSerializer();
}

class _$HealthSerializer implements PrimitiveSerializer<Health> {
  @override
  final Iterable<Type> types = const [Health, _$Health];

  @override
  final String wireName = r'Health';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Health object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HealthStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Health object, {
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
    required HealthBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthStatusEnum),
          ) as HealthStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Health deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthBuilder();
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

class HealthStatusEnum extends EnumClass {
<<<<<<< HEAD

=======
>>>>>>> origin/main
  @BuiltValueEnumConst(wireName: r'ok')
  static const HealthStatusEnum ok = _$healthStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const HealthStatusEnum unavailable = _$healthStatusEnum_unavailable;

<<<<<<< HEAD
  static Serializer<HealthStatusEnum> get serializer => _$healthStatusEnumSerializer;

  const HealthStatusEnum._(String name): super(name);

  static BuiltSet<HealthStatusEnum> get values => _$healthStatusEnumValues;
  static HealthStatusEnum valueOf(String name) => _$healthStatusEnumValueOf(name);
}

=======
  static Serializer<HealthStatusEnum> get serializer =>
      _$healthStatusEnumSerializer;

  const HealthStatusEnum._(String name) : super(name);

  static BuiltSet<HealthStatusEnum> get values => _$healthStatusEnumValues;
  static HealthStatusEnum valueOf(String name) =>
      _$healthStatusEnumValueOf(name);
}
>>>>>>> origin/main
