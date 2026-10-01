//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/verification_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verification_status_response.g.dart';

/// VerificationStatusResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class VerificationStatusResponse
    implements
        Built<VerificationStatusResponse, VerificationStatusResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  VerificationStatus get data;

  VerificationStatusResponse._();

  factory VerificationStatusResponse(
          [void updates(VerificationStatusResponseBuilder b)]) =
      _$VerificationStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerificationStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerificationStatusResponse> get serializer =>
      _$VerificationStatusResponseSerializer();
}

class _$VerificationStatusResponseSerializer
    implements PrimitiveSerializer<VerificationStatusResponse> {
  @override
  final Iterable<Type> types = const [
    VerificationStatusResponse,
    _$VerificationStatusResponse
  ];

  @override
  final String wireName = r'VerificationStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerificationStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(VerificationStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerificationStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VerificationStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VerificationStatus),
          ) as VerificationStatus;
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
  VerificationStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerificationStatusResponseBuilder();
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
