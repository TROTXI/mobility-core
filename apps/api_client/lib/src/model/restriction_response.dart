//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/restriction.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'restriction_response.g.dart';

/// RestrictionResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class RestrictionResponse implements Built<RestrictionResponse, RestrictionResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Restriction get data;

  RestrictionResponse._();

  factory RestrictionResponse([void updates(RestrictionResponseBuilder b)]) = _$RestrictionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestrictionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RestrictionResponse> get serializer => _$RestrictionResponseSerializer();
}

class _$RestrictionResponseSerializer implements PrimitiveSerializer<RestrictionResponse> {
  @override
  final Iterable<Type> types = const [RestrictionResponse, _$RestrictionResponse];

  @override
  final String wireName = r'RestrictionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RestrictionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Restriction),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RestrictionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RestrictionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Restriction),
          ) as Restriction;
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
  RestrictionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RestrictionResponseBuilder();
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

