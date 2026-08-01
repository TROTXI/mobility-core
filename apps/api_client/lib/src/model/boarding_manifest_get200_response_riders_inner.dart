//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'boarding_manifest_get200_response_riders_inner.g.dart';

/// BoardingManifestGet200ResponseRidersInner
///
/// Properties:
/// * [reservationId] 
/// * [userId] 
/// * [name] 
/// * [avatarUrl] 
/// * [direction] 
/// * [boarded] 
@BuiltValue()
abstract class BoardingManifestGet200ResponseRidersInner implements Built<BoardingManifestGet200ResponseRidersInner, BoardingManifestGet200ResponseRidersInnerBuilder> {
  @BuiltValueField(wireName: r'reservationId')
  String get reservationId;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'direction')
  BoardingManifestGet200ResponseRidersInnerDirectionEnum get direction;
  // enum directionEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'boarded')
  bool get boarded;

  BoardingManifestGet200ResponseRidersInner._();

  factory BoardingManifestGet200ResponseRidersInner([void updates(BoardingManifestGet200ResponseRidersInnerBuilder b)]) = _$BoardingManifestGet200ResponseRidersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BoardingManifestGet200ResponseRidersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BoardingManifestGet200ResponseRidersInner> get serializer => _$BoardingManifestGet200ResponseRidersInnerSerializer();
}

class _$BoardingManifestGet200ResponseRidersInnerSerializer implements PrimitiveSerializer<BoardingManifestGet200ResponseRidersInner> {
  @override
  final Iterable<Type> types = const [BoardingManifestGet200ResponseRidersInner, _$BoardingManifestGet200ResponseRidersInner];

  @override
  final String wireName = r'BoardingManifestGet200ResponseRidersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BoardingManifestGet200ResponseRidersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservationId';
    yield serializers.serialize(
      object.reservationId,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null ? null : serializers.serialize(
      object.name,
      specifiedType: const FullType.nullable(String),
    );
    yield r'avatarUrl';
    yield object.avatarUrl == null ? null : serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(BoardingManifestGet200ResponseRidersInnerDirectionEnum),
    );
    yield r'boarded';
    yield serializers.serialize(
      object.boarded,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BoardingManifestGet200ResponseRidersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BoardingManifestGet200ResponseRidersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservationId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reservationId = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BoardingManifestGet200ResponseRidersInnerDirectionEnum),
          ) as BoardingManifestGet200ResponseRidersInnerDirectionEnum;
          result.direction = valueDes;
          break;
        case r'boarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.boarded = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BoardingManifestGet200ResponseRidersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BoardingManifestGet200ResponseRidersInnerBuilder();
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

class BoardingManifestGet200ResponseRidersInnerDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const BoardingManifestGet200ResponseRidersInnerDirectionEnum morning = _$boardingManifestGet200ResponseRidersInnerDirectionEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const BoardingManifestGet200ResponseRidersInnerDirectionEnum evening = _$boardingManifestGet200ResponseRidersInnerDirectionEnum_evening;

  static Serializer<BoardingManifestGet200ResponseRidersInnerDirectionEnum> get serializer => _$boardingManifestGet200ResponseRidersInnerDirectionEnumSerializer;

  const BoardingManifestGet200ResponseRidersInnerDirectionEnum._(String name): super(name);

  static BuiltSet<BoardingManifestGet200ResponseRidersInnerDirectionEnum> get values => _$boardingManifestGet200ResponseRidersInnerDirectionEnumValues;
  static BoardingManifestGet200ResponseRidersInnerDirectionEnum valueOf(String name) => _$boardingManifestGet200ResponseRidersInnerDirectionEnumValueOf(name);
}

