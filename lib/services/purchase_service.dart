import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/constants.dart';

/// Manages premium subscription via in-app purchases.
class PurchaseService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  ProductDetails? _premiumProduct;
  bool _purchasePending = false;
  String? _error;

  /// Called when a purchase is verified — host should update Firestore.
  void Function(PurchaseDetails)? onPurchaseVerified;

  bool get available => _available;
  bool get purchasePending => _purchasePending;
  ProductDetails? get premiumProduct => _premiumProduct;
  String? get error => _error;

  /// The formatted price string from the store (e.g. "€2,99").
  String get priceLabel => _premiumProduct?.price ?? '€2,99';

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('IAP not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    // Load product details
    final response = await _iap.queryProductDetails(
      {GameConstants.premiumProductId},
    );
    if (response.error != null) {
      _error = response.error!.message;
      debugPrint('IAP query error: ${response.error}');
      return;
    }
    if (response.productDetails.isNotEmpty) {
      _premiumProduct = response.productDetails.first;
    }
    notifyListeners();
  }

  /// Start the purchase flow.
  Future<void> buyPremium() async {
    if (_premiumProduct == null) {
      _error = 'Product not available';
      notifyListeners();
      return;
    }
    _purchasePending = true;
    _error = null;
    notifyListeners();

    final param = PurchaseParam(productDetails: _premiumProduct!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restore previous purchases (e.g. after reinstall).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchasePending = false;
          onPurchaseVerified?.call(purchase);
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;
        case PurchaseStatus.error:
          _purchasePending = false;
          _error = purchase.error?.message ?? 'Purchase failed';
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
