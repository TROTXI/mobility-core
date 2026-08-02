//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/flags_get200_response_flags_inner.dart';
import 'package:trotxi_api_client/src/model/flags_get200_response_min_supported_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flags_get200_response.g.dart';

/// FlagsGet200Response
///
/// Properties:
/// * [flags] 
/// * [minSupportedVersion] 
@BuiltValue()
abstract class FlagsGet200Response implements Built<FlagsGet200Response, FlagsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'flags')
  BuiltList<FlagsGet200ResponseFlagsInner> get flags;

  @BuiltValueField(wireName: r'minSupportedVersion')
  FlagsGet200ResponseMinSupportedVersion get minSupportedVersion;

  FlagsGet200Response._();

  factory FlagsGet200Response([void updates(FlagsGet200ResponseBuilder b)]) = _$FlagsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagsGet200Response> get serializer => _$FlagsGet200ResponseSerializer();
}

class _$FlagsGet200ResponseSerializer implements PrimitiveSerializer<FlagsGet200Response> {
  @override
  final Iterable<Type> types = const [FlagsGet200Response, _$FlagsGet200Response];

  @override
  final String wireName = r'FlagsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'flags';
    yield serializers.serialize(
      object.flags,
      specifiedType: const FullType(BuiltList, [FullType(FlagsGet200ResponseFlagsInner)]),
    );
    yield r'minSupportedVersion';
    yield serializers.serialize(
      object.minSupportedVersion,
      specifiedType: const FullType(FlagsGet200ResponseMinSupportedVersion),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FlagsGet200ResponseFlagsInner)]),
          ) as BuiltList<FlagsGet200ResponseFlagsInner>;
          result.flags.replace(valueDes);
          break;
        case r'minSupportedVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FlagsGet200ResponseMinSupportedVersion),
          ) as FlagsGet200ResponseMinSupportedVersion;
          result.minSupportedVersion.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagsGet200ResponseBuilder();
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

