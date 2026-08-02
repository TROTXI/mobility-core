//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_verify_pin_post_request.g.dart';

/// BoardingVerifyPinPostRequest
///
/// Properties:
/// * [reservationId] 
/// * [pin] 
@BuiltValue()
abstract class BoardingVerifyPinPostRequest implements Built<BoardingVerifyPinPostRequest, BoardingVerifyPinPostRequestBuilder> {
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  BoardingVerifyPinPostRequest._();

  factory BoardingVerifyPinPostRequest([void updates(BoardingVerifyPinPostRequestBuilder b)]) = _$BoardingVerifyPinPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingVerifyPinPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingVerifyPinPostRequest> get serializer => _$BoardingVerifyPinPostRequestSerializer();
}

class _$BoardingVerifyPinPostRequestSerializer implements PrimitiveSerializer<BoardingVerifyPinPostRequest> {
  @override
  final Iterable<Type> types = const [BoardingVerifyPinPostRequest, _$BoardingVerifyPinPostRequest];

  @override
  final String wireName = r'BoardingVerifyPinPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingVerifyPinPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingVerifyPinPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingVerifyPinPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingVerifyPinPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingVerifyPinPostRequestBuilder();
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

