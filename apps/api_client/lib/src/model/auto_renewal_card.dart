//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_renewal_card.g.dart';

/// AutoRenewalCard
///
/// Properties:
/// * [brand]
/// * [last4]
/// * [expMonth]
/// * [expYear]
@BuiltValue()
abstract class AutoRenewalCard
    implements Built<AutoRenewalCard, AutoRenewalCardBuilder> {
  @BuiltValueField(wireName: r'brand')
  String get brand;

  @BuiltValueField(wireName: r'last4')
  String get last4;

  @BuiltValueField(wireName: r'expMonth')
  int get expMonth;

  @BuiltValueField(wireName: r'expYear')
  int get expYear;

  AutoRenewalCard._();

  factory AutoRenewalCard([void updates(AutoRenewalCardBuilder b)]) =
      _$AutoRenewalCard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoRenewalCardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoRenewalCard> get serializer =>
      _$AutoRenewalCardSerializer();
}

class _$AutoRenewalCardSerializer
    implements PrimitiveSerializer<AutoRenewalCard> {
  @override
  final Iterable<Type> types = const [AutoRenewalCard, _$AutoRenewalCard];

  @override
  final String wireName = r'AutoRenewalCard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoRenewalCard object, {
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
    yield r'expMonth';
    yield serializers.serialize(
      object.expMonth,
      specifiedType: const FullType(int),
    );
    yield r'expYear';
    yield serializers.serialize(
      object.expYear,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoRenewalCard object, {
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
    required AutoRenewalCardBuilder result,
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
        case r'expMonth':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expMonth = valueDes;
          break;
        case r'expYear':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expYear = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoRenewalCard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoRenewalCardBuilder();
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
