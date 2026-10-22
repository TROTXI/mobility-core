// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TermsStatusAudienceEnum _$termsStatusAudienceEnum_commuter =
    const TermsStatusAudienceEnum._('commuter');
const TermsStatusAudienceEnum _$termsStatusAudienceEnum_driver =
    const TermsStatusAudienceEnum._('driver');

TermsStatusAudienceEnum _$termsStatusAudienceEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$termsStatusAudienceEnum_commuter;
    case 'driver':
      return _$termsStatusAudienceEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TermsStatusAudienceEnum> _$termsStatusAudienceEnumValues =
    BuiltSet<TermsStatusAudienceEnum>(const <TermsStatusAudienceEnum>[
  _$termsStatusAudienceEnum_commuter,
  _$termsStatusAudienceEnum_driver,
]);

Serializer<TermsStatusAudienceEnum> _$termsStatusAudienceEnumSerializer =
    _$TermsStatusAudienceEnumSerializer();

class _$TermsStatusAudienceEnumSerializer
    implements PrimitiveSerializer<TermsStatusAudienceEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'commuter': 'commuter',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'commuter': 'commuter',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[TermsStatusAudienceEnum];
  @override
  final String wireName = 'TermsStatusAudienceEnum';

  @override
  Object serialize(Serializers serializers, TermsStatusAudienceEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TermsStatusAudienceEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TermsStatusAudienceEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TermsStatus extends TermsStatus {
  @override
  final TermsStatusAudienceEnum audience;
  @override
  final Date currentVersion;
  @override
  final Date? acceptedVersion;
  @override
  final bool acceptanceRequired;

  factory _$TermsStatus([void Function(TermsStatusBuilder)? updates]) =>
      (TermsStatusBuilder()..update(updates))._build();

  _$TermsStatus._(
      {required this.audience,
      required this.currentVersion,
      this.acceptedVersion,
      required this.acceptanceRequired})
      : super._();
  @override
  TermsStatus rebuild(void Function(TermsStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TermsStatusBuilder toBuilder() => TermsStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TermsStatus &&
        audience == other.audience &&
        currentVersion == other.currentVersion &&
        acceptedVersion == other.acceptedVersion &&
        acceptanceRequired == other.acceptanceRequired;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, audience.hashCode);
    _$hash = $jc(_$hash, currentVersion.hashCode);
    _$hash = $jc(_$hash, acceptedVersion.hashCode);
    _$hash = $jc(_$hash, acceptanceRequired.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TermsStatus')
          ..add('audience', audience)
          ..add('currentVersion', currentVersion)
          ..add('acceptedVersion', acceptedVersion)
          ..add('acceptanceRequired', acceptanceRequired))
        .toString();
  }
}

class TermsStatusBuilder implements Builder<TermsStatus, TermsStatusBuilder> {
  _$TermsStatus? _$v;

  TermsStatusAudienceEnum? _audience;
  TermsStatusAudienceEnum? get audience => _$this._audience;
  set audience(TermsStatusAudienceEnum? audience) =>
      _$this._audience = audience;

  Date? _currentVersion;
  Date? get currentVersion => _$this._currentVersion;
  set currentVersion(Date? currentVersion) =>
      _$this._currentVersion = currentVersion;

  Date? _acceptedVersion;
  Date? get acceptedVersion => _$this._acceptedVersion;
  set acceptedVersion(Date? acceptedVersion) =>
      _$this._acceptedVersion = acceptedVersion;

  bool? _acceptanceRequired;
  bool? get acceptanceRequired => _$this._acceptanceRequired;
  set acceptanceRequired(bool? acceptanceRequired) =>
      _$this._acceptanceRequired = acceptanceRequired;

  TermsStatusBuilder() {
    TermsStatus._defaults(this);
  }

  TermsStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _audience = $v.audience;
      _currentVersion = $v.currentVersion;
      _acceptedVersion = $v.acceptedVersion;
      _acceptanceRequired = $v.acceptanceRequired;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TermsStatus other) {
    _$v = other as _$TermsStatus;
  }

  @override
  void update(void Function(TermsStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TermsStatus build() => _build();

  _$TermsStatus _build() {
    final _$result = _$v ??
        _$TermsStatus._(
          audience: BuiltValueNullFieldError.checkNotNull(
              audience, r'TermsStatus', 'audience'),
          currentVersion: BuiltValueNullFieldError.checkNotNull(
              currentVersion, r'TermsStatus', 'currentVersion'),
          acceptedVersion: acceptedVersion,
          acceptanceRequired: BuiltValueNullFieldError.checkNotNull(
              acceptanceRequired, r'TermsStatus', 'acceptanceRequired'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
