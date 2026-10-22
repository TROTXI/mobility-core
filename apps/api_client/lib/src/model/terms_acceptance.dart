//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'terms_acceptance.g.dart';

/// TermsAcceptance
///
/// Properties:
/// * [acceptedTerms]
/// * [termsVersion]
@BuiltValue()
abstract class TermsAcceptance
    implements Built<TermsAcceptance, TermsAcceptanceBuilder> {
  @BuiltValueField(wireName: r'acceptedTerms')
  bool get acceptedTerms;

  @BuiltValueField(wireName: r'termsVersion')
  Date get termsVersion;

  TermsAcceptance._();

  factory TermsAcceptance([void updates(TermsAcceptanceBuilder b)]) =
      _$TermsAcceptance;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TermsAcceptanceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TermsAcceptance> get serializer =>
      _$TermsAcceptanceSerializer();
}

class _$TermsAcceptanceSerializer
    implements PrimitiveSerializer<TermsAcceptance> {
  @override
  final Iterable<Type> types = const [TermsAcceptance, _$TermsAcceptance];

  @override
  final String wireName = r'TermsAcceptance';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TermsAcceptance object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'acceptedTerms';
    yield serializers.serialize(
      object.acceptedTerms,
      specifiedType: const FullType(bool),
    );
    yield r'termsVersion';
    yield serializers.serialize(
      object.termsVersion,
      specifiedType: const FullType(Date),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TermsAcceptance object, {
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
    required TermsAcceptanceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'acceptedTerms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.acceptedTerms = valueDes;
          break;
        case r'termsVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.termsVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TermsAcceptance deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TermsAcceptanceBuilder();
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
