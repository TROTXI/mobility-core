// Rider-facing wording for the purchase wire enums. Shared by the activity
// feed in WalletTab and the purchase details sheet so a purchase reads the
// same in the list as it does when opened.

import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// The plan the purchase bought.
String purchasePlanLabel(PurchasePlanEnum plan) =>
    plan == PurchasePlanEnum.annual ? 'Annual plan' : 'Monthly plan';

/// Where the purchase itself stands.
String purchaseStateLabel(PurchaseStateEnum state) {
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

/// Where the money collection stands, which can lag the purchase state while
/// Paystack settles.
String purchaseCollectionStateLabel(PurchaseCollectionStateEnum state) {
  return switch (state) {
    PurchaseCollectionStateEnum.pending => 'Pending',
    PurchaseCollectionStateEnum.successful => 'Collected',
    PurchaseCollectionStateEnum.failed => 'Not collected',
    PurchaseCollectionStateEnum.unknown => 'Unknown',
    _ => 'Unknown',
  };
}

/// Badge colour for a purchase state: settled green, dead red, in-flight amber.
Color purchaseStateColor(BuildContext context, PurchaseStateEnum state) {
  final colors = context.appColors;
  return switch (state) {
    PurchaseStateEnum.fulfilled => colors.success,
    PurchaseStateEnum.failed || PurchaseStateEnum.cancelled => colors.error,
    _ => colors.warning,
  };
}
