import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/creation_item.dart';

class CreationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cacheKeyPrefix = 'cached_creations';
  static const int _defaultFetchLimit = 100;

  String? get _userId => _auth.currentUser?.uid;

  /// Get creations with cache-first strategy
  Future<List<CreationItem>> getCreations(
      {int limit = _defaultFetchLimit}) async {
    final uid = _userId;
    if (uid == null) return [];

    try {
      // Try to load from cache first for instant UI
      // We do this manually because we want to show *something* immediately
      // before waiting for Firestore
      final cached = await _getCachedCreations();
      if (cached.isNotEmpty) {
        // Return immediately if we have cache, but still fetch fresh data in background
        // Note: In a real app we might want to use a stream or state management to update
        // when the fresh data arrives. Here we just return cached and let the fresh
        // fetch happen on next refresh or via stream.
        // BUT for this specific method, we want fresh data if possible.
        // So we will try to fetch fresh data, and if it fails (offline), return cached.
      }

      // Load from Firestore (source of truth)
      // Use serverAndCache to hopefully get *some* data if offline but persistence is on
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get(const GetOptions(source: Source.serverAndCache));

      final creations =
          snapshot.docs.map((doc) => CreationItem.fromMap(doc.data())).toList();

      // Update cache
      await _cacheCreations(creations);

      return creations;
    } catch (e) {
      if (e.toString().contains('unavailable') ||
          e.toString().contains('offline')) {
        print('⚠️ Firestore unavailable (offline), using cache.');
      } else {
        print('Error loading creations from Firestore: $e');
      }

      // Return cached data if Firebase fails
      final cached = await _getCachedCreations();
      return cached;
    }
  }

  /// Get creations stream for real-time updates
  Stream<List<CreationItem>> getCreationsStream() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('creations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final creations =
          snapshot.docs.map((doc) => CreationItem.fromMap(doc.data())).toList();

      // Update cache in background
      _cacheCreations(creations);

      return creations;
    }).handleError((error) {
      print('Error in creations stream: $error');
      return <CreationItem>[];
    });
  }

  Future<void> saveCreation(CreationItem creation) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .doc(creation.id)
          .set(creation.toMap());

      // Update cache
      final cached = await _getCachedCreations();
      final index = cached.indexWhere((c) => c.id == creation.id);
      if (index >= 0) {
        cached[index] = creation;
      } else {
        cached.insert(0, creation);
      }
      await _cacheCreations(cached);
    } catch (e) {
      print('Error saving creation to Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteCreation(String id) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .doc(id)
          .delete();

      // Update cache
      final cached = await _getCachedCreations();
      cached.removeWhere((c) => c.id == id);
      await _cacheCreations(cached);
    } catch (e) {
      print('Error deleting creation from Firestore: $e');
      rethrow;
    }
  }

  // Cache methods
  Future<List<CreationItem>> _getCachedCreations() async {
    try {
      final uid = _userId;
      if (uid == null) return [];
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKeyForUser(uid));

      if (cachedJson != null) {
        final List<dynamic> decoded = json.decode(cachedJson);
        return decoded
            .map((item) => CreationItem.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading cached creations: $e');
    }
    return [];
  }

  Future<void> _cacheCreations(List<CreationItem> creations) async {
    try {
      final uid = _userId;
      if (uid == null) return;
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(creations.map((c) => c.toMap()).toList());
      await prefs.setString(_cacheKeyForUser(uid), encoded);
    } catch (e) {
      print('Error caching creations: $e');
    }
  }

  /// Clear local cache
  Future<void> clearCache() async {
    try {
      final uid = _userId;
      if (uid == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyForUser(uid));
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Cleanup creations older than 10 days (Kie AI retention limit)
  /// This should be called on app startup to prevent crashes from expired URLs
  static const int _retentionDays = 10;

  Future<int> cleanupExpiredCreations() async {
    final uid = _userId;
    if (uid == null) return 0;

    int deletedCount = 0;
    final cutoffDate =
        DateTime.now().subtract(const Duration(days: _retentionDays));

    try {
      // Get all creations
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .get();

      // Find and delete expired ones
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        DateTime? creationDate;

        if (createdAt is Timestamp) {
          creationDate = createdAt.toDate();
        } else if (createdAt is String) {
          creationDate = DateTime.tryParse(createdAt);
        }

        if (creationDate != null && creationDate.isBefore(cutoffDate)) {
          batch.delete(doc.reference);
          deletedCount++;
          print(
              '🗑️ Deleted expired creation: ${doc.id} (created: $creationDate)');
        }
      }

      if (deletedCount > 0) {
        await batch.commit();
      }

      // Update cache to remove expired items
      if (deletedCount > 0) {
        final cached = await _getCachedCreations();
        final updatedCache =
            cached.where((c) => c.createdAt.isAfter(cutoffDate)).toList();
        await _cacheCreations(updatedCache);
        print('✅ Cleaned up $deletedCount expired creations');
      }
    } catch (e) {
      print('Error cleaning up expired creations: $e');
    }

    return deletedCount;
  }

  String _cacheKeyForUser(String uid) => '${_cacheKeyPrefix}_$uid';
}
