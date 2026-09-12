// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_plan_pricing_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminPlanPricingGet200Response extends AdminPlanPricingGet200Response {
  @override
  final BuiltList<AdminPlanPricingGet200ResponsePlansInner> plans;

  factory _$AdminPlanPricingGet200Response(
          [void Function(AdminPlanPricingGet200ResponseBuilder)? updates]) =>
      (AdminPlanPricingGet200ResponseBuilder()..update(updates))._build();

  _$AdminPlanPricingGet200Response._({required this.plans}) : super._();
  @override
  AdminPlanPricingGet200Response rebuild(
          void Function(AdminPlanPricingGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminPlanPricingGet200ResponseBuilder toBuilder() =>
      AdminPlanPricingGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminPlanPricingGet200Response && plans == other.plans;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plans.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminPlanPricingGet200Response')
          ..add('plans', plans))
        .toString();
  }
}

class AdminPlanPricingGet200ResponseBuilder
    implements
        Builder<AdminPlanPricingGet200Response,
            AdminPlanPricingGet200ResponseBuilder> {
  _$AdminPlanPricingGet200Response? _$v;

  ListBuilder<AdminPlanPricingGet200ResponsePlansInner>? _plans;
  ListBuilder<AdminPlanPricingGet200ResponsePlansInner> get plans =>
      _$this._plans ??= ListBuilder<AdminPlanPricingGet200ResponsePlansInner>();
  set plans(ListBuilder<AdminPlanPricingGet200ResponsePlansInner>? plans) =>
      _$this._plans = plans;

  AdminPlanPricingGet200ResponseBuilder() {
    AdminPlanPricingGet200Response._defaults(this);
  }

  AdminPlanPricingGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plans = $v.plans.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminPlanPricingGet200Response other) {
    _$v = other as _$AdminPlanPricingGet200Response;
  }

  @override
  void update(void Function(AdminPlanPricingGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminPlanPricingGet200Response build() => _build();

  _$AdminPlanPricingGet200Response _build() {
    _$AdminPlanPricingGet200Response _$result;
    try {
      _$result = _$v ??
          _$AdminPlanPricingGet200Response._(
            plans: plans.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plans';
        plans.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminPlanPricingGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
