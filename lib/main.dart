import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/payment/tap_payment_service.dart';
import 'core/services/cache_manager.dart';
import 'core/services/notification_service.dart';
import 'core/router/app_router.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Setup Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      final exceptionStr = details.exception.toString();

      // Suppress media 404 errors - these are handled gracefully in UI
      final isImageError = exceptionStr.contains('NetworkImageLoadException') ||
          exceptionStr.contains('HTTP request failed, statusCode: 404');
      final isVideoError = exceptionStr.contains('Source error') ||
          exceptionStr.contains('VideoError') ||
          exceptionStr.contains('ExoPlaybackException') ||
          exceptionStr.contains('PlatformException(VideoError');

      if (isImageError || isVideoError) {
        if (kDebugMode) {
          debugPrint('⚠️ Suppressed media error: ${details.exception}');
        }
        return; // Don't propagate
      }
      FlutterError.presentError(details);
      _handleGlobalError(details.exception, details.stack);
    };

    // Use path-based URLs instead of hash-based URLs on web
    if (kIsWeb) {
      usePathUrlStrategy();
    }

    try {
      // Load .env file (may fail on web if not bundled properly)
      try {
        await dotenv.load(fileName: "assets/env");
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Warning: Could not load .env file: $e');
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
        debugPrint('✅ CacheManager initialized');
      }

      // Initialize notification service (only on mobile)
      if (!kIsWeb) {
        try {
          await NotificationService().init();
          await NotificationService().requestPermissions();
          if (kDebugMode) {
            debugPrint('✅ NotificationService initialized');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ NotificationService init failed: $e');
          }
        }
      }

      // Check AI API Keys
      String openAiKey = '';

      if (dotenv.isInitialized) {
        openAiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      }

      if (kDebugMode) {
        if (!dotenv.isInitialized) {
          debugPrint(
              '⚠️ Warning: dotenv not initialized. Using empty API keys.');
        } else {
          if (openAiKey.isEmpty) {
            debugPrint('⚠️ Warning: OPENAI_API_KEY is missing');
          }
        }
      }

      // Initialize Tap Payments SDK (Android and Web only - iOS uses IAP)
      if (!kIsWeb && !Platform.isIOS) {
        final tapSecretKey =
            dotenv.isInitialized ? (dotenv.env['TAP_SECRET_KEY'] ?? '') : '';
        final tapPublicKey =
            dotenv.isInitialized ? (dotenv.env['TAP_PUBLIC_KEY'] ?? '') : '';
        final tapMerchantId =
            dotenv.isInitialized ? (dotenv.env['TAP_MERCHANT_ID'] ?? '') : '';
        if (kDebugMode) {
          debugPrint(
              '🔵 Tap SECRET_KEY from env: ${tapSecretKey.isNotEmpty ? "${tapSecretKey.substring(0, 10)}..." : "empty"}');
          debugPrint(
              '🔵 Tap PUBLIC_KEY from env: ${tapPublicKey.isNotEmpty ? "${tapPublicKey.substring(0, 10)}..." : "empty"}');
          debugPrint(
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
            debugPrint('🔵 Tap Payment initialized successfully');
          }
        } else {
          debugPrint('❌ Tap Payment keys are empty!');
        }
      } else if (Platform.isIOS && kDebugMode) {
        debugPrint('🍎 iOS: Skipping Tap Payment - using IAP only');
      }

      runApp(const ProviderScope(child: AqviooApp()));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error during initialization: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      // Show error UI for initialization failures
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Initialization Error:\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ));
    }
  }, (error, stack) {
    final errorStr = error.toString();

    // Suppress media 404 errors in async errors too
    final isImageError = errorStr.contains('NetworkImageLoadException') ||
        errorStr.contains('HTTP request failed, statusCode: 404');
    final isVideoError = errorStr.contains('Source error') ||
        errorStr.contains('VideoError') ||
        errorStr.contains('ExoPlaybackException') ||
        errorStr.contains('PlatformException(VideoError');

    if (isImageError || isVideoError) {
      if (kDebugMode) {
        debugPrint('⚠️ Suppressed async media error: $error');
      }
      return; // Don't propagate
    }
    debugPrint('🔴 Global Async Error detected: $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stack);
    }
    _handleGlobalError(error, stack);
  });
}

/// Handle global errors by navigating to the error screen
void _handleGlobalError(Object error, StackTrace? stack) {
  // Prevent infinite error loops by checking explicitly or relying on UI stability
  // Schedule navigation to ensure we have a frame/context
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        debugPrint('👉 Navigating to /error screen...');
        GoRouter.of(context).go(
          '/error',
          extra: {'error': '$error\n\n$stack'},
        );
      } catch (e) {
        debugPrint('⚠️ Failed to navigate to error screen: $e');
      }
    } else {
      debugPrint('⚠️ Root navigator context is null, cannot navigate.');
    }
  });
}
