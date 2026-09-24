//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/me_work_requests_post_request_one_of.dart';
import 'package:trotxi_api_client/src/model/me_work_requests_post_request_one_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'me_work_requests_post_request.g.dart';

/// MeWorkRequestsPostRequest
///
/// Properties:
/// * [kind]
/// * [routeId]
/// * [fromDate]
/// * [note]
/// * [toDate]
@BuiltValue()
abstract class MeWorkRequestsPostRequest
    implements
        Built<MeWorkRequestsPostRequest, MeWorkRequestsPostRequestBuilder> {
  /// One Of [MeWorkRequestsPostRequestOneOf], [MeWorkRequestsPostRequestOneOf1]
  OneOf get oneOf;

  MeWorkRequestsPostRequest._();

  factory MeWorkRequestsPostRequest(
          [void updates(MeWorkRequestsPostRequestBuilder b)]) =
      _$MeWorkRequestsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRequestsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRequestsPostRequest> get serializer =>
      _$MeWorkRequestsPostRequestSerializer();
}

class _$MeWorkRequestsPostRequestSerializer
    implements PrimitiveSerializer<MeWorkRequestsPostRequest> {
  @override
  final Iterable<Type> types = const [
    MeWorkRequestsPostRequest,
    _$MeWorkRequestsPostRequest
  ];

  @override
  final String wireName = r'MeWorkRequestsPostRequest';

  Iterable<Object?> _serializeProperties(
      Serializers serializers, MeWorkRequestsPostRequest object) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRequestsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value,
        specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  MeWorkRequestsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRequestsPostRequestBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [
      FullType(MeWorkRequestsPostRequestOneOf),
      FullType(MeWorkRequestsPostRequestOneOf1),
    ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc,
        specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class MeWorkRequestsPostRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'leave')
  static const MeWorkRequestsPostRequestKindEnum leave =
      _$meWorkRequestsPostRequestKindEnum_leave;

  static Serializer<MeWorkRequestsPostRequestKindEnum> get serializer =>
      _$meWorkRequestsPostRequestKindEnumSerializer;

  const MeWorkRequestsPostRequestKindEnum._(String name) : super(name);

  static BuiltSet<MeWorkRequestsPostRequestKindEnum> get values =>
      _$meWorkRequestsPostRequestKindEnumValues;
  static MeWorkRequestsPostRequestKindEnum valueOf(String name) =>
      _$meWorkRequestsPostRequestKindEnumValueOf(name);
}
