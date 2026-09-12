//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_ask_dispatch_post_request.g.dart';

/// AdminAskDispatchPostRequest
///
/// Properties:
/// * [travelDate] 
/// * [direction] 
@BuiltValue()
abstract class AdminAskDispatchPostRequest implements Built<AdminAskDispatchPostRequest, AdminAskDispatchPostRequestBuilder> {
  @BuiltValueField(wireName: r'travelDate')
  String get travelDate;

  @BuiltValueField(wireName: r'direction')
  AdminAskDispatchPostRequestDirectionEnum get direction;
  // enum directionEnum {  morning,  evening,  };

  AdminAskDispatchPostRequest._();

  factory AdminAskDispatchPostRequest([void updates(AdminAskDispatchPostRequestBuilder b)]) = _$AdminAskDispatchPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAskDispatchPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAskDispatchPostRequest> get serializer => _$AdminAskDispatchPostRequestSerializer();
}

class _$AdminAskDispatchPostRequestSerializer implements PrimitiveSerializer<AdminAskDispatchPostRequest> {
  @override
  final Iterable<Type> types = const [AdminAskDispatchPostRequest, _$AdminAskDispatchPostRequest];

  @override
  final String wireName = r'AdminAskDispatchPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAskDispatchPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(AdminAskDispatchPostRequestDirectionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAskDispatchPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAskDispatchPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'travelDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.travelDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminAskDispatchPostRequestDirectionEnum),
          ) as AdminAskDispatchPostRequestDirectionEnum;
          result.direction = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAskDispatchPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAskDispatchPostRequestBuilder();
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

class AdminAskDispatchPostRequestDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const AdminAskDispatchPostRequestDirectionEnum morning = _$adminAskDispatchPostRequestDirectionEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const AdminAskDispatchPostRequestDirectionEnum evening = _$adminAskDispatchPostRequestDirectionEnum_evening;

  static Serializer<AdminAskDispatchPostRequestDirectionEnum> get serializer => _$adminAskDispatchPostRequestDirectionEnumSerializer;

  const AdminAskDispatchPostRequestDirectionEnum._(String name): super(name);

  static BuiltSet<AdminAskDispatchPostRequestDirectionEnum> get values => _$adminAskDispatchPostRequestDirectionEnumValues;
  static AdminAskDispatchPostRequestDirectionEnum valueOf(String name) => _$adminAskDispatchPostRequestDirectionEnumValueOf(name);
}

