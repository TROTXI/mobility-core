//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/auto_renewal.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_renewal_response.g.dart';

/// AutoRenewalResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class AutoRenewalResponse
    implements Built<AutoRenewalResponse, AutoRenewalResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  AutoRenewal get data;

  AutoRenewalResponse._();

  factory AutoRenewalResponse([void updates(AutoRenewalResponseBuilder b)]) =
      _$AutoRenewalResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoRenewalResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoRenewalResponse> get serializer =>
      _$AutoRenewalResponseSerializer();
}

class _$AutoRenewalResponseSerializer
    implements PrimitiveSerializer<AutoRenewalResponse> {
  @override
  final Iterable<Type> types = const [
    AutoRenewalResponse,
    _$AutoRenewalResponse
  ];

  @override
  final String wireName = r'AutoRenewalResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoRenewalResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(AutoRenewal),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoRenewalResponse object, {
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
    required AutoRenewalResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AutoRenewal),
          ) as AutoRenewal;
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
  AutoRenewalResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoRenewalResponseBuilder();
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
