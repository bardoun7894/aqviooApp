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
import 'core/services/remote_config_service.dart';
import 'core/router/app_router.dart';

void main() async {
  runZonedGuarded<void>(() {
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

      // Suppress RenderFlex overflow errors - these are benign layout warnings
      final isOverflowError = exceptionStr.contains('overflowed by') ||
          exceptionStr.contains('RenderFlex');

      if (isImageError || isVideoError || isOverflowError) {
        if (kDebugMode) {
          debugPrint('⚠️ Suppressed error: ${details.exception}');
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

    runApp(const AppBootstrap());
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

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isReady = false;
  Object? _fatalError;
  StackTrace? _fatalStack;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await _initializeCoreServices();
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _fatalError = error;
        _fatalStack = stack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return const ProviderScope(child: AqviooApp());
    }

    if (_fatalError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BootstrapErrorView(
          error: _fatalError!,
          stack: _fatalStack,
          onRetry: () {
            setState(() {
              _fatalError = null;
              _fatalStack = null;
              _isReady = false;
            });
            unawaited(_bootstrap());
          },
        ),
      );
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _BootstrapLoadingView(),
    );
  }
}

Future<void> _initializeCoreServices() async {
  await _runBestEffortStep('dotenv load', () async {
    await dotenv
        .load(fileName: 'assets/env')
        .timeout(const Duration(seconds: 3));
  });

  await _runCriticalStep('firebase initialization', () async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 12));
    } else {
      Firebase.app();
    }
  });

  // Run remaining non-critical init steps in parallel (all depend on Firebase)
  final parallelSteps = <Future<void>>[
    _runBestEffortStep('cache manager initialization', () async {
      await CacheManager.init().timeout(const Duration(seconds: 3));
    }),
    _runBestEffortStep('remote config loading', () async {
      await RemoteConfigService()
          .loadKeys()
          .timeout(const Duration(seconds: 8));
    }),
  ];
  if (!kIsWeb) {
    parallelSteps.add(
      _runBestEffortStep('notification service initialization', () async {
        await NotificationService().init().timeout(const Duration(seconds: 4));
      }),
    );
  }
  await Future.wait(parallelSteps);

  if (!kIsWeb && !Platform.isIOS) {
    await _runBestEffortStep('tap payment initialization', () async {
      final remoteConfig = RemoteConfigService();
      final tapSecretKey = remoteConfig.tapSecretKey;
      final tapPublicKey = remoteConfig.tapPublicKey;
      final tapMerchantId = remoteConfig.tapMerchantId;
      final tapTestMode = remoteConfig.tapTestMode;

      if (tapSecretKey.isNotEmpty && tapPublicKey.isNotEmpty) {
        TapPaymentService().initialize(
          secretKey: tapSecretKey,
          publicKey: tapPublicKey,
          merchantId: tapMerchantId,
          isProduction: !tapTestMode,
        );
      } else {
        debugPrint(
          'Tap payment keys are missing. Configure them in admin settings.',
        );
      }
    });
  }
}

Future<void> _runCriticalStep(
  String name,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (kDebugMode) {
      debugPrint('Startup: $name succeeded');
    }
  } catch (error) {
    debugPrint('Startup: critical step failed - $name: $error');
    rethrow;
  }
}

Future<void> _runBestEffortStep(
  String name,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (kDebugMode) {
      debugPrint('Startup: $name succeeded');
    }
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Startup: non-critical step failed - $name: $error');
    }
  }
}

class _BootstrapLoadingView extends StatelessWidget {
  const _BootstrapLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFAFF),
              Color(0xFFF5F3FF),
              Color(0xFFF0EFFF),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aqvioo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({
    required this.error,
    required this.stack,
    required this.onRetry,
  });

  final Object error;
  final StackTrace? stack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Initialization failed. Please try again.',
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                Text(
                  '$error\n\n$stack',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
