import 'package:flutter/foundation.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

/// Service class to handle Tabby payment SDK integration
class TabbyService {
  static final TabbyService _instance = TabbyService._internal();
  factory TabbyService() => _instance;
  TabbyService._internal();

  /// Initialize Tabby SDK with API key
  void initialize(String apiKey) {
    TabbySDK().setup(
      withApiKey: apiKey,
      environment:
          Environment.production, // Use Environment.production for both
    );
  }

  /// Create a checkout session for a credit package purchase
  Future<TabbySession?> createCheckoutSession({
    required String merchantCode,
    required double amount,
    required String currency,
    required String userEmail,
    required String userPhone,
    required String userName,
    required int credits,
    required String orderId,
  }) async {
    try {
      final payment = Payment(
        amount: amount.toStringAsFixed(2),
        currency: _getCurrency(currency),
        buyer: Buyer(
          email: userEmail,
          phone: userPhone,
          name: userName,
          dob: '1990-01-01', // Default DOB - can be updated if needed
        ),
        buyerHistory: BuyerHistory(
          loyaltyLevel: 0,
          registeredSince: DateTime.now().toIso8601String(),
          wishlistCount: 0,
        ),
        shippingAddress: const ShippingAddress(
          city: 'Riyadh',
          address: 'Digital Purchase',
          zip: '00000',
        ),
        order: Order(
          referenceId: orderId,
          items: [
            OrderItem(
              title: '$credits Credits Package',
              description: 'AI Video/Image Generation Credits',
              quantity: 1,
              unitPrice: amount.toStringAsFixed(2),
              referenceId: orderId,
              productUrl: 'https://aqvioo.com/credits',
              category: 'digital_goods',
            ),
          ],
        ),
        orderHistory: [],
      );

      final session = await TabbySDK().createSession(
        TabbyCheckoutPayload(
          merchantCode: merchantCode,
          lang: Lang.en, // Can be changed to Lang.ar for Arabic
          payment: payment,
        ),
      );

      return session;
    } catch (e) {
      debugPrint('Error creating Tabby session: $e');
      return null;
    }
  }

  /// Convert currency string to Currency enum
  Currency _getCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'AED':
        return Currency.aed;
      case 'SAR':
        return Currency.sar;
      case 'KWD':
        return Currency.kwd;
      case 'BHD':
        return Currency.bhd;
      case 'QAR':
        return Currency.qar;
      default:
        return Currency.sar; // Default to SAR
    }
  }

  /// Get rejection text based on language
  String getRejectionText({bool isArabic = false}) {
    return isArabic
        ? 'عذراً، تم رفض الدفع. يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى.'
        : 'Sorry, payment was rejected. Please try again or use another payment method.';
  }
}
