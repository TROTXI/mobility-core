//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_min_versions_platform_put_request.g.dart';

/// AdminMinVersionsPlatformPutRequest
///
/// Properties:
/// * [version] 
@BuiltValue()
abstract class AdminMinVersionsPlatformPutRequest implements Built<AdminMinVersionsPlatformPutRequest, AdminMinVersionsPlatformPutRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  String get version;

  AdminMinVersionsPlatformPutRequest._();

  factory AdminMinVersionsPlatformPutRequest([void updates(AdminMinVersionsPlatformPutRequestBuilder b)]) = _$AdminMinVersionsPlatformPutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMinVersionsPlatformPutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMinVersionsPlatformPutRequest> get serializer => _$AdminMinVersionsPlatformPutRequestSerializer();
}

class _$AdminMinVersionsPlatformPutRequestSerializer implements PrimitiveSerializer<AdminMinVersionsPlatformPutRequest> {
  @override
  final Iterable<Type> types = const [AdminMinVersionsPlatformPutRequest, _$AdminMinVersionsPlatformPutRequest];

  @override
  final String wireName = r'AdminMinVersionsPlatformPutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMinVersionsPlatformPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminMinVersionsPlatformPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMinVersionsPlatformPutRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminMinVersionsPlatformPutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMinVersionsPlatformPutRequestBuilder();
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

