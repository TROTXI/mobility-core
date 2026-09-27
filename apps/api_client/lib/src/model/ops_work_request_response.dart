//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_work_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_work_request_response.g.dart';

/// OpsWorkRequestResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class OpsWorkRequestResponse implements Built<OpsWorkRequestResponse, OpsWorkRequestResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class OpsWorkRequestResponse
    implements Built<OpsWorkRequestResponse, OpsWorkRequestResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  OpsWorkRequest get data;

  OpsWorkRequestResponse._();

<<<<<<< HEAD
  factory OpsWorkRequestResponse([void updates(OpsWorkRequestResponseBuilder b)]) = _$OpsWorkRequestResponse;
=======
  factory OpsWorkRequestResponse(
          [void updates(OpsWorkRequestResponseBuilder b)]) =
      _$OpsWorkRequestResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsWorkRequestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<OpsWorkRequestResponse> get serializer => _$OpsWorkRequestResponseSerializer();
}

class _$OpsWorkRequestResponseSerializer implements PrimitiveSerializer<OpsWorkRequestResponse> {
  @override
  final Iterable<Type> types = const [OpsWorkRequestResponse, _$OpsWorkRequestResponse];
=======
  static Serializer<OpsWorkRequestResponse> get serializer =>
      _$OpsWorkRequestResponseSerializer();
}

class _$OpsWorkRequestResponseSerializer
    implements PrimitiveSerializer<OpsWorkRequestResponse> {
  @override
  final Iterable<Type> types = const [
    OpsWorkRequestResponse,
    _$OpsWorkRequestResponse
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'OpsWorkRequestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsWorkRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsWorkRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsWorkRequestResponse object, {
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
    required OpsWorkRequestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsWorkRequest),
          ) as OpsWorkRequest;
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
  OpsWorkRequestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsWorkRequestResponseBuilder();
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
