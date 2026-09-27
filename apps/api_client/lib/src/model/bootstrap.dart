//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/bootstrap_applications_inner.dart';
import 'package:trotxi_api_client/src/model/bootstrap_flags_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/bootstrap_map_tiles.dart';
import 'package:trotxi_api_client/src/model/bootstrap_operations.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap.g.dart';

/// Bootstrap
///
/// Properties:
/// * [serverTime] 
/// * [applications] 
/// * [operations] 
/// * [mapTiles] 
/// * [flags] 
@BuiltValue()
abstract class Bootstrap implements Built<Bootstrap, BootstrapBuilder> {
  @BuiltValueField(wireName: r'serverTime')
  DateTime get serverTime;

  @BuiltValueField(wireName: r'applications')
  BuiltList<BootstrapApplicationsInner> get applications;

  @BuiltValueField(wireName: r'operations')
  BootstrapOperations get operations;

  @BuiltValueField(wireName: r'mapTiles')
  BootstrapMapTiles get mapTiles;

  @BuiltValueField(wireName: r'flags')
  BuiltList<BootstrapFlagsInner> get flags;

  Bootstrap._();

  factory Bootstrap([void updates(BootstrapBuilder b)]) = _$Bootstrap;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Bootstrap> get serializer => _$BootstrapSerializer();
}

class _$BootstrapSerializer implements PrimitiveSerializer<Bootstrap> {
  @override
  final Iterable<Type> types = const [Bootstrap, _$Bootstrap];

  @override
  final String wireName = r'Bootstrap';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Bootstrap object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'serverTime';
    yield serializers.serialize(
      object.serverTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'applications';
    yield serializers.serialize(
      object.applications,
      specifiedType: const FullType(BuiltList, [FullType(BootstrapApplicationsInner)]),
    );
    yield r'operations';
    yield serializers.serialize(
      object.operations,
      specifiedType: const FullType(BootstrapOperations),
    );
    yield r'mapTiles';
    yield serializers.serialize(
      object.mapTiles,
      specifiedType: const FullType(BootstrapMapTiles),
    );
    yield r'flags';
    yield serializers.serialize(
      object.flags,
      specifiedType: const FullType(BuiltList, [FullType(BootstrapFlagsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Bootstrap object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'serverTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.serverTime = valueDes;
          break;
        case r'applications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BootstrapApplicationsInner)]),
          ) as BuiltList<BootstrapApplicationsInner>;
          result.applications.replace(valueDes);
          break;
        case r'operations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BootstrapOperations),
          ) as BootstrapOperations;
          result.operations.replace(valueDes);
          break;
        case r'mapTiles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BootstrapMapTiles),
          ) as BootstrapMapTiles;
          result.mapTiles.replace(valueDes);
          break;
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BootstrapFlagsInner)]),
          ) as BuiltList<BootstrapFlagsInner>;
          result.flags.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Bootstrap deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapBuilder();
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

