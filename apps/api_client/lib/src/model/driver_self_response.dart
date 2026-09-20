//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/driver_self.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_self_response.g.dart';

/// DriverSelfResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class DriverSelfResponse implements Built<DriverSelfResponse, DriverSelfResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DriverSelf get data;

  DriverSelfResponse._();

  factory DriverSelfResponse([void updates(DriverSelfResponseBuilder b)]) = _$DriverSelfResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverSelfResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverSelfResponse> get serializer => _$DriverSelfResponseSerializer();
}

class _$DriverSelfResponseSerializer implements PrimitiveSerializer<DriverSelfResponse> {
  @override
  final Iterable<Type> types = const [DriverSelfResponse, _$DriverSelfResponse];

  @override
  final String wireName = r'DriverSelfResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverSelfResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DriverSelf),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverSelfResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverSelfResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverSelf),
          ) as DriverSelf;
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
  DriverSelfResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverSelfResponseBuilder();
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

