//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/maintenance_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'maintenance_result_response.g.dart';

/// MaintenanceResultResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class MaintenanceResultResponse implements Built<MaintenanceResultResponse, MaintenanceResultResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class MaintenanceResultResponse
    implements
        Built<MaintenanceResultResponse, MaintenanceResultResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  MaintenanceResult get data;

  MaintenanceResultResponse._();

<<<<<<< HEAD
  factory MaintenanceResultResponse([void updates(MaintenanceResultResponseBuilder b)]) = _$MaintenanceResultResponse;
=======
  factory MaintenanceResultResponse(
          [void updates(MaintenanceResultResponseBuilder b)]) =
      _$MaintenanceResultResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MaintenanceResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<MaintenanceResultResponse> get serializer => _$MaintenanceResultResponseSerializer();
}

class _$MaintenanceResultResponseSerializer implements PrimitiveSerializer<MaintenanceResultResponse> {
  @override
  final Iterable<Type> types = const [MaintenanceResultResponse, _$MaintenanceResultResponse];
=======
  static Serializer<MaintenanceResultResponse> get serializer =>
      _$MaintenanceResultResponseSerializer();
}

class _$MaintenanceResultResponseSerializer
    implements PrimitiveSerializer<MaintenanceResultResponse> {
  @override
  final Iterable<Type> types = const [
    MaintenanceResultResponse,
    _$MaintenanceResultResponse
  ];
>>>>>>> origin/main

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
<<<<<<< HEAD

=======
>>>>>>> origin/main
