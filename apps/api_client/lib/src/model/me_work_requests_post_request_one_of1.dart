//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_requests_post_request_one_of1.g.dart';

/// MeWorkRequestsPostRequestOneOf1
///
/// Properties:
/// * [kind] 
/// * [fromDate] 
/// * [toDate] 
/// * [note] 
@BuiltValue()
abstract class MeWorkRequestsPostRequestOneOf1 implements Built<MeWorkRequestsPostRequestOneOf1, MeWorkRequestsPostRequestOneOf1Builder> {
  @BuiltValueField(wireName: r'kind')
  MeWorkRequestsPostRequestOneOf1KindEnum get kind;
  // enum kindEnum {  leave,  };

  @BuiltValueField(wireName: r'fromDate')
  String get fromDate;

  @BuiltValueField(wireName: r'toDate')
  String get toDate;

  @BuiltValueField(wireName: r'note')
  String? get note;

  MeWorkRequestsPostRequestOneOf1._();

  factory MeWorkRequestsPostRequestOneOf1([void updates(MeWorkRequestsPostRequestOneOf1Builder b)]) = _$MeWorkRequestsPostRequestOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRequestsPostRequestOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRequestsPostRequestOneOf1> get serializer => _$MeWorkRequestsPostRequestOneOf1Serializer();
}

class _$MeWorkRequestsPostRequestOneOf1Serializer implements PrimitiveSerializer<MeWorkRequestsPostRequestOneOf1> {
  @override
  final Iterable<Type> types = const [MeWorkRequestsPostRequestOneOf1, _$MeWorkRequestsPostRequestOneOf1];

  @override
  final String wireName = r'MeWorkRequestsPostRequestOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRequestsPostRequestOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(MeWorkRequestsPostRequestOneOf1KindEnum),
    );
    yield r'fromDate';
    yield serializers.serialize(
      object.fromDate,
      specifiedType: const FullType(String),
    );
    yield r'toDate';
    yield serializers.serialize(
      object.toDate,
      specifiedType: const FullType(String),
    );
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
    MeWorkRequestsPostRequestOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRequestsPostRequestOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeWorkRequestsPostRequestOneOf1KindEnum),
          ) as MeWorkRequestsPostRequestOneOf1KindEnum;
          result.kind = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromDate = valueDes;
          break;
        case r'toDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toDate = valueDes;
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
  MeWorkRequestsPostRequestOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRequestsPostRequestOneOf1Builder();
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

class MeWorkRequestsPostRequestOneOf1KindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'leave')
  static const MeWorkRequestsPostRequestOneOf1KindEnum leave = _$meWorkRequestsPostRequestOneOf1KindEnum_leave;

  static Serializer<MeWorkRequestsPostRequestOneOf1KindEnum> get serializer => _$meWorkRequestsPostRequestOneOf1KindEnumSerializer;

  const MeWorkRequestsPostRequestOneOf1KindEnum._(String name): super(name);

  static BuiltSet<MeWorkRequestsPostRequestOneOf1KindEnum> get values => _$meWorkRequestsPostRequestOneOf1KindEnumValues;
  static MeWorkRequestsPostRequestOneOf1KindEnum valueOf(String name) => _$meWorkRequestsPostRequestOneOf1KindEnumValueOf(name);
}

