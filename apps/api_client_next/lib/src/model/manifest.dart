//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/manifest_rider.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'manifest.g.dart';

/// Manifest
///
/// Properties:
/// * [tripId] 
/// * [revision] 
/// * [generatedAt] 
/// * [expiresAt] 
/// * [complete] 
/// * [riders] 
@BuiltValue()
abstract class Manifest implements Built<Manifest, ManifestBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'revision')
  String get revision;

  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'complete')
  bool get complete;

  @BuiltValueField(wireName: r'riders')
  BuiltList<ManifestRider> get riders;

  Manifest._();

  factory Manifest([void updates(ManifestBuilder b)]) = _$Manifest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ManifestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Manifest> get serializer => _$ManifestSerializer();
}

class _$ManifestSerializer implements PrimitiveSerializer<Manifest> {
  @override
  final Iterable<Type> types = const [Manifest, _$Manifest];

  @override
  final String wireName = r'Manifest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Manifest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(String),
    );
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'complete';
    yield serializers.serialize(
      object.complete,
      specifiedType: const FullType(bool),
    );
    yield r'riders';
    yield serializers.serialize(
      object.riders,
      specifiedType: const FullType(BuiltList, [FullType(ManifestRider)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Manifest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ManifestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.revision = valueDes;
          break;
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'complete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.complete = valueDes;
          break;
        case r'riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ManifestRider)]),
          ) as BuiltList<ManifestRider>;
          result.riders.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Manifest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ManifestBuilder();
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

