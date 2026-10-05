//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_auto_renewal_card.g.dart';

/// OpsAutoRenewalCard
///
/// Properties:
/// * [brand]
/// * [last4]
@BuiltValue()
abstract class OpsAutoRenewalCard
    implements Built<OpsAutoRenewalCard, OpsAutoRenewalCardBuilder> {
  @BuiltValueField(wireName: r'brand')
  String get brand;

  @BuiltValueField(wireName: r'last4')
  String get last4;

  OpsAutoRenewalCard._();

  factory OpsAutoRenewalCard([void updates(OpsAutoRenewalCardBuilder b)]) =
      _$OpsAutoRenewalCard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAutoRenewalCardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAutoRenewalCard> get serializer =>
      _$OpsAutoRenewalCardSerializer();
}

class _$OpsAutoRenewalCardSerializer
    implements PrimitiveSerializer<OpsAutoRenewalCard> {
  @override
  final Iterable<Type> types = const [OpsAutoRenewalCard, _$OpsAutoRenewalCard];

  @override
  final String wireName = r'OpsAutoRenewalCard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAutoRenewalCard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'brand';
    yield serializers.serialize(
      object.brand,
      specifiedType: const FullType(String),
    );
    yield r'last4';
    yield serializers.serialize(
      object.last4,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsAutoRenewalCard object, {
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
    required OpsAutoRenewalCardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'brand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.brand = valueDes;
          break;
        case r'last4':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.last4 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsAutoRenewalCard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAutoRenewalCardBuilder();
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
