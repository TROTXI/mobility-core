//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/standby_application.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_application_response.g.dart';

/// StandbyApplicationResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class StandbyApplicationResponse
    implements
        Built<StandbyApplicationResponse, StandbyApplicationResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  StandbyApplication get data;

  StandbyApplicationResponse._();

  factory StandbyApplicationResponse(
          [void updates(StandbyApplicationResponseBuilder b)]) =
      _$StandbyApplicationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyApplicationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyApplicationResponse> get serializer =>
      _$StandbyApplicationResponseSerializer();
}

class _$StandbyApplicationResponseSerializer
    implements PrimitiveSerializer<StandbyApplicationResponse> {
  @override
  final Iterable<Type> types = const [
    StandbyApplicationResponse,
    _$StandbyApplicationResponse
  ];

  @override
  final String wireName = r'StandbyApplicationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyApplicationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(StandbyApplication),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyApplicationResponse object, {
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
    required StandbyApplicationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandbyApplication),
          ) as StandbyApplication;
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
  StandbyApplicationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyApplicationResponseBuilder();
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
