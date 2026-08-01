//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_patch_request.g.dart';

/// MePatchRequest
///
/// Properties:
/// * [displayName] 
@BuiltValue()
abstract class MePatchRequest implements Built<MePatchRequest, MePatchRequestBuilder> {
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  MePatchRequest._();

  factory MePatchRequest([void updates(MePatchRequestBuilder b)]) = _$MePatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MePatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MePatchRequest> get serializer => _$MePatchRequestSerializer();
}

class _$MePatchRequestSerializer implements PrimitiveSerializer<MePatchRequest> {
  @override
  final Iterable<Type> types = const [MePatchRequest, _$MePatchRequest];

  @override
  final String wireName = r'MePatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MePatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MePatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MePatchRequestBuilder();
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

