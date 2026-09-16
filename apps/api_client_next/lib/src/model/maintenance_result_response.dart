//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/maintenance_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'maintenance_result_response.g.dart';

/// MaintenanceResultResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class MaintenanceResultResponse implements Built<MaintenanceResultResponse, MaintenanceResultResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  MaintenanceResult get data;

  MaintenanceResultResponse._();

  factory MaintenanceResultResponse([void updates(MaintenanceResultResponseBuilder b)]) = _$MaintenanceResultResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaintenanceResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MaintenanceResultResponse> get serializer => _$MaintenanceResultResponseSerializer();
}

class _$MaintenanceResultResponseSerializer implements PrimitiveSerializer<MaintenanceResultResponse> {
  @override
  final Iterable<Type> types = const [MaintenanceResultResponse, _$MaintenanceResultResponse];

  @override
  final String wireName = r'MaintenanceResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MaintenanceResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(MaintenanceResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MaintenanceResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MaintenanceResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MaintenanceResult),
          ) as MaintenanceResult;
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
  MaintenanceResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MaintenanceResultResponseBuilder();
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

