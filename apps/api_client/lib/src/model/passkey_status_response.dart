//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/passkey_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_status_response.g.dart';

/// PasskeyStatusResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PasskeyStatusResponse
    implements Built<PasskeyStatusResponse, PasskeyStatusResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PasskeyStatus get data;

  PasskeyStatusResponse._();

  factory PasskeyStatusResponse(
      [void updates(PasskeyStatusResponseBuilder b)]) = _$PasskeyStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyStatusResponse> get serializer =>
      _$PasskeyStatusResponseSerializer();
}

class _$PasskeyStatusResponseSerializer
    implements PrimitiveSerializer<PasskeyStatusResponse> {
  @override
  final Iterable<Type> types = const [
    PasskeyStatusResponse,
    _$PasskeyStatusResponse
  ];

  @override
  final String wireName = r'PasskeyStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PasskeyStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyStatusResponse object, {
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
    required PasskeyStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyStatus),
          ) as PasskeyStatus;
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
  PasskeyStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyStatusResponseBuilder();
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
