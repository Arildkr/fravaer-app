import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abonnementstjeneste — håndterer prøveperiode og Google Play-abonnement.
///
/// Modell: 30 dager gratis, deretter 29 kr/år.
class SubscriptionService {
  static const productId = 'allemed_yearly';
  static const _trialStartKey = 'trial_start_date';
  static const trialDays = 30;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Gjeldende abonnementsstatus.
  final ValueNotifier<SubscriptionStatus> status =
      ValueNotifier(SubscriptionStatus.loading);

  /// Initialiserer tjenesten: sjekker prøveperiode og kjøpsstatus.
  Future<void> initialize() async {
    // Registrer prøveperiodens startdato ved første bruk
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_trialStartKey)) {
      await prefs.setString(
          _trialStartKey, DateTime.now().toIso8601String());
    }

    // Sjekk om butikken er tilgjengelig
    final available = await _iap.isAvailable();
    if (!available) {
      // Butikk ikke tilgjengelig (emulator etc.) — bruk kun prøveperiode
      _updateFromTrial(prefs);
      return;
    }

    // Lytt på kjøpsoppdateringer
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (_) => _updateFromTrial(prefs),
    );

    // Gjenopprett eksisterende kjøp
    await _iap.restorePurchases();

    // Hvis ingen aktive kjøp ble funnet, sjekk prøveperiode
    if (status.value == SubscriptionStatus.loading) {
      _updateFromTrial(prefs);
    }
  }

  void _updateFromTrial(SharedPreferences prefs) {
    if (_isTrialActive(prefs)) {
      status.value = SubscriptionStatus.trial;
    } else {
      status.value = SubscriptionStatus.expired;
    }
  }

  bool _isTrialActive(SharedPreferences prefs) {
    final startStr = prefs.getString(_trialStartKey);
    if (startStr == null) return true; // Aldri startet = ny bruker
    final start = DateTime.parse(startStr);
    return DateTime.now().difference(start).inDays < trialDays;
  }

  /// Antall dager igjen av prøveperioden.
  Future<int> get trialDaysRemaining async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(_trialStartKey);
    if (startStr == null) return trialDays;
    final start = DateTime.parse(startStr);
    final remaining = trialDays - DateTime.now().difference(start).inDays;
    return remaining.clamp(0, trialDays);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == productId) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            status.value = SubscriptionStatus.active;
            if (purchase.pendingCompletePurchase) {
              _iap.completePurchase(purchase);
            }
          case PurchaseStatus.pending:
            status.value = SubscriptionStatus.loading;
          case PurchaseStatus.error:
          case PurchaseStatus.canceled:
            // Behold gjeldende status (trial eller expired)
            break;
        }
      }
    }
  }

  /// Start kjøpsprosessen for årsabonnementet.
  Future<bool> purchase() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return false;

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Gjenopprett tidligere kjøp.
  Future<void> restore() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
    status.dispose();
  }
}

enum SubscriptionStatus {
  loading,
  trial,
  active,
  expired,
}
