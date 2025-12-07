import 'package:shared_preferences/shared_preferences.dart';

/// Centralized cache manager for the app
/// Handles cache versioning, expiration, and user-specific data
class CacheManager {
  static const String _cacheVersionKey = 'cache_version';
  static const String _currentUserId = 'current_cached_user_id';
  static const int _currentCacheVersion = 2; // Increment this to invalidate all caches

  static SharedPreferences? _prefs;

  /// Initialize cache manager - call this on app startup
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _checkCacheVersion();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('CacheManager not initialized. Call CacheManager.init() first.');
    }
    return _prefs!;
  }

  /// Check cache version and clear if outdated
  static Future<void> _checkCacheVersion() async {
    final storedVersion = _prefs?.getInt(_cacheVersionKey) ?? 0;

    if (storedVersion < _currentCacheVersion) {
      print('🗑️ Cache: Version mismatch ($storedVersion < $_currentCacheVersion), clearing all cache');
      await clearAllCache();
      await _prefs?.setInt(_cacheVersionKey, _currentCacheVersion);
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      // Keep only essential non-cache keys
      if (!key.startsWith('flutter.') && key != _cacheVersionKey) {
        await _prefs?.remove(key);
      }
    }
    print('🗑️ Cache: All cache cleared');
  }

  /// Clear cache for a specific user (call on logout)
  static Future<void> clearUserCache() async {
    final keysToRemove = [
      'cached_user_balance_sar',
      'cached_has_generated_first',
      'cached_user_credits',
      'cached_credits',
      _currentUserId,
    ];

    for (final key in keysToRemove) {
      await _prefs?.remove(key);
    }
    print('🗑️ Cache: User cache cleared');
  }

  /// Check if cached data belongs to current user
  static Future<bool> isValidUserCache(String userId) async {
    final cachedUserId = _prefs?.getString(_currentUserId);
    return cachedUserId == userId;
  }

  /// Set current user ID for cache validation
  static Future<void> setCurrentUser(String userId) async {
    final previousUserId = _prefs?.getString(_currentUserId);

    // If user changed, clear old user's cache
    if (previousUserId != null && previousUserId != userId) {
      print('🗑️ Cache: User changed from $previousUserId to $userId, clearing old cache');
      await clearUserCache();
    }

    await _prefs?.setString(_currentUserId, userId);
  }

  /// Get cached balance (with validation)
  static double? getCachedBalance(String userId) {
    final cachedUserId = _prefs?.getString(_currentUserId);
    if (cachedUserId != userId) {
      return null; // Cache belongs to different user
    }
    return _prefs?.getDouble('cached_user_balance_sar');
  }

  /// Set cached balance
  static Future<void> setCachedBalance(String userId, double balance) async {
    await _prefs?.setString(_currentUserId, userId);
    await _prefs?.setDouble('cached_user_balance_sar', balance);
  }

  /// Get cached hasGeneratedFirst flag
  static bool? getCachedHasGeneratedFirst(String userId) {
    final cachedUserId = _prefs?.getString(_currentUserId);
    if (cachedUserId != userId) {
      return null;
    }
    return _prefs?.getBool('cached_has_generated_first');
  }

  /// Set cached hasGeneratedFirst flag
  static Future<void> setCachedHasGeneratedFirst(String userId, bool value) async {
    await _prefs?.setString(_currentUserId, userId);
    await _prefs?.setBool('cached_has_generated_first', value);
  }
}
