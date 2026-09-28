//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_rider_detail.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_detail_response.g.dart';

/// OpsRiderDetailResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OpsRiderDetailResponse
    implements Built<OpsRiderDetailResponse, OpsRiderDetailResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsRiderDetail get data;

  OpsRiderDetailResponse._();

  factory OpsRiderDetailResponse(
          [void updates(OpsRiderDetailResponseBuilder b)]) =
      _$OpsRiderDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderDetailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderDetailResponse> get serializer =>
      _$OpsRiderDetailResponseSerializer();
}

class _$OpsRiderDetailResponseSerializer
    implements PrimitiveSerializer<OpsRiderDetailResponse> {
  @override
  final Iterable<Type> types = const [
    OpsRiderDetailResponse,
    _$OpsRiderDetailResponse
  ];

  @override
  final String wireName = r'OpsRiderDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsRiderDetail),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderDetailResponse object, {
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
    required OpsRiderDetailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRiderDetail),
          ) as OpsRiderDetail;
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
  OpsRiderDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderDetailResponseBuilder();
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
