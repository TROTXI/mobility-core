//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'readyz_get200_response.g.dart';

/// ReadyzGet200Response
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class ReadyzGet200Response implements Built<ReadyzGet200Response, ReadyzGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  ReadyzGet200ResponseStatusEnum get status;
  // enum statusEnum {  ready,  };

  ReadyzGet200Response._();

  factory ReadyzGet200Response([void updates(ReadyzGet200ResponseBuilder b)]) = _$ReadyzGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyzGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyzGet200Response> get serializer => _$ReadyzGet200ResponseSerializer();
}

class _$ReadyzGet200ResponseSerializer implements PrimitiveSerializer<ReadyzGet200Response> {
  @override
  final Iterable<Type> types = const [ReadyzGet200Response, _$ReadyzGet200Response];

  @override
  final String wireName = r'ReadyzGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyzGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReadyzGet200ResponseStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyzGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReadyzGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadyzGet200ResponseStatusEnum),
          ) as ReadyzGet200ResponseStatusEnum;
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
  ReadyzGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyzGet200ResponseBuilder();
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

class ReadyzGet200ResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ready')
  static const ReadyzGet200ResponseStatusEnum ready = _$readyzGet200ResponseStatusEnum_ready;

  static Serializer<ReadyzGet200ResponseStatusEnum> get serializer => _$readyzGet200ResponseStatusEnumSerializer;

  const ReadyzGet200ResponseStatusEnum._(String name): super(name);

  static BuiltSet<ReadyzGet200ResponseStatusEnum> get values => _$readyzGet200ResponseStatusEnumValues;
  static ReadyzGet200ResponseStatusEnum valueOf(String name) => _$readyzGet200ResponseStatusEnumValueOf(name);
}

