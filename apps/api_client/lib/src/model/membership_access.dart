//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/access_block.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_access.g.dart';

/// MembershipAccess
///
/// Properties:
/// * [canReserve] 
/// * [blocks] 
@BuiltValue()
abstract class MembershipAccess implements Built<MembershipAccess, MembershipAccessBuilder> {
  @BuiltValueField(wireName: r'canReserve')
  bool get canReserve;

  @BuiltValueField(wireName: r'blocks')
  BuiltList<AccessBlock> get blocks;

  MembershipAccess._();

  factory MembershipAccess([void updates(MembershipAccessBuilder b)]) = _$MembershipAccess;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipAccessBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipAccess> get serializer => _$MembershipAccessSerializer();
}

class _$MembershipAccessSerializer implements PrimitiveSerializer<MembershipAccess> {
  @override
  final Iterable<Type> types = const [MembershipAccess, _$MembershipAccess];

  @override
  final String wireName = r'MembershipAccess';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipAccess object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'canReserve';
    yield serializers.serialize(
      object.canReserve,
      specifiedType: const FullType(bool),
    );
    yield r'blocks';
    yield serializers.serialize(
      object.blocks,
      specifiedType: const FullType(BuiltList, [FullType(AccessBlock)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipAccess object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipAccessBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'canReserve':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canReserve = valueDes;
          break;
        case r'blocks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AccessBlock)]),
          ) as BuiltList<AccessBlock>;
          result.blocks.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipAccess deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipAccessBuilder();
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

