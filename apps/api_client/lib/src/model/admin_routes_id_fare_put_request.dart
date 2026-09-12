//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_routes_id_fare_put_request.g.dart';

/// AdminRoutesIdFarePutRequest
///
/// Properties:
/// * [farePesewas] 
/// * [note] 
@BuiltValue()
abstract class AdminRoutesIdFarePutRequest implements Built<AdminRoutesIdFarePutRequest, AdminRoutesIdFarePutRequestBuilder> {
  @BuiltValueField(wireName: r'farePesewas')
  int get farePesewas;

  @BuiltValueField(wireName: r'note')
  String? get note;

  AdminRoutesIdFarePutRequest._();

  factory AdminRoutesIdFarePutRequest([void updates(AdminRoutesIdFarePutRequestBuilder b)]) = _$AdminRoutesIdFarePutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRoutesIdFarePutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRoutesIdFarePutRequest> get serializer => _$AdminRoutesIdFarePutRequestSerializer();
}

class _$AdminRoutesIdFarePutRequestSerializer implements PrimitiveSerializer<AdminRoutesIdFarePutRequest> {
  @override
  final Iterable<Type> types = const [AdminRoutesIdFarePutRequest, _$AdminRoutesIdFarePutRequest];

  @override
  final String wireName = r'AdminRoutesIdFarePutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRoutesIdFarePutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'farePesewas';
    yield serializers.serialize(
      object.farePesewas,
      specifiedType: const FullType(int),
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
    AdminRoutesIdFarePutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRoutesIdFarePutRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'farePesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.farePesewas = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  AdminRoutesIdFarePutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRoutesIdFarePutRequestBuilder();
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


