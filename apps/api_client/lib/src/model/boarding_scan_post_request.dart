//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_scan_post_request.g.dart';

/// BoardingScanPostRequest
///
/// Properties:
/// * [pass] 
/// * [tripId] 
@BuiltValue()
abstract class BoardingScanPostRequest implements Built<BoardingScanPostRequest, BoardingScanPostRequestBuilder> {
  @BuiltValueField(wireName: r'pass')
  String get pass;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  BoardingScanPostRequest._();

  factory BoardingScanPostRequest([void updates(BoardingScanPostRequestBuilder b)]) = _$BoardingScanPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingScanPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingScanPostRequest> get serializer => _$BoardingScanPostRequestSerializer();
}

class _$BoardingScanPostRequestSerializer implements PrimitiveSerializer<BoardingScanPostRequest> {
  @override
  final Iterable<Type> types = const [BoardingScanPostRequest, _$BoardingScanPostRequest];

  @override
  final String wireName = r'BoardingScanPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingScanPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pass';
    yield serializers.serialize(
      object.pass,
      specifiedType: const FullType(String),
    );
    if (object.tripId != null) {
      yield r'tripId';
      yield serializers.serialize(
        object.tripId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingScanPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingScanPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pass':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pass = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingScanPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingScanPostRequestBuilder();
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

