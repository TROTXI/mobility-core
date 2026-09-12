//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_requests_post_request_one_of.g.dart';

/// MeWorkRequestsPostRequestOneOf
///
/// Properties:
/// * [kind] 
/// * [routeId] 
/// * [fromDate] 
/// * [note] 
@BuiltValue()
abstract class MeWorkRequestsPostRequestOneOf implements Built<MeWorkRequestsPostRequestOneOf, MeWorkRequestsPostRequestOneOfBuilder> {
  @BuiltValueField(wireName: r'kind')
  MeWorkRequestsPostRequestOneOfKindEnum get kind;
  // enum kindEnum {  route_change,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'fromDate')
  String? get fromDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  MeWorkRequestsPostRequestOneOf._();

  factory MeWorkRequestsPostRequestOneOf([void updates(MeWorkRequestsPostRequestOneOfBuilder b)]) = _$MeWorkRequestsPostRequestOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRequestsPostRequestOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRequestsPostRequestOneOf> get serializer => _$MeWorkRequestsPostRequestOneOfSerializer();
}

class _$MeWorkRequestsPostRequestOneOfSerializer implements PrimitiveSerializer<MeWorkRequestsPostRequestOneOf> {
  @override
  final Iterable<Type> types = const [MeWorkRequestsPostRequestOneOf, _$MeWorkRequestsPostRequestOneOf];

  @override
  final String wireName = r'MeWorkRequestsPostRequestOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRequestsPostRequestOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(MeWorkRequestsPostRequestOneOfKindEnum),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    if (object.fromDate != null) {
      yield r'fromDate';
      yield serializers.serialize(
        object.fromDate,
        specifiedType: const FullType(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRequestsPostRequestOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRequestsPostRequestOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeWorkRequestsPostRequestOneOfKindEnum),
          ) as MeWorkRequestsPostRequestOneOfKindEnum;
          result.kind = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromDate = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeWorkRequestsPostRequestOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRequestsPostRequestOneOfBuilder();
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

class MeWorkRequestsPostRequestOneOfKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'route_change')
  static const MeWorkRequestsPostRequestOneOfKindEnum routeChange = _$meWorkRequestsPostRequestOneOfKindEnum_routeChange;

  static Serializer<MeWorkRequestsPostRequestOneOfKindEnum> get serializer => _$meWorkRequestsPostRequestOneOfKindEnumSerializer;

  const MeWorkRequestsPostRequestOneOfKindEnum._(String name): super(name);

  static BuiltSet<MeWorkRequestsPostRequestOneOfKindEnum> get values => _$meWorkRequestsPostRequestOneOfKindEnumValues;
  static MeWorkRequestsPostRequestOneOfKindEnum valueOf(String name) => _$meWorkRequestsPostRequestOneOfKindEnumValueOf(name);
}

