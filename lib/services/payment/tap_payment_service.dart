import 'package:flutter/foundation.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';

/// Service class to handle Tap Payments SDK integration
/// Using official goSellSDK from github.com/Tap-Payments
/// Secure payment processing for Android and iOS
class TapPaymentService {
  static final TapPaymentService _instance = TapPaymentService._internal();
  factory TapPaymentService() => _instance;
  TapPaymentService._internal();

  String? _secretKey;
  String? _bundleId;
  bool _isInitialized = false;

  /// Initialize Tap Payment SDK with credentials
  void initialize({
    required String secretKey,
    required String bundleId,
  }) {
    _secretKey = secretKey;
    _bundleId = bundleId;
    _isInitialized = true;
    debugPrint('🔵 Tap Payment Service initialized (Official SDK)');
    debugPrint('🔵 Bundle ID: $bundleId');
  }

  bool get isInitialized => _isInitialized;

  /// Configure SDK app settings
  void configureApp({required String lang}) {
    if (!_isInitialized) {
      throw Exception('TapPaymentService not initialized');
    }

    GoSellSdkFlutter.configureApp(
      bundleId: _bundleId!,
      productionSecretKey: _secretKey!,
      sandBoxSecretKey: _secretKey!,
      lang: lang,
    );
  }

  /// Setup and start payment session
  Future<Map<String, dynamic>> startPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerFirstName,
    required String customerLastName,
    required String orderId,
    required String itemName,
    required String itemDescription,
  }) async {
    if (!_isInitialized) {
      throw Exception('TapPaymentService not initialized');
    }

    try {
      // Clean phone number
      String cleanPhone = customerPhone.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPhone.startsWith('966')) {
        cleanPhone = cleanPhone.substring(3);
      }
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }

      // Create customer
      final customer = Customer(
        customerId: '',
        email: customerEmail,
        isdNumber: '966',
        number: cleanPhone,
        firstName: customerFirstName,
        middleName: '',
        lastName: customerLastName.isEmpty ? customerFirstName : customerLastName,
        metaData: null,
      );

      // Create payment items
      final paymentItems = <PaymentItem>[
        PaymentItem(
          name: itemName,
          amountPerUnit: amount,
          quantity: Quantity(value: 1),
          totalAmount: amount.toInt(),
          description: itemDescription,
          discount: null,
          taxes: null,
        ),
      ];

      // Create reference
      final reference = Reference(
        acquirer: '',
        gateway: '',
        payment: orderId,
        track: orderId,
        transaction: orderId,
        order: orderId,
        gosellID: null,
      );

      // Configure session
      GoSellSdkFlutter.sessionConfigurations(
        trxMode: TransactionMode.PURCHASE,
        transactionCurrency: currency,
        amount: amount,
        customer: customer,
        paymentItems: paymentItems,
        taxes: [],
        shippings: [],
        postURL: '',
        paymentDescription: itemDescription,
        paymentMetaData: {'orderId': orderId},
        paymentReference: reference,
        paymentStatementDescriptor: 'Aqvioo',
        isUserAllowedToSaveCard: false,
        isRequires3DSecure: true,
        receipt: Receipt(false, true), // sms: false, email: true
        authorizeAction: AuthorizeAction(
          type: AuthorizeActionType.VOID,
          timeInHours: 1,
        ),
        destinations: null,
        merchantID: '',
        allowedCadTypes: CardType.ALL,
        applePayMerchantID: '',
        allowsToSaveSameCardMoreThanOnce: false,
        allowsToEditCardHolderName: true,
        cardHolderName: '$customerFirstName $customerLastName',
        paymentType: PaymentType.ALL,
        sdkMode: SDKMode.Production,
        supportedPaymentMethods: ['VISA', 'MASTERCARD', 'MADA', 'AMERICAN_EXPRESS'],
      );

      // Start payment
      final result = await GoSellSdkFlutter.startPaymentSDK;

      debugPrint('🔵 Tap Payment Result: $result');

      return result ?? {};
    } catch (e, stackTrace) {
      debugPrint('❌ Tap Payment Error: $e');
      debugPrint('❌ Stack: $stackTrace');
      rethrow;
    }
  }

  /// Parse payment result
  PaymentResult parseResult(Map<String, dynamic> result) {
    final status = result['sdk_result'] as String?;
    final chargeId = result['charge_id'] as String?;
    final message = result['message'] as String?;

    if (status == 'SUCCESS') {
      return PaymentResult(
        success: true,
        chargeId: chargeId,
        message: message ?? 'Payment successful',
      );
    } else if (status == 'FAILED') {
      return PaymentResult(
        success: false,
        chargeId: chargeId,
        message: message ?? 'Payment failed',
      );
    } else {
      return PaymentResult(
        success: false,
        message: message ?? 'Payment cancelled',
      );
    }
  }

  /// Get rejection text
  String getRejectionText({bool isArabic = false}) {
    return isArabic
        ? 'عذراً، تم رفض الدفع. يرجى المحاولة مرة أخرى.'
        : 'Sorry, payment was rejected. Please try again.';
  }
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? chargeId;
  final String message;

  PaymentResult({
    required this.success,
    this.chargeId,
    required this.message,
  });
}
