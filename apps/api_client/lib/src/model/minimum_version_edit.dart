//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'minimum_version_edit.g.dart';

/// MinimumVersionEdit
///
/// Properties:
/// * [minSupportedBuild] 
/// * [apiMajor] 
/// * [storeUrl] 
@BuiltValue()
abstract class MinimumVersionEdit implements Built<MinimumVersionEdit, MinimumVersionEditBuilder> {
  @BuiltValueField(wireName: r'minSupportedBuild')
  int get minSupportedBuild;

  @BuiltValueField(wireName: r'apiMajor')
  MinimumVersionEditApiMajorEnum get apiMajor;
  // enum apiMajorEnum {  1,  };

  @BuiltValueField(wireName: r'storeUrl')
  String get storeUrl;

  MinimumVersionEdit._();

  factory MinimumVersionEdit([void updates(MinimumVersionEditBuilder b)]) = _$MinimumVersionEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MinimumVersionEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MinimumVersionEdit> get serializer => _$MinimumVersionEditSerializer();
}

class _$MinimumVersionEditSerializer implements PrimitiveSerializer<MinimumVersionEdit> {
  @override
  final Iterable<Type> types = const [MinimumVersionEdit, _$MinimumVersionEdit];

  @override
  final String wireName = r'MinimumVersionEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MinimumVersionEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'minSupportedBuild';
    yield serializers.serialize(
      object.minSupportedBuild,
      specifiedType: const FullType(int),
    );
    yield r'apiMajor';
    yield serializers.serialize(
      object.apiMajor,
      specifiedType: const FullType(MinimumVersionEditApiMajorEnum),
    );
    yield r'storeUrl';
    yield serializers.serialize(
      object.storeUrl,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MinimumVersionEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MinimumVersionEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'minSupportedBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minSupportedBuild = valueDes;
          break;
        case r'apiMajor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MinimumVersionEditApiMajorEnum),
          ) as MinimumVersionEditApiMajorEnum;
          result.apiMajor = valueDes;
          break;
        case r'storeUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storeUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MinimumVersionEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MinimumVersionEditBuilder();
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

class MinimumVersionEditApiMajorEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const MinimumVersionEditApiMajorEnum number1 = _$minimumVersionEditApiMajorEnum_number1;

  static Serializer<MinimumVersionEditApiMajorEnum> get serializer => _$minimumVersionEditApiMajorEnumSerializer;

  const MinimumVersionEditApiMajorEnum._(String name): super(name);

  static BuiltSet<MinimumVersionEditApiMajorEnum> get values => _$minimumVersionEditApiMajorEnumValues;
  static MinimumVersionEditApiMajorEnum valueOf(String name) => _$minimumVersionEditApiMajorEnumValueOf(name);
}

