//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/boarding_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_result_response.g.dart';

/// BoardingResultResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class BoardingResultResponse implements Built<BoardingResultResponse, BoardingResultResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class BoardingResultResponse
    implements Built<BoardingResultResponse, BoardingResultResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BoardingResult get data;

  BoardingResultResponse._();

<<<<<<< HEAD
  factory BoardingResultResponse([void updates(BoardingResultResponseBuilder b)]) = _$BoardingResultResponse;
=======
  factory BoardingResultResponse(
          [void updates(BoardingResultResponseBuilder b)]) =
      _$BoardingResultResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<BoardingResultResponse> get serializer => _$BoardingResultResponseSerializer();
}

class _$BoardingResultResponseSerializer implements PrimitiveSerializer<BoardingResultResponse> {
  @override
  final Iterable<Type> types = const [BoardingResultResponse, _$BoardingResultResponse];
=======
  static Serializer<BoardingResultResponse> get serializer =>
      _$BoardingResultResponseSerializer();
}

class _$BoardingResultResponseSerializer
    implements PrimitiveSerializer<BoardingResultResponse> {
  @override
  final Iterable<Type> types = const [
    BoardingResultResponse,
    _$BoardingResultResponse
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'BoardingResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BoardingResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingResultResponse object, {
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
    required BoardingResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingResult),
          ) as BoardingResult;
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
  BoardingResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingResultResponseBuilder();
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
