//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'readyz_get503_response.g.dart';

/// ReadyzGet503Response
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class ReadyzGet503Response implements Built<ReadyzGet503Response, ReadyzGet503ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  ReadyzGet503ResponseStatusEnum get status;
  // enum statusEnum {  not_ready,  };

  ReadyzGet503Response._();

  factory ReadyzGet503Response([void updates(ReadyzGet503ResponseBuilder b)]) = _$ReadyzGet503Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyzGet503ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyzGet503Response> get serializer => _$ReadyzGet503ResponseSerializer();
}

class _$ReadyzGet503ResponseSerializer implements PrimitiveSerializer<ReadyzGet503Response> {
  @override
  final Iterable<Type> types = const [ReadyzGet503Response, _$ReadyzGet503Response];

  @override
  final String wireName = r'ReadyzGet503Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyzGet503Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReadyzGet503ResponseStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyzGet503Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReadyzGet503ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadyzGet503ResponseStatusEnum),
          ) as ReadyzGet503ResponseStatusEnum;
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
  ReadyzGet503Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyzGet503ResponseBuilder();
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

class ReadyzGet503ResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'not_ready')
  static const ReadyzGet503ResponseStatusEnum notReady = _$readyzGet503ResponseStatusEnum_notReady;

  static Serializer<ReadyzGet503ResponseStatusEnum> get serializer => _$readyzGet503ResponseStatusEnumSerializer;

  const ReadyzGet503ResponseStatusEnum._(String name): super(name);

  static BuiltSet<ReadyzGet503ResponseStatusEnum> get values => _$readyzGet503ResponseStatusEnumValues;
  static ReadyzGet503ResponseStatusEnum valueOf(String name) => _$readyzGet503ResponseStatusEnumValueOf(name);
}

