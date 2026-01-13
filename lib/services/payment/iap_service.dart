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
    'credits_package_15',
    'credits_package_30',
    'credits_package_50',
    'credits_package_100',
  };

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
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
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      // Sort by price
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    } catch (e) {
      debugPrint('Error loading products: $e');
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
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
        onPurchaseUpdated?.call(purchaseDetails);
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
          onPurchaseUpdated?.call(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify payment receipt if needed here
          // For now, we trust the status for this implementation phase

          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          onPurchaseUpdated?.call(purchaseDetails);
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
