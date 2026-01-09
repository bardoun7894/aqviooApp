import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:checkout_flutter/checkout_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:akvioo/core/utils/safe_api_caller.dart';

/// Service class to handle Tap Payments SDK integration
/// Using official Checkout Flutter SDK from developers.tap.company
/// Secure payment processing for Android and iOS
class TapPaymentService with SafeApiCaller {
  static final TapPaymentService _instance = TapPaymentService._internal();
  factory TapPaymentService() => _instance;
  TapPaymentService._internal();

  String? _publicKey;
  String? _secretKey;
  String? _merchantId;
  bool _isInitialized = false;

  /// Initialize Tap Payment SDK with credentials
  void initialize({
    required String publicKey,
    required String secretKey,
    required String merchantId,
    bool isProduction = true,
  }) {
    _publicKey = publicKey;
    _secretKey = secretKey;
    _merchantId = merchantId;
    _isInitialized = true;
    debugPrint('🔵 Tap Payment Service initialized (Checkout SDK)');
    debugPrint('🔵 Merchant ID: $merchantId');
    debugPrint('🔵 Mode: ${isProduction ? "Production" : "Sandbox"}');
  }

  bool get isInitialized => _isInitialized;
  String? get secretKey => _secretKey;

  /// Generates a secure hash string to use with Tap Checkout
  String _generateHashString({
    required double amount,
    required String currency,
    String postUrl = '',
    String transactionReference = '',
  }) {
    try {
      final key = utf8.encode(_secretKey!);
      final formattedAmount = amount.toStringAsFixed(2);
      final toBeHashed = 'x_publickey$_publicKey'
          'x_amount$formattedAmount'
          'x_currency$currency'
          'x_transaction$transactionReference'
          'x_post$postUrl';
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(utf8.encode(toBeHashed));
      return digest.toString();
    } catch (e) {
      debugPrint('❌ Error generating hash string: $e');
      rethrow;
    }
  }

  /// Verify transaction status via Tap API
  /// Returns: 'CAPTURED', 'DECLINED', 'INITIATED', 'AUTHORIZED', 'VOID', 'REFUNDED'
  Future<TransactionVerificationResult> verifyTransaction(
      String chargeId) async {
    if (!_isInitialized || _secretKey == null) {
      return TransactionVerificationResult(
        success: false,
        status: 'ERROR',
        message: 'TapPaymentService not initialized',
      );
    }

    if (chargeId.isEmpty) {
      return TransactionVerificationResult(
        success: false,
        status: 'ERROR',
        message: 'Charge ID is empty',
      );
    }

    final String apiUrl = 'https://api.tap.company/v2/charges/$chargeId';

    // Use safeApiCall for robust error handling
    try {
      final response = await safeApiCall(
        () => http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $_secretKey',
            'accept': 'application/json',
          },
        ),
        timeout: const Duration(seconds: 30),
        serviceName: 'TapPayment',
      );

      // SafeApiCall handles 429, 500, etc.
      // We still check 200 for expected business logic
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String? ?? 'UNKNOWN';
        final message = data['response']?['message'] as String? ?? '';

        debugPrint('🔵 Transaction $chargeId status: $status');

        return TransactionVerificationResult(
          success: status == 'CAPTURED' || status == 'AUTHORIZED',
          status: status,
          message: message,
          rawData: data,
        );
      } else {
        debugPrint('❌ Failed to verify transaction: ${response.statusCode}');
        return TransactionVerificationResult(
          success: false,
          status: 'ERROR',
          message: 'Failed to verify: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error verifying transaction: $e');
      // Use user friendly error if it's an API exception, otherwise generic
      final errorMessage = getUserFriendlyError(e);
      return TransactionVerificationResult(
        success: false,
        status: 'ERROR',
        message: errorMessage,
      );
    }
  }

  /// Start payment checkout with full configuration
  Future<PaymentResult> startPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerFirstName,
    required String customerLastName,
    required String orderId,
    required String itemName,
    required String itemDescription,
    String lang = 'ar',
    String? postUrl,
    TapThemeMode themeMode = TapThemeMode.light,
    List<String>? supportedPaymentMethods,
  }) async {
    // Validate initialization
    if (!_isInitialized) {
      return PaymentResult(
        success: false,
        message: 'TapPaymentService not initialized',
        errorCode: PaymentErrorCode.notInitialized,
      );
    }

    // Validate required fields
    if (amount <= 0) {
      return PaymentResult(
        success: false,
        message: 'Invalid amount',
        errorCode: PaymentErrorCode.invalidAmount,
      );
    }

    if (customerEmail.isEmpty || !customerEmail.contains('@')) {
      return PaymentResult(
        success: false,
        message: 'Invalid email',
        errorCode: PaymentErrorCode.invalidEmail,
      );
    }

    // Use Completer to properly handle async callbacks
    final completer = Completer<PaymentResult>();

    try {
      // Clean and validate phone number
      String cleanPhone = customerPhone.replaceAll(RegExp(r'[^\d]'), '');
      String countryCode = '966';

      if (cleanPhone.startsWith('966')) {
        cleanPhone = cleanPhone.substring(3);
      } else if (cleanPhone.startsWith('+966')) {
        cleanPhone = cleanPhone.substring(4);
      }
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }

      // Ensure phone has valid length
      if (cleanPhone.length < 9) {
        cleanPhone = '500000001'; // Default fallback
      }

      // Generate hash string
      final hashString = _generateHashString(
        amount: amount,
        currency: currency,
        postUrl: postUrl ?? '',
        transactionReference: orderId,
      );

      // Determine theme mode string
      final String themeModeStr;
      switch (themeMode) {
        case TapThemeMode.dark:
          themeModeStr = 'dark';
          break;
        case TapThemeMode.dynamic:
          themeModeStr = 'dynamic';
          break;
        case TapThemeMode.light:
          themeModeStr = 'light';
          break;
      }

      // Build configuration map
      final Map<String, dynamic> configurations = {
        "hashString": hashString,
        "language": lang,
        "themeMode": themeModeStr,
        "supportedPaymentMethods": supportedPaymentMethods ?? "ALL",
        "paymentType": "ALL",
        "selectedCurrency": currency,
        "supportedCurrencies": "ALL",
        "supportedPaymentTypes": [],
        "supportedRegions": [],
        "supportedSchemes": [],
        "supportedCountries": [],
        "gateway": {
          "publicKey": _publicKey,
          "merchantId": _merchantId ?? "",
        },
        "customer": {
          "firstName":
              customerFirstName.isNotEmpty ? customerFirstName : "Customer",
          "lastName": customerLastName.isNotEmpty
              ? customerLastName
              : customerFirstName,
          "email": customerEmail,
          "phone": {
            "countryCode": countryCode,
            "number": cleanPhone,
          },
        },
        "transaction": {
          "mode": "charge",
          "charge": {
            "metadata": {
              "orderId": orderId,
              "app": "aqvioo",
            },
            "reference": {
              "transaction": orderId,
              "order": orderId,
              "idempotent": orderId,
            },
            "saveCard": false,
            "redirect": {
              "url": "https://aqvioo.com/payment/callback",
            },
            "post": postUrl ?? "",
            "threeDSecure": true,
          },
        },
        "amount": amount.toStringAsFixed(2),
        "order": {
          "currency": currency,
          "amount": amount.toStringAsFixed(2),
          "items": [
            {
              "amount": amount.toStringAsFixed(2),
              "currency": currency,
              "name": itemName,
              "quantity": 1,
              "description": itemDescription,
            },
          ],
        },
        "cardOptions": {
          "showBrands": true,
          "showLoadingState": true,
          "collectHolderName": true,
          "preLoadCardName": "$customerFirstName $customerLastName".trim(),
          "cardNameEditable": true,
          "cardFundingSource": "all",
          "saveCardOption": "none",
          "forceLtr": false,
          "alternativeCardInputs": {
            "cardScanner": true,
            "cardNFC": true,
          },
        },
        "isApplePayAvailableOnClient": true,
      };

      debugPrint('🔵 Starting Tap Checkout with config: $orderId');

      // Start checkout with callbacks
      final success = await startCheckout(
        configurations: configurations,
        onReady: () {
          debugPrint('🔵 Tap Checkout is ready');
        },
        onSuccess: (data) {
          debugPrint('🔵 Tap Checkout Success: $data');
          if (!completer.isCompleted) {
            try {
              final Map<String, dynamic> decoded = jsonDecode(data);
              final String chargeId = decoded['chargeId'] ?? '';
              completer.complete(PaymentResult(
                success: true,
                chargeId: chargeId,
                message: 'Payment successful',
                rawData: decoded,
              ));
            } catch (e) {
              debugPrint('❌ Error parsing success data: $e');
              completer.complete(PaymentResult(
                success: true,
                message: 'Payment successful',
              ));
            }
          }
        },
        onError: (error) {
          debugPrint('❌ Tap Checkout Error: $error');
          if (!completer.isCompleted) {
            PaymentErrorCode errorCode = PaymentErrorCode.unknown;
            String message = error;

            // Parse error message for better handling
            if (error.toLowerCase().contains('cancelled')) {
              errorCode = PaymentErrorCode.cancelled;
              message = lang == 'ar' ? 'تم إلغاء الدفع' : 'Payment cancelled';
            } else if (error.toLowerCase().contains('declined')) {
              errorCode = PaymentErrorCode.declined;
              message = lang == 'ar' ? 'تم رفض البطاقة' : 'Card declined';
            } else if (error.toLowerCase().contains('network') ||
                error.toLowerCase().contains('connection')) {
              errorCode = PaymentErrorCode.networkError;
              message = lang == 'ar' ? 'خطأ في الاتصال' : 'Network error';
            } else if (error.toLowerCase().contains('3d') ||
                error.toLowerCase().contains('secure')) {
              errorCode = PaymentErrorCode.threeDSecureFailed;
              message = lang == 'ar' ? 'فشل التحقق الأمني' : '3D Secure failed';
            }

            completer.complete(PaymentResult(
              success: false,
              message: message,
              errorCode: errorCode,
            ));
          }
        },
        onClose: () {
          debugPrint('🔵 Tap Checkout closed');
          if (!completer.isCompleted) {
            completer.complete(PaymentResult(
              success: false,
              message: lang == 'ar' ? 'تم إغلاق صفحة الدفع' : 'Checkout closed',
              errorCode: PaymentErrorCode.closed,
            ));
          }
        },
        onCancel: () {
          debugPrint('🔵 Tap Checkout cancelled (Android)');
          if (!completer.isCompleted) {
            completer.complete(PaymentResult(
              success: false,
              message: lang == 'ar' ? 'تم إلغاء الدفع' : 'Payment cancelled',
              errorCode: PaymentErrorCode.cancelled,
            ));
          }
        },
      );

      if (!success) {
        if (!completer.isCompleted) {
          completer.complete(PaymentResult(
            success: false,
            message:
                lang == 'ar' ? 'فشل بدء الدفع' : 'Failed to start checkout',
            errorCode: PaymentErrorCode.startFailed,
          ));
        }
      }

      // Wait for the completer with timeout
      return await completer.future.timeout(
        const Duration(minutes: 15),
        onTimeout: () => PaymentResult(
          success: false,
          message: lang == 'ar' ? 'انتهت مهلة الدفع' : 'Payment timeout',
          errorCode: PaymentErrorCode.timeout,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Tap Payment Error: $e');
      debugPrint('❌ Stack: $stackTrace');

      if (!completer.isCompleted) {
        completer.complete(PaymentResult(
          success: false,
          message: e.toString(),
          errorCode: PaymentErrorCode.exception,
        ));
      }
      return completer.future;
    }
  }

  /// Get localized error message
  String getErrorMessage({
    required PaymentErrorCode errorCode,
    bool isArabic = false,
  }) {
    switch (errorCode) {
      case PaymentErrorCode.notInitialized:
        return isArabic
            ? 'خدمة الدفع غير مفعلة'
            : 'Payment service not initialized';
      case PaymentErrorCode.invalidAmount:
        return isArabic ? 'المبلغ غير صالح' : 'Invalid amount';
      case PaymentErrorCode.invalidEmail:
        return isArabic ? 'البريد الإلكتروني غير صالح' : 'Invalid email';
      case PaymentErrorCode.cancelled:
        return isArabic ? 'تم إلغاء الدفع' : 'Payment cancelled';
      case PaymentErrorCode.declined:
        return isArabic
            ? 'تم رفض البطاقة. يرجى استخدام بطاقة أخرى'
            : 'Card declined. Please try a different card';
      case PaymentErrorCode.networkError:
        return isArabic
            ? 'خطأ في الاتصال. تحقق من الإنترنت'
            : 'Network error. Check your connection';
      case PaymentErrorCode.threeDSecureFailed:
        return isArabic
            ? 'فشل التحقق الأمني 3D Secure'
            : '3D Secure verification failed';
      case PaymentErrorCode.timeout:
        return isArabic ? 'انتهت مهلة الدفع' : 'Payment session timed out';
      case PaymentErrorCode.startFailed:
        return isArabic
            ? 'فشل بدء جلسة الدفع'
            : 'Failed to start payment session';
      case PaymentErrorCode.closed:
        return isArabic ? 'تم إغلاق صفحة الدفع' : 'Payment page was closed';
      case PaymentErrorCode.exception:
      case PaymentErrorCode.unknown:
      default:
        return isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';
    }
  }

  /// Get rejection text (legacy support)
  String getRejectionText({bool isArabic = false}) {
    return isArabic
        ? 'عذراً، تم رفض الدفع. يرجى المحاولة مرة أخرى.'
        : 'Sorry, payment was rejected. Please try again.';
  }
}

/// Theme mode for Tap Checkout
enum TapThemeMode {
  light,
  dark,
  dynamic,
}

/// Payment error codes for better error handling
enum PaymentErrorCode {
  none,
  notInitialized,
  invalidAmount,
  invalidEmail,
  cancelled,
  declined,
  networkError,
  threeDSecureFailed,
  timeout,
  startFailed,
  closed,
  exception,
  unknown,
}

/// Payment result model
class PaymentResult {
  final bool success;
  final String? chargeId;
  final String message;
  final Map<String, dynamic>? rawData;
  final PaymentErrorCode errorCode;

  PaymentResult({
    required this.success,
    this.chargeId,
    required this.message,
    this.rawData,
    this.errorCode = PaymentErrorCode.none,
  });

  /// Check if transaction was captured
  bool get isCaptured => rawData?['status'] == 'CAPTURED';

  /// Check if user cancelled
  bool get isCancelled =>
      errorCode == PaymentErrorCode.cancelled ||
      errorCode == PaymentErrorCode.closed;
}

/// Transaction verification result
class TransactionVerificationResult {
  final bool success;
  final String status;
  final String message;
  final Map<String, dynamic>? rawData;

  TransactionVerificationResult({
    required this.success,
    required this.status,
    required this.message,
    this.rawData,
  });

  /// Check if payment was captured
  bool get isCaptured => status == 'CAPTURED';

  /// Check if payment was authorized
  bool get isAuthorized => status == 'AUTHORIZED';

  /// Check if payment was declined
  bool get isDeclined => status == 'DECLINED';
}
