//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_verify_code_post_request.g.dart';

/// BoardingVerifyCodePostRequest
///
/// Properties:
/// * [tripId] 
/// * [code] 
@BuiltValue()
abstract class BoardingVerifyCodePostRequest implements Built<BoardingVerifyCodePostRequest, BoardingVerifyCodePostRequestBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'code')
  String get code;

  BoardingVerifyCodePostRequest._();

  factory BoardingVerifyCodePostRequest([void updates(BoardingVerifyCodePostRequestBuilder b)]) = _$BoardingVerifyCodePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingVerifyCodePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingVerifyCodePostRequest> get serializer => _$BoardingVerifyCodePostRequestSerializer();
}

class _$BoardingVerifyCodePostRequestSerializer implements PrimitiveSerializer<BoardingVerifyCodePostRequest> {
  @override
  final Iterable<Type> types = const [BoardingVerifyCodePostRequest, _$BoardingVerifyCodePostRequest];

  @override
  final String wireName = r'BoardingVerifyCodePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingVerifyCodePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingVerifyCodePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingVerifyCodePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingVerifyCodePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingVerifyCodePostRequestBuilder();
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

