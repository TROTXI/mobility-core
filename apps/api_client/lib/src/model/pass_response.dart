//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/pass.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pass_response.g.dart';

/// PassResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PassResponse implements Built<PassResponse, PassResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Pass get data;

  PassResponse._();

  factory PassResponse([void updates(PassResponseBuilder b)]) = _$PassResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PassResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PassResponse> get serializer => _$PassResponseSerializer();
}

class _$PassResponseSerializer implements PrimitiveSerializer<PassResponse> {
  @override
  final Iterable<Type> types = const [PassResponse, _$PassResponse];

  @override
  final String wireName = r'PassResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PassResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Pass),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PassResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PassResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Pass),
          ) as Pass;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PassResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PassResponseBuilder();
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

