//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/ops_commute_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_commute_request_response.g.dart';

/// OpsCommuteRequestResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OpsCommuteRequestResponse implements Built<OpsCommuteRequestResponse, OpsCommuteRequestResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsCommuteRequest get data;

  OpsCommuteRequestResponse._();

  factory OpsCommuteRequestResponse([void updates(OpsCommuteRequestResponseBuilder b)]) = _$OpsCommuteRequestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsCommuteRequestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsCommuteRequestResponse> get serializer => _$OpsCommuteRequestResponseSerializer();
}

class _$OpsCommuteRequestResponseSerializer implements PrimitiveSerializer<OpsCommuteRequestResponse> {
  @override
  final Iterable<Type> types = const [OpsCommuteRequestResponse, _$OpsCommuteRequestResponse];

  @override
  final String wireName = r'OpsCommuteRequestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsCommuteRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsCommuteRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsCommuteRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsCommuteRequestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsCommuteRequest),
          ) as OpsCommuteRequest;
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
  OpsCommuteRequestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsCommuteRequestResponseBuilder();
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

