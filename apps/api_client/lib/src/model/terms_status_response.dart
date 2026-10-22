//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/terms_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'terms_status_response.g.dart';

/// TermsStatusResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class TermsStatusResponse
    implements Built<TermsStatusResponse, TermsStatusResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TermsStatus get data;

  TermsStatusResponse._();

  factory TermsStatusResponse([void updates(TermsStatusResponseBuilder b)]) =
      _$TermsStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TermsStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TermsStatusResponse> get serializer =>
      _$TermsStatusResponseSerializer();
}

class _$TermsStatusResponseSerializer
    implements PrimitiveSerializer<TermsStatusResponse> {
  @override
  final Iterable<Type> types = const [
    TermsStatusResponse,
    _$TermsStatusResponse
  ];

  @override
  final String wireName = r'TermsStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TermsStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TermsStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TermsStatusResponse object, {
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
    required TermsStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TermsStatus),
          ) as TermsStatus;
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
  TermsStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TermsStatusResponseBuilder();
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
