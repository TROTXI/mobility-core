//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_flags_key_put_request.g.dart';

/// AdminFlagsKeyPutRequest
///
/// Properties:
/// * [enabled] 
/// * [rolloutPercentage] 
/// * [description] 
@BuiltValue()
abstract class AdminFlagsKeyPutRequest implements Built<AdminFlagsKeyPutRequest, AdminFlagsKeyPutRequestBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'rolloutPercentage')
  int? get rolloutPercentage;

  @BuiltValueField(wireName: r'description')
  String? get description;

  AdminFlagsKeyPutRequest._();

  factory AdminFlagsKeyPutRequest([void updates(AdminFlagsKeyPutRequestBuilder b)]) = _$AdminFlagsKeyPutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminFlagsKeyPutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminFlagsKeyPutRequest> get serializer => _$AdminFlagsKeyPutRequestSerializer();
}

class _$AdminFlagsKeyPutRequestSerializer implements PrimitiveSerializer<AdminFlagsKeyPutRequest> {
  @override
  final Iterable<Type> types = const [AdminFlagsKeyPutRequest, _$AdminFlagsKeyPutRequest];

  @override
  final String wireName = r'AdminFlagsKeyPutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminFlagsKeyPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.rolloutPercentage != null) {
      yield r'rolloutPercentage';
      yield serializers.serialize(
        object.rolloutPercentage,
        specifiedType: const FullType(int),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminFlagsKeyPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminFlagsKeyPutRequestBuilder result,
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
        case r'rolloutPercentage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rolloutPercentage = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminFlagsKeyPutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminFlagsKeyPutRequestBuilder();
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

