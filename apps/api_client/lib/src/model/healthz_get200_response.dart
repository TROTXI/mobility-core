//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'healthz_get200_response.g.dart';

/// HealthzGet200Response
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class HealthzGet200Response implements Built<HealthzGet200Response, HealthzGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  HealthzGet200ResponseStatusEnum get status;
  // enum statusEnum {  ok,  };

  HealthzGet200Response._();

  factory HealthzGet200Response([void updates(HealthzGet200ResponseBuilder b)]) = _$HealthzGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthzGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HealthzGet200Response> get serializer => _$HealthzGet200ResponseSerializer();
}

class _$HealthzGet200ResponseSerializer implements PrimitiveSerializer<HealthzGet200Response> {
  @override
  final Iterable<Type> types = const [HealthzGet200Response, _$HealthzGet200Response];

  @override
  final String wireName = r'HealthzGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HealthzGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(HealthzGet200ResponseStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HealthzGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HealthzGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthzGet200ResponseStatusEnum),
          ) as HealthzGet200ResponseStatusEnum;
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
  HealthzGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthzGet200ResponseBuilder();
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

class HealthzGet200ResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const HealthzGet200ResponseStatusEnum ok = _$healthzGet200ResponseStatusEnum_ok;

  static Serializer<HealthzGet200ResponseStatusEnum> get serializer => _$healthzGet200ResponseStatusEnumSerializer;

  const HealthzGet200ResponseStatusEnum._(String name): super(name);

  static BuiltSet<HealthzGet200ResponseStatusEnum> get values => _$healthzGet200ResponseStatusEnumValues;
  static HealthzGet200ResponseStatusEnum valueOf(String name) => _$healthzGet200ResponseStatusEnumValueOf(name);
}

