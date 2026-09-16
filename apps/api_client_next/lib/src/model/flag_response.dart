//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/flag.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_response.g.dart';

/// FlagResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class FlagResponse implements Built<FlagResponse, FlagResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Flag get data;

  FlagResponse._();

  factory FlagResponse([void updates(FlagResponseBuilder b)]) = _$FlagResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagResponse> get serializer => _$FlagResponseSerializer();
}

class _$FlagResponseSerializer implements PrimitiveSerializer<FlagResponse> {
  @override
  final Iterable<Type> types = const [FlagResponse, _$FlagResponse];

  @override
  final String wireName = r'FlagResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Flag),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Flag),
          ) as Flag;
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
  FlagResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagResponseBuilder();
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

