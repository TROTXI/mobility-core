//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/auto_renewal_card.dart';
import 'package:trotxi_api_client/src/model/auto_renewal_upcoming.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_renewal.g.dart';

/// AutoRenewal
///
/// Properties:
/// * [enabled]
/// * [card]
/// * [upcoming]
@BuiltValue()
abstract class AutoRenewal implements Built<AutoRenewal, AutoRenewalBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'card')
  AutoRenewalCard? get card;

  @BuiltValueField(wireName: r'upcoming')
  AutoRenewalUpcoming? get upcoming;

  AutoRenewal._();

  factory AutoRenewal([void updates(AutoRenewalBuilder b)]) = _$AutoRenewal;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoRenewalBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoRenewal> get serializer => _$AutoRenewalSerializer();
}

class _$AutoRenewalSerializer implements PrimitiveSerializer<AutoRenewal> {
  @override
  final Iterable<Type> types = const [AutoRenewal, _$AutoRenewal];

  @override
  final String wireName = r'AutoRenewal';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoRenewal object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'card';
    yield object.card == null
        ? null
        : serializers.serialize(
            object.card,
            specifiedType: const FullType.nullable(AutoRenewalCard),
          );
    yield r'upcoming';
    yield object.upcoming == null
        ? null
        : serializers.serialize(
            object.upcoming,
            specifiedType: const FullType.nullable(AutoRenewalUpcoming),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoRenewal object, {
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
    required AutoRenewalBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'card':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AutoRenewalCard),
          ) as AutoRenewalCard?;
          if (valueDes == null) continue;
          result.card.replace(valueDes);
          break;
        case r'upcoming':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AutoRenewalUpcoming),
          ) as AutoRenewalUpcoming?;
          if (valueDes == null) continue;
          result.upcoming.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoRenewal deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoRenewalBuilder();
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
