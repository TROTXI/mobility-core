//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_board_post_request.g.dart';

/// BoardingBoardPostRequest
///
/// Properties:
/// * [reservationId] 
@BuiltValue()
abstract class BoardingBoardPostRequest implements Built<BoardingBoardPostRequest, BoardingBoardPostRequestBuilder> {
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  BoardingBoardPostRequest._();

  factory BoardingBoardPostRequest([void updates(BoardingBoardPostRequestBuilder b)]) = _$BoardingBoardPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingBoardPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingBoardPostRequest> get serializer => _$BoardingBoardPostRequestSerializer();
}

class _$BoardingBoardPostRequestSerializer implements PrimitiveSerializer<BoardingBoardPostRequest> {
  @override
  final Iterable<Type> types = const [BoardingBoardPostRequest, _$BoardingBoardPostRequest];

  @override
  final String wireName = r'BoardingBoardPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingBoardPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingBoardPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingBoardPostRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingBoardPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingBoardPostRequestBuilder();
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

