//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'terms_status.g.dart';

/// TermsStatus
///
/// Properties:
/// * [audience]
/// * [currentVersion]
/// * [acceptedVersion]
/// * [acceptanceRequired]
@BuiltValue()
abstract class TermsStatus implements Built<TermsStatus, TermsStatusBuilder> {
  @BuiltValueField(wireName: r'audience')
  TermsStatusAudienceEnum get audience;
  // enum audienceEnum {  commuter,  driver,  };

  @BuiltValueField(wireName: r'currentVersion')
  Date get currentVersion;

  @BuiltValueField(wireName: r'acceptedVersion')
  Date? get acceptedVersion;

  @BuiltValueField(wireName: r'acceptanceRequired')
  bool get acceptanceRequired;

  TermsStatus._();

  factory TermsStatus([void updates(TermsStatusBuilder b)]) = _$TermsStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TermsStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TermsStatus> get serializer => _$TermsStatusSerializer();
}

class _$TermsStatusSerializer implements PrimitiveSerializer<TermsStatus> {
  @override
  final Iterable<Type> types = const [TermsStatus, _$TermsStatus];

  @override
  final String wireName = r'TermsStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TermsStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'audience';
    yield serializers.serialize(
      object.audience,
      specifiedType: const FullType(TermsStatusAudienceEnum),
    );
    yield r'currentVersion';
    yield serializers.serialize(
      object.currentVersion,
      specifiedType: const FullType(Date),
    );
    yield r'acceptedVersion';
    yield object.acceptedVersion == null
        ? null
        : serializers.serialize(
            object.acceptedVersion,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'acceptanceRequired';
    yield serializers.serialize(
      object.acceptanceRequired,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TermsStatus object, {
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
    required TermsStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'audience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TermsStatusAudienceEnum),
          ) as TermsStatusAudienceEnum;
          result.audience = valueDes;
          break;
        case r'currentVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.currentVersion = valueDes;
          break;
        case r'acceptedVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.acceptedVersion = valueDes;
          break;
        case r'acceptanceRequired':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.acceptanceRequired = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TermsStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TermsStatusBuilder();
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

class TermsStatusAudienceEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'commuter')
  static const TermsStatusAudienceEnum commuter =
      _$termsStatusAudienceEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const TermsStatusAudienceEnum driver =
      _$termsStatusAudienceEnum_driver;

  static Serializer<TermsStatusAudienceEnum> get serializer =>
      _$termsStatusAudienceEnumSerializer;

  const TermsStatusAudienceEnum._(String name) : super(name);

  static BuiltSet<TermsStatusAudienceEnum> get values =>
      _$termsStatusAudienceEnumValues;
  static TermsStatusAudienceEnum valueOf(String name) =>
      _$termsStatusAudienceEnumValueOf(name);
}
