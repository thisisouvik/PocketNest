import 'package:flutter/foundation.dart';
import 'package:pocketnest/config/environment_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String premiumEntitlementId = 'PocketNest Premium';

  static final ValueNotifier<CustomerInfo?> customerInfo =
      ValueNotifier<CustomerInfo?>(null);

  static Future<void> initialize({String? appUserId}) async {
    final apiKey = EnvironmentConfig.revenueCatApiKey;
    if (apiKey.isEmpty) {
      return;
    }

    final logLevel = EnvironmentConfig.isProduction()
        ? LogLevel.info
        : LogLevel.debug;
    await Purchases.setLogLevel(logLevel);

    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener((info) {
      customerInfo.value = info;
    });

    customerInfo.value = await Purchases.getCustomerInfo();
  }

  static Future<void> refreshCustomerInfo() async {
    customerInfo.value = await Purchases.getCustomerInfo();
  }

  static bool get isPremium {
    final info = customerInfo.value;
    if (info == null) return false;
    return info.entitlements.active.containsKey(premiumEntitlementId);
  }

  static Future<void> logIn(String appUserId) async {
    if (appUserId.isEmpty) return;
    final result = await Purchases.logIn(appUserId);
    customerInfo.value = result.customerInfo;
  }

  static Future<void> logOut() async {
    await Purchases.logOut();
    customerInfo.value = await Purchases.getCustomerInfo();
  }

  static Future<Offerings> getOfferings() {
    return Purchases.getOfferings();
  }

  static Future<PurchaseResult> purchasePackage(Package package) {
    return Purchases.purchasePackage(package);
  }

  static Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }

  static Future<void> presentPaywall() {
    return RevenueCatUI.presentPaywall();
  }

  static Future<void> presentPaywallIfNeeded() {
    return RevenueCatUI.presentPaywallIfNeeded(premiumEntitlementId);
  }

  static Future<void> presentCustomerCenter() {
    return RevenueCatUI.presentCustomerCenter();
  }
}
