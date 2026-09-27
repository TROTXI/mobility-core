//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_update.g.dart';

/// ProfileUpdate
///
/// Properties:
<<<<<<< HEAD
/// * [displayName] 
@BuiltValue()
abstract class ProfileUpdate implements Built<ProfileUpdate, ProfileUpdateBuilder> {
=======
/// * [displayName]
@BuiltValue()
abstract class ProfileUpdate
    implements Built<ProfileUpdate, ProfileUpdateBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  ProfileUpdate._();

<<<<<<< HEAD
  factory ProfileUpdate([void updates(ProfileUpdateBuilder b)]) = _$ProfileUpdate;
=======
  factory ProfileUpdate([void updates(ProfileUpdateBuilder b)]) =
      _$ProfileUpdate;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfileUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ProfileUpdate> get serializer => _$ProfileUpdateSerializer();
=======
  static Serializer<ProfileUpdate> get serializer =>
      _$ProfileUpdateSerializer();
>>>>>>> origin/main
}

class _$ProfileUpdateSerializer implements PrimitiveSerializer<ProfileUpdate> {
  @override
  final Iterable<Type> types = const [ProfileUpdate, _$ProfileUpdate];

  @override
  final String wireName = r'ProfileUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfileUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfileUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProfileUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfileUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfileUpdateBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
