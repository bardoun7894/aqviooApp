import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/payment/tap_payment_service.dart';
import 'core/services/cache_manager.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs instead of hash-based URLs on web
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  try {
    // Load .env file (may fail on web if not bundled properly)
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }

    // Initialize Firebase (only if not already initialized)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // Use the existing app (auto-initialized by native SDK)
      Firebase.app();
    }

    // Initialize cache manager
    await CacheManager.init();
    if (kDebugMode) {
      print('✅ CacheManager initialized');
    }

    // Initialize notification service (only on mobile)
    if (!kIsWeb) {
      try {
        await NotificationService().init();
        await NotificationService().requestPermissions();
        if (kDebugMode) {
          print('✅ NotificationService initialized');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ NotificationService init failed: $e');
        }
      }
    }

    // Initialize Tap Payments SDK (only on mobile platforms, not web)
    if (!kIsWeb) {
      final tapSecretKey = dotenv.env['TAP_SECRET_KEY'] ?? '';
      final tapPublicKey = dotenv.env['TAP_PUBLIC_KEY'] ?? '';
      final tapMerchantId = dotenv.env['TAP_MERCHANT_ID'] ?? '';
      if (kDebugMode) {
        print(
            '🔵 Tap SECRET_KEY from env: ${tapSecretKey.isNotEmpty ? "${tapSecretKey.substring(0, 10)}..." : "empty"}');
        print(
            '🔵 Tap PUBLIC_KEY from env: ${tapPublicKey.isNotEmpty ? "${tapPublicKey.substring(0, 10)}..." : "empty"}');
        print(
            '🔵 Tap MERCHANT_ID from env: ${tapMerchantId.isNotEmpty ? tapMerchantId : "empty"}');
      }
      if (tapSecretKey.isNotEmpty && tapPublicKey.isNotEmpty) {
        TapPaymentService().initialize(
          secretKey: tapSecretKey,
          publicKey: tapPublicKey,
          merchantId: tapMerchantId,
          isProduction: true,
        );
        if (kDebugMode) {
          print('🔵 Tap Payment initialized successfully');
        }
      } else {
        print('❌ Tap Payment keys are empty!');
      }
    }

    runApp(const ProviderScope(child: AqviooApp()));
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error during initialization: $e');
      print('Stack trace: $stackTrace');
    }
    // Show error UI
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
  }
}
