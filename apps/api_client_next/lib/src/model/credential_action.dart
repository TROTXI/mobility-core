//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_action.g.dart';

/// CredentialAction
///
/// Properties:
/// * [action] 
/// * [reason] 
@BuiltValue()
abstract class CredentialAction implements Built<CredentialAction, CredentialActionBuilder> {
  @BuiltValueField(wireName: r'action')
  CredentialActionActionEnum get action;
  // enum actionEnum {  suspend,  activate,  unlock,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  CredentialAction._();

  factory CredentialAction([void updates(CredentialActionBuilder b)]) = _$CredentialAction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialActionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialAction> get serializer => _$CredentialActionSerializer();
}

class _$CredentialActionSerializer implements PrimitiveSerializer<CredentialAction> {
  @override
  final Iterable<Type> types = const [CredentialAction, _$CredentialAction];

  @override
  final String wireName = r'CredentialAction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialAction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CredentialActionActionEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CredentialAction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CredentialActionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CredentialActionActionEnum),
          ) as CredentialActionActionEnum;
          result.action = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CredentialAction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialActionBuilder();
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

class CredentialActionActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'suspend')
  static const CredentialActionActionEnum suspend = _$credentialActionActionEnum_suspend;
  @BuiltValueEnumConst(wireName: r'activate')
  static const CredentialActionActionEnum activate = _$credentialActionActionEnum_activate;
  @BuiltValueEnumConst(wireName: r'unlock')
  static const CredentialActionActionEnum unlock = _$credentialActionActionEnum_unlock;

  static Serializer<CredentialActionActionEnum> get serializer => _$credentialActionActionEnumSerializer;

  const CredentialActionActionEnum._(String name): super(name);

  static BuiltSet<CredentialActionActionEnum> get values => _$credentialActionActionEnumValues;
  static CredentialActionActionEnum valueOf(String name) => _$credentialActionActionEnumValueOf(name);
}

