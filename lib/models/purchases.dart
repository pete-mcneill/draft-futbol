// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesNotifier extends StateNotifier<DraftPurchases> {
  PurchasesNotifier() : super(DraftPurchases());

  void updateNoAdvertsStatus(bool status) {
    state = state.copyWith(noAdverts: status);
  }

  void updateSubscriptionPrice(String price) {
    state = state.copyWith(subscriptionPrice: price);
  }

  makePurchases() async {
    late Package package;
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        package = offerings.current!.availablePackages[0];
      }
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(package);
      var isPro = purchaserInfo.entitlements.all["noAdverts"]!.isActive;
      if (isPro) {
        state = state.copyWith(noAdverts: true);
      } else {
        state = state.copyWith(noAdverts: false);
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(noAdverts: false);
      }
    }
  }

  restorePurchase() async {
    try {
      PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
      // ... check restored purchaserInfo to see if entitlement is now active
      var isPro = restoredInfo.entitlements.all["noAdverts"]!.isActive;
      if (isPro) {
        state = state.copyWith(noAdverts: true);
      } else {
        state = state.copyWith(noAdverts: false);
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(noAdverts: false);
      }
    }
  }
}

class DraftPurchases {
  bool? noAdverts;
  String? subscriptionPrice;
  DraftPurchases({this.noAdverts, this.subscriptionPrice}) : super();

  DraftPurchases copyWith({bool? noAdverts, String? subscriptionPrice}) {
    return DraftPurchases(
        noAdverts: noAdverts ?? this.noAdverts,
        subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'noAdverts': noAdverts,
    };
  }

  factory DraftPurchases.fromMap(Map<String, dynamic> map) {
    return DraftPurchases(
      noAdverts: map['noAdverts'] != null ? map['noAdverts'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftPurchases.fromJson(String source) =>
      DraftPurchases.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DraftPurchases(noAdverts: $noAdverts)';

  @override
  bool operator ==(covariant DraftPurchases other) {
    if (identical(this, other)) return true;

    return other.noAdverts == noAdverts;
  }

  @override
  int get hashCode => noAdverts.hashCode;
}
