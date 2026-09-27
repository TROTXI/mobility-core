//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'access_block.g.dart';

/// AccessBlock
///
/// Properties:
/// * [kind] 
/// * [scope] 
/// * [periodId] 
@BuiltValue()
abstract class AccessBlock implements Built<AccessBlock, AccessBlockBuilder> {
  @BuiltValueField(wireName: r'kind')
  AccessBlockKindEnum get kind;
  // enum kindEnum {  paused,  dispute,  ops_restriction,  };

  @BuiltValueField(wireName: r'scope')
  AccessBlockScopeEnum get scope;
  // enum scopeEnum {  period,  account,  };

  @BuiltValueField(wireName: r'periodId')
  String? get periodId;

  AccessBlock._();

  factory AccessBlock([void updates(AccessBlockBuilder b)]) = _$AccessBlock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccessBlockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccessBlock> get serializer => _$AccessBlockSerializer();
}

class _$AccessBlockSerializer implements PrimitiveSerializer<AccessBlock> {
  @override
  final Iterable<Type> types = const [AccessBlock, _$AccessBlock];

  @override
  final String wireName = r'AccessBlock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccessBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(AccessBlockKindEnum),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(AccessBlockScopeEnum),
    );
    yield r'periodId';
    yield object.periodId == null ? null : serializers.serialize(
      object.periodId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccessBlock object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AccessBlockBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AccessBlockKindEnum),
          ) as AccessBlockKindEnum;
          result.kind = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AccessBlockScopeEnum),
          ) as AccessBlockScopeEnum;
          result.scope = valueDes;
          break;
        case r'periodId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.periodId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccessBlock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccessBlockBuilder();
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

class AccessBlockKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'paused')
  static const AccessBlockKindEnum paused = _$accessBlockKindEnum_paused;
  @BuiltValueEnumConst(wireName: r'dispute')
  static const AccessBlockKindEnum dispute = _$accessBlockKindEnum_dispute;
  @BuiltValueEnumConst(wireName: r'ops_restriction')
  static const AccessBlockKindEnum opsRestriction = _$accessBlockKindEnum_opsRestriction;

  static Serializer<AccessBlockKindEnum> get serializer => _$accessBlockKindEnumSerializer;

  const AccessBlockKindEnum._(String name): super(name);

  static BuiltSet<AccessBlockKindEnum> get values => _$accessBlockKindEnumValues;
  static AccessBlockKindEnum valueOf(String name) => _$accessBlockKindEnumValueOf(name);
}

class AccessBlockScopeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'period')
  static const AccessBlockScopeEnum period = _$accessBlockScopeEnum_period;
  @BuiltValueEnumConst(wireName: r'account')
  static const AccessBlockScopeEnum account = _$accessBlockScopeEnum_account;

  static Serializer<AccessBlockScopeEnum> get serializer => _$accessBlockScopeEnumSerializer;

  const AccessBlockScopeEnum._(String name): super(name);

  static BuiltSet<AccessBlockScopeEnum> get values => _$accessBlockScopeEnumValues;
  static AccessBlockScopeEnum valueOf(String name) => _$accessBlockScopeEnumValueOf(name);
}

