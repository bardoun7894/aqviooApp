import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_manager.dart';

/// Service to fetch and manage API keys from Firestore.
/// Keys are stored in the `config/api_keys` Firestore document
/// and can be managed by admins from the admin dashboard.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cached keys in memory
  String _kieApiKey = '';
  String _openaiApiKey = '';
  String _tapSecretKey = '';
  String _tapPublicKey = '';
  String _tapMerchantId = '';
  bool _tapTestMode = false;
  bool _isLoaded = false;

  // Getters
  String get kieApiKey => _kieApiKey;
  String get openaiApiKey => _openaiApiKey;
  String get tapSecretKey => _tapSecretKey;
  String get tapPublicKey => _tapPublicKey;
  String get tapMerchantId => _tapMerchantId;
  bool get tapTestMode => _tapTestMode;
  bool get isLoaded => _isLoaded;

  /// Firestore document reference for API keys
  DocumentReference get _configDoc =>
      _firestore.collection('config').doc('api_keys');

  /// Load API keys from Firestore with local cache fallback.
  /// Called once during app initialization.
  Future<void> loadKeys() async {
    try {
      debugPrint('🔑 RemoteConfig: Loading API keys from Firestore...');

      // Try Firestore first
      final doc = await _configDoc
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 8));

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _kieApiKey = data['kie_api_key'] as String? ?? '';
        _openaiApiKey = data['openai_api_key'] as String? ?? '';
        _tapSecretKey = data['tap_secret_key'] as String? ?? '';
        _tapPublicKey = data['tap_public_key'] as String? ?? '';
        _tapMerchantId = data['tap_merchant_id'] as String? ?? '';
        _tapTestMode = data['tap_test_mode'] as bool? ?? false;
        _isLoaded = true;

        // Cache locally for offline use
        await _cacheKeys();

        debugPrint('🔑 RemoteConfig: Keys loaded from Firestore');
        if (kDebugMode) {
          debugPrint(
              '🔑 KIE key: ${_kieApiKey.isNotEmpty ? "${_kieApiKey.substring(0, 4)}..." : "empty"}');
          debugPrint(
              '🔑 OpenAI key: ${_openaiApiKey.isNotEmpty ? "${_openaiApiKey.substring(0, 7)}..." : "empty"}');
          debugPrint(
              '🔑 Tap keys: secret=${_tapSecretKey.isNotEmpty}, public=${_tapPublicKey.isNotEmpty}');
        }
      } else {
        debugPrint(
            '🔑 RemoteConfig: No config document found, trying local cache...');
        await _loadFromCache();

        // If still no keys, seed initial keys from hardcoded defaults
        // This runs ONCE to populate Firestore, then keys are managed via admin dashboard
        if (!_isLoaded) {
          debugPrint(
              '🔑 RemoteConfig: No config found. Seeding initial keys to Firestore...');
          await _seedInitialKeys();
        }
      }
    } catch (e) {
      debugPrint('⚠️ RemoteConfig: Error loading from Firestore: $e');
      // Fall back to local cache
      await _loadFromCache();

      // If cache is also empty (first run, user not authenticated yet),
      // use hardcoded fallback so the app works immediately
      if (!_isLoaded) {
        debugPrint(
            '🔑 RemoteConfig: Using hardcoded fallback keys (will sync to Firestore after auth)');
        _useHardcodedFallback();
      }
    }
  }

  /// Called after user authenticates to sync keys to Firestore if needed.
  /// This handles the case where loadKeys() failed during startup
  /// because the user wasn't authenticated yet.
  Future<void> ensureKeysInFirestore() async {
    if (_isLoaded) {
      // Check if we need to seed to Firestore (we might be using fallback keys)
      try {
        final doc = await _configDoc
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 8));
        if (!doc.exists) {
          debugPrint(
              '🔑 RemoteConfig: Seeding keys to Firestore after auth...');
          await _seedInitialKeys();
        } else {
          // Firestore has keys, load them (they might be newer than our fallback)
          final data = doc.data() as Map<String, dynamic>;
          _kieApiKey = data['kie_api_key'] as String? ?? '';
          _openaiApiKey = data['openai_api_key'] as String? ?? '';
          _tapSecretKey = data['tap_secret_key'] as String? ?? '';
          _tapPublicKey = data['tap_public_key'] as String? ?? '';
          _tapMerchantId = data['tap_merchant_id'] as String? ?? '';
          _tapTestMode = data['tap_test_mode'] as bool? ?? false;
          await _cacheKeys();
          debugPrint(
              '🔑 RemoteConfig: Keys refreshed from Firestore after auth');
        }
      } catch (e) {
        debugPrint('⚠️ RemoteConfig: ensureKeysInFirestore failed: $e');
      }
    }
  }

  /// Save/update API keys to Firestore (admin only).
  Future<void> saveKeys({
    String? kieApiKey,
    String? openaiApiKey,
    String? tapSecretKey,
    String? tapPublicKey,
    String? tapMerchantId,
    bool? tapTestMode,
  }) async {
    final updates = <String, dynamic>{
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (kieApiKey != null) {
      updates['kie_api_key'] = kieApiKey;
      _kieApiKey = kieApiKey;
    }
    if (openaiApiKey != null) {
      updates['openai_api_key'] = openaiApiKey;
      _openaiApiKey = openaiApiKey;
    }
    if (tapSecretKey != null) {
      updates['tap_secret_key'] = tapSecretKey;
      _tapSecretKey = tapSecretKey;
    }
    if (tapPublicKey != null) {
      updates['tap_public_key'] = tapPublicKey;
      _tapPublicKey = tapPublicKey;
    }
    if (tapMerchantId != null) {
      updates['tap_merchant_id'] = tapMerchantId;
      _tapMerchantId = tapMerchantId;
    }
    if (tapTestMode != null) {
      updates['tap_test_mode'] = tapTestMode;
      _tapTestMode = tapTestMode;
    }

    await _configDoc.set(updates, SetOptions(merge: true));
    await _cacheKeys();

    debugPrint('🔑 RemoteConfig: Keys saved to Firestore');
  }

  /// Cache keys locally using SharedPreferences via CacheManager
  Future<void> _cacheKeys() async {
    try {
      final prefs = CacheManager.prefs;
      await prefs.setString('rc_kie_api_key', _kieApiKey);
      await prefs.setString('rc_openai_api_key', _openaiApiKey);
      await prefs.setString('rc_tap_secret_key', _tapSecretKey);
      await prefs.setString('rc_tap_public_key', _tapPublicKey);
      await prefs.setString('rc_tap_merchant_id', _tapMerchantId);
      await prefs.setBool('rc_tap_test_mode', _tapTestMode);
      await prefs.setBool('rc_is_loaded', true);
    } catch (e) {
      debugPrint('⚠️ RemoteConfig: Error caching keys: $e');
    }
  }

  /// Load keys from local cache (offline fallback)
  Future<void> _loadFromCache() async {
    try {
      final prefs = CacheManager.prefs;
      final cached = prefs.getBool('rc_is_loaded') ?? false;
      if (!cached) return;

      _kieApiKey = prefs.getString('rc_kie_api_key') ?? '';
      _openaiApiKey = prefs.getString('rc_openai_api_key') ?? '';
      _tapSecretKey = prefs.getString('rc_tap_secret_key') ?? '';
      _tapPublicKey = prefs.getString('rc_tap_public_key') ?? '';
      _tapMerchantId = prefs.getString('rc_tap_merchant_id') ?? '';
      _tapTestMode = prefs.getBool('rc_tap_test_mode') ?? false;
      _isLoaded = true;

      debugPrint('🔑 RemoteConfig: Keys loaded from local cache');
    } catch (e) {
      debugPrint('⚠️ RemoteConfig: Error loading from cache: $e');
    }
  }

  /// Use hardcoded fallback keys in memory (when Firestore and cache are both unavailable)
  /// Keys are loaded from Firestore at runtime - these are empty fallbacks only
  void _useHardcodedFallback() {
    _kieApiKey = const String.fromEnvironment('KIE_API_KEY', defaultValue: '');
    _openaiApiKey =
        const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    _tapSecretKey =
        const String.fromEnvironment('TAP_SECRET_KEY', defaultValue: '');
    _tapPublicKey =
        const String.fromEnvironment('TAP_PUBLIC_KEY', defaultValue: '');
    _tapMerchantId =
        const String.fromEnvironment('TAP_MERCHANT_ID', defaultValue: '');
    _tapTestMode = false;
    _isLoaded = true;
  }

  /// One-time migration: seed Firestore with initial API keys.
  /// This runs only if the config/api_keys document doesn't exist yet.
  /// After this, keys are managed exclusively via the admin dashboard.
  Future<void> _seedInitialKeys() async {
    try {
      // Keys are provided via environment variables (Codemagic CI) or Firestore
      final initialKeys = {
        'kie_api_key':
            const String.fromEnvironment('KIE_API_KEY', defaultValue: ''),
        'openai_api_key':
            const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
        'tap_secret_key':
            const String.fromEnvironment('TAP_SECRET_KEY', defaultValue: ''),
        'tap_public_key':
            const String.fromEnvironment('TAP_PUBLIC_KEY', defaultValue: ''),
        'tap_merchant_id':
            const String.fromEnvironment('TAP_MERCHANT_ID', defaultValue: ''),
        'tap_test_mode': false,
      };

      await _configDoc.set({
        ...initialKeys,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Load the seeded keys into memory
      _kieApiKey = initialKeys['kie_api_key'] as String;
      _openaiApiKey = initialKeys['openai_api_key'] as String;
      _tapSecretKey = initialKeys['tap_secret_key'] as String;
      _tapPublicKey = initialKeys['tap_public_key'] as String;
      _tapMerchantId = initialKeys['tap_merchant_id'] as String;
      _tapTestMode = initialKeys['tap_test_mode'] as bool;
      _isLoaded = true;

      await _cacheKeys();
      debugPrint(
          '🔑 RemoteConfig: Initial keys seeded to Firestore successfully');
    } catch (e) {
      debugPrint('⚠️ RemoteConfig: Failed to seed initial keys: $e');
      // If seeding fails, fall back to environment variable values
      _kieApiKey =
          const String.fromEnvironment('KIE_API_KEY', defaultValue: '');
      _openaiApiKey =
          const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
      _tapSecretKey =
          const String.fromEnvironment('TAP_SECRET_KEY', defaultValue: '');
      _tapPublicKey =
          const String.fromEnvironment('TAP_PUBLIC_KEY', defaultValue: '');
      _tapMerchantId =
          const String.fromEnvironment('TAP_MERCHANT_ID', defaultValue: '');
      _tapTestMode = false;
      _isLoaded = true;
      await _cacheKeys();
    }
  }

  /// Reload keys from Firestore (e.g., after admin updates them)
  Future<void> reload() async {
    _isLoaded = false;
    await loadKeys();
  }
}

/// Riverpod provider for RemoteConfigService
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});
