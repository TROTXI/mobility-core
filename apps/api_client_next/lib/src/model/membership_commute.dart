//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:trotxi_api_client_next/src/model/commute_leg_view.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'membership_commute.g.dart';

/// MembershipCommute
///
/// Properties:
/// * [id] 
/// * [routeId] 
/// * [routeName] 
/// * [effectiveFrom] 
/// * [effectiveTo] 
/// * [legs] 
@BuiltValue()
abstract class MembershipCommute implements Built<MembershipCommute, MembershipCommuteBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'routeName')
  String get routeName;

  @BuiltValueField(wireName: r'effectiveFrom')
  Date get effectiveFrom;

  @BuiltValueField(wireName: r'effectiveTo')
  Date? get effectiveTo;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLegView> get legs;

  MembershipCommute._();

  factory MembershipCommute([void updates(MembershipCommuteBuilder b)]) = _$MembershipCommute;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MembershipCommuteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MembershipCommute> get serializer => _$MembershipCommuteSerializer();
}

class _$MembershipCommuteSerializer implements PrimitiveSerializer<MembershipCommute> {
  @override
  final Iterable<Type> types = const [MembershipCommute, _$MembershipCommute];

  @override
  final String wireName = r'MembershipCommute';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MembershipCommute object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'routeName';
    yield serializers.serialize(
      object.routeName,
      specifiedType: const FullType(String),
    );
    yield r'effectiveFrom';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(Date),
    );
    yield r'effectiveTo';
    yield object.effectiveTo == null ? null : serializers.serialize(
      object.effectiveTo,
      specifiedType: const FullType.nullable(Date),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType: const FullType(BuiltList, [FullType(CommuteLegView)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MembershipCommute object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MembershipCommuteBuilder result,
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
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'routeName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeName = valueDes;
          break;
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.effectiveFrom = valueDes;
          break;
        case r'effectiveTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.effectiveTo = valueDes;
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteLegView)]),
          ) as BuiltList<CommuteLegView>;
          result.legs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MembershipCommute deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MembershipCommuteBuilder();
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

