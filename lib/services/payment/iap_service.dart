import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Callback for when a purchase is completed/failed
  Function(PurchaseDetails)? onPurchaseUpdated;

  // Product IDs configuration
  // These must match exactly what is in App Store Connect
  static const Set<String> _kProductIds = {
    'aqvioo_credits_15',
    'aqvioo_credits_30',
    'aqvioo_credits_50',
    'aqvioo_credits_100',
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    // Prevent duplicate listeners when screen reopens
    await _subscription?.cancel();
    _subscription = null;

    _isAvailable = await _iap.isAvailable();

    if (_isAvailable) {
      /*
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        // await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }
      */

      await _loadProducts();

      // Listen to purchase updates
      final purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription?.cancel();
        _subscription = null;
      }, onError: (error) {
        debugPrint('IAP Error: $error');
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kProductIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
            '⚠️ IAP: Products not found in App Store: ${response.notFoundIDs}');
        debugPrint(
            '⚠️ IAP: This usually means products need screenshots uploaded in App Store Connect');
      }

      if (response.error != null) {
        debugPrint('⚠️ IAP: Query error: ${response.error}');
      }

      _products = response.productDetails;

      if (_products.isEmpty) {
        debugPrint(
            '⚠️ IAP: No products loaded. Check App Store Connect configuration.');
      } else {
        debugPrint('✅ IAP: Loaded ${_products.length} products successfully');
        // Sort by price
        _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      }
    } catch (e) {
      debugPrint('❌ IAP: Error loading products: $e');
    }
  }

  Future<void> buyConsumable(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error buying consumable: $e');
      throw Exception('Failed to initiate purchase');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      _processPurchaseUpdate(purchaseDetails);
    }
  }

  Future<void> _processPurchaseUpdate(PurchaseDetails purchaseDetails) async {
    debugPrint(
        '📦 IAP: Purchase update - status=${purchaseDetails.status}, product=${purchaseDetails.productID}');

    if (purchaseDetails.status == PurchaseStatus.pending) {
      onPurchaseUpdated?.call(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      debugPrint('📦 IAP: Purchase canceled by user');
      onPurchaseUpdated?.call(purchaseDetails);
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint(
          '📦 IAP: Purchase error: ${purchaseDetails.error?.message} (code: ${purchaseDetails.error?.code})');
      onPurchaseUpdated?.call(purchaseDetails);
      // Complete errored purchases to clear them from the queue
      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchaseDetails);
        } catch (e) {
          debugPrint('📦 IAP: Error completing errored purchase: $e');
        }
      }
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      debugPrint('📦 IAP: Purchase successful - delivering credits');
      // Notify the callback FIRST so credits are added,
      // THEN complete the purchase.
      try {
        onPurchaseUpdated?.call(purchaseDetails);
      } catch (e) {
        debugPrint('📦 IAP: Error in purchase callback: $e');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchaseDetails);
          debugPrint('📦 IAP: Purchase completed successfully');
        } catch (e) {
          debugPrint('📦 IAP: Error completing purchase: $e');
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    onPurchaseUpdated = null;
  }
}
