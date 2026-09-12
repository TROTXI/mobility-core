//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/admin_learn_routes_post200_response_routes_inner_segments_learned.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_learn_routes_post200_response_routes_inner.g.dart';

/// AdminLearnRoutesPost200ResponseRoutesInner
///
/// Properties:
/// * [routeId] 
/// * [runsUsed] 
/// * [geometryUpdated] 
/// * [segmentsLearned] 
@BuiltValue()
abstract class AdminLearnRoutesPost200ResponseRoutesInner implements Built<AdminLearnRoutesPost200ResponseRoutesInner, AdminLearnRoutesPost200ResponseRoutesInnerBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'runsUsed')
  int get runsUsed;

  @BuiltValueField(wireName: r'geometryUpdated')
  bool get geometryUpdated;

  @BuiltValueField(wireName: r'segmentsLearned')
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned get segmentsLearned;

  AdminLearnRoutesPost200ResponseRoutesInner._();

  factory AdminLearnRoutesPost200ResponseRoutesInner([void updates(AdminLearnRoutesPost200ResponseRoutesInnerBuilder b)]) = _$AdminLearnRoutesPost200ResponseRoutesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLearnRoutesPost200ResponseRoutesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLearnRoutesPost200ResponseRoutesInner> get serializer => _$AdminLearnRoutesPost200ResponseRoutesInnerSerializer();
}

class _$AdminLearnRoutesPost200ResponseRoutesInnerSerializer implements PrimitiveSerializer<AdminLearnRoutesPost200ResponseRoutesInner> {
  @override
  final Iterable<Type> types = const [AdminLearnRoutesPost200ResponseRoutesInner, _$AdminLearnRoutesPost200ResponseRoutesInner];

  @override
  final String wireName = r'AdminLearnRoutesPost200ResponseRoutesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLearnRoutesPost200ResponseRoutesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'runsUsed';
    yield serializers.serialize(
      object.runsUsed,
      specifiedType: const FullType(int),
    );
    yield r'geometryUpdated';
    yield serializers.serialize(
      object.geometryUpdated,
      specifiedType: const FullType(bool),
    );
    yield r'segmentsLearned';
    yield serializers.serialize(
      object.segmentsLearned,
      specifiedType: const FullType(AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLearnRoutesPost200ResponseRoutesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLearnRoutesPost200ResponseRoutesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'runsUsed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.runsUsed = valueDes;
          break;
        case r'geometryUpdated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.geometryUpdated = valueDes;
          break;
        case r'segmentsLearned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned),
          ) as AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned;
          result.segmentsLearned.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLearnRoutesPost200ResponseRoutesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLearnRoutesPost200ResponseRoutesInnerBuilder();
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

