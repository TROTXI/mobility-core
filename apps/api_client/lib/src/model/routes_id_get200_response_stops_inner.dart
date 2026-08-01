//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'routes_id_get200_response_stops_inner.g.dart';

/// RoutesIdGet200ResponseStopsInner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [latitude] 
/// * [longitude] 
/// * [createdAt] 
/// * [seq] 
@BuiltValue()
abstract class RoutesIdGet200ResponseStopsInner implements Built<RoutesIdGet200ResponseStopsInner, RoutesIdGet200ResponseStopsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'seq')
  int get seq;

  RoutesIdGet200ResponseStopsInner._();

  factory RoutesIdGet200ResponseStopsInner([void updates(RoutesIdGet200ResponseStopsInnerBuilder b)]) = _$RoutesIdGet200ResponseStopsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RoutesIdGet200ResponseStopsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RoutesIdGet200ResponseStopsInner> get serializer => _$RoutesIdGet200ResponseStopsInnerSerializer();
}

class _$RoutesIdGet200ResponseStopsInnerSerializer implements PrimitiveSerializer<RoutesIdGet200ResponseStopsInner> {
  @override
  final Iterable<Type> types = const [RoutesIdGet200ResponseStopsInner, _$RoutesIdGet200ResponseStopsInner];

  @override
  final String wireName = r'RoutesIdGet200ResponseStopsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RoutesIdGet200ResponseStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'seq';
    yield serializers.serialize(
      object.seq,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RoutesIdGet200ResponseStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RoutesIdGet200ResponseStopsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seq = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RoutesIdGet200ResponseStopsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RoutesIdGet200ResponseStopsInnerBuilder();
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

