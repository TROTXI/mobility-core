//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/boarding_manifest_get200_response_riders_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_manifest_get200_response.g.dart';

/// BoardingManifestGet200Response
///
/// Properties:
/// * [tripId] 
/// * [riders] 
@BuiltValue()
abstract class BoardingManifestGet200Response implements Built<BoardingManifestGet200Response, BoardingManifestGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'riders')
  BuiltList<BoardingManifestGet200ResponseRidersInner> get riders;

  BoardingManifestGet200Response._();

  factory BoardingManifestGet200Response([void updates(BoardingManifestGet200ResponseBuilder b)]) = _$BoardingManifestGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingManifestGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingManifestGet200Response> get serializer => _$BoardingManifestGet200ResponseSerializer();
}

class _$BoardingManifestGet200ResponseSerializer implements PrimitiveSerializer<BoardingManifestGet200Response> {
  @override
  final Iterable<Type> types = const [BoardingManifestGet200Response, _$BoardingManifestGet200Response];

  @override
  final String wireName = r'BoardingManifestGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingManifestGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'riders';
    yield serializers.serialize(
      object.riders,
      specifiedType: const FullType(BuiltList, [FullType(BoardingManifestGet200ResponseRidersInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingManifestGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingManifestGet200ResponseBuilder result,
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
        case r'riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BoardingManifestGet200ResponseRidersInner)]),
          ) as BuiltList<BoardingManifestGet200ResponseRidersInner>;
          result.riders.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingManifestGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingManifestGet200ResponseBuilder();
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

