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
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class RestrictionResponse implements Built<RestrictionResponse, RestrictionResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class RestrictionResponse
    implements Built<RestrictionResponse, RestrictionResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  Restriction get data;

  RestrictionResponse._();

<<<<<<< HEAD
  factory RestrictionResponse([void updates(RestrictionResponseBuilder b)]) = _$RestrictionResponse;
=======
  factory RestrictionResponse([void updates(RestrictionResponseBuilder b)]) =
      _$RestrictionResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RestrictionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<RestrictionResponse> get serializer => _$RestrictionResponseSerializer();
}

class _$RestrictionResponseSerializer implements PrimitiveSerializer<RestrictionResponse> {
  @override
  final Iterable<Type> types = const [RestrictionResponse, _$RestrictionResponse];
=======
  static Serializer<RestrictionResponse> get serializer =>
      _$RestrictionResponseSerializer();
}

class _$RestrictionResponseSerializer
    implements PrimitiveSerializer<RestrictionResponse> {
  @override
  final Iterable<Type> types = const [
    RestrictionResponse,
    _$RestrictionResponse
  ];
>>>>>>> origin/main

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
<<<<<<< HEAD

=======
>>>>>>> origin/main
