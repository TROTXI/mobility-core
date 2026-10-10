// Rider-facing wording for the purchase wire enums. Shared by the activity
// feed in WalletTab and the purchase details sheet so a purchase reads the
// same in the list as it does when opened.

import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// The plan the purchase bought.
String purchasePlanLabel(PurchasePlanEnum plan) =>
    plan == PurchasePlanEnum.annual ? 'Annual plan' : 'Monthly plan';

String purchaseCashLabel(PurchaseCollectionStateEnum state) =>
    state == PurchaseCollectionStateEnum.successful
    ? 'Collected via Paystack'
    : 'Cash due';

/// Where the purchase itself stands.
String purchaseStateLabel(
  PurchaseStateEnum state, {
  PurchaseCollectionStateEnum? collectionState,
}) {
  if (state == PurchaseStateEnum.failed &&
      collectionState == PurchaseCollectionStateEnum.successful) {
    return 'Payment received · Under review';
  }
  if (state == PurchaseStateEnum.awaitingPayment &&
      collectionState == PurchaseCollectionStateEnum.successful) {
    return 'Payment processing';
  }
  return switch (state) {
    PurchaseStateEnum.awaitingPayment => 'Awaiting payment',
    PurchaseStateEnum.processing => 'Payment processing',
    PurchaseStateEnum.fulfilled => 'Paid',
    PurchaseStateEnum.failed => 'Payment failed',
    PurchaseStateEnum.cancelled => 'Cancelled',
    PurchaseStateEnum.reviewRequired => 'Under review',
    _ => 'Purchase',
  };
}

/// Badge colour for a purchase state: settled green, dead red, in-flight amber.
Color purchaseStateColor(
  BuildContext context,
  PurchaseStateEnum state, {
  PurchaseCollectionStateEnum? collectionState,
}) {
  final colors = context.appColors;
  if (state == PurchaseStateEnum.failed &&
      collectionState == PurchaseCollectionStateEnum.successful) {
    return colors.warning;
  }
  return switch (state) {
    PurchaseStateEnum.fulfilled => colors.success,
    PurchaseStateEnum.failed || PurchaseStateEnum.cancelled => colors.error,
    _ => colors.warning,
  };
}
