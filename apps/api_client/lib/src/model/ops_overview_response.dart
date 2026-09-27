//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_overview.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_overview_response.g.dart';

/// OpsOverviewResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OpsOverviewResponse implements Built<OpsOverviewResponse, OpsOverviewResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsOverview get data;

  OpsOverviewResponse._();

  factory OpsOverviewResponse([void updates(OpsOverviewResponseBuilder b)]) = _$OpsOverviewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsOverviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsOverviewResponse> get serializer => _$OpsOverviewResponseSerializer();
}

class _$OpsOverviewResponseSerializer implements PrimitiveSerializer<OpsOverviewResponse> {
  @override
  final Iterable<Type> types = const [OpsOverviewResponse, _$OpsOverviewResponse];

  @override
  final String wireName = r'OpsOverviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsOverviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsOverview),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsOverviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsOverviewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsOverview),
          ) as OpsOverview;
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
  OpsOverviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsOverviewResponseBuilder();
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

