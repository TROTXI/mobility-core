//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_routes_id_fares_get200_response_fares_inner.g.dart';

/// AdminRoutesIdFaresGet200ResponseFaresInner
///
/// Properties:
/// * [id] 
/// * [routeId] 
/// * [farePesewas] 
/// * [effectiveFrom] 
/// * [effectiveTo] 
/// * [note] 
@BuiltValue()
abstract class AdminRoutesIdFaresGet200ResponseFaresInner implements Built<AdminRoutesIdFaresGet200ResponseFaresInner, AdminRoutesIdFaresGet200ResponseFaresInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'farePesewas')
  int get farePesewas;

  @BuiltValueField(wireName: r'effectiveFrom')
  DateTime get effectiveFrom;

  @BuiltValueField(wireName: r'effectiveTo')
  DateTime? get effectiveTo;

  @BuiltValueField(wireName: r'note')
  String? get note;

  AdminRoutesIdFaresGet200ResponseFaresInner._();

  factory AdminRoutesIdFaresGet200ResponseFaresInner([void updates(AdminRoutesIdFaresGet200ResponseFaresInnerBuilder b)]) = _$AdminRoutesIdFaresGet200ResponseFaresInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRoutesIdFaresGet200ResponseFaresInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRoutesIdFaresGet200ResponseFaresInner> get serializer => _$AdminRoutesIdFaresGet200ResponseFaresInnerSerializer();
}

class _$AdminRoutesIdFaresGet200ResponseFaresInnerSerializer implements PrimitiveSerializer<AdminRoutesIdFaresGet200ResponseFaresInner> {
  @override
  final Iterable<Type> types = const [AdminRoutesIdFaresGet200ResponseFaresInner, _$AdminRoutesIdFaresGet200ResponseFaresInner];

  @override
  final String wireName = r'AdminRoutesIdFaresGet200ResponseFaresInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRoutesIdFaresGet200ResponseFaresInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'farePesewas';
    yield serializers.serialize(
      object.farePesewas,
      specifiedType: const FullType(int),
    );
    yield r'effectiveFrom';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(DateTime),
    );
    yield r'effectiveTo';
    yield object.effectiveTo == null ? null : serializers.serialize(
      object.effectiveTo,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRoutesIdFaresGet200ResponseFaresInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRoutesIdFaresGet200ResponseFaresInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'farePesewas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.farePesewas = valueDes;
          break;
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.effectiveFrom = valueDes;
          break;
        case r'effectiveTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveTo = valueDes;
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
  AdminRoutesIdFaresGet200ResponseFaresInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRoutesIdFaresGet200ResponseFaresInnerBuilder();
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

