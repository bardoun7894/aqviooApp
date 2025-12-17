import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/creation_item.dart';

class CreationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cacheKey = 'cached_creations';

  String? get _userId => _auth.currentUser?.uid;

  /// Get creations with cache-first strategy
  Future<List<CreationItem>> getCreations() async {
    final uid = _userId;
    if (uid == null) return [];

    try {
      // Try to load from cache first for instant UI
      await _getCachedCreations();

      // Load from Firestore (source of truth)
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .orderBy('createdAt', descending: true)
          .get();

      final creations = snapshot.docs
          .map((doc) => CreationItem.fromMap(doc.data()))
          .toList();

      // Update cache
      await _cacheCreations(creations);

      return creations;
    } catch (e) {
      print('Error loading creations from Firestore: $e');

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
      final creations = snapshot.docs
          .map((doc) => CreationItem.fromMap(doc.data()))
          .toList();

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
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);

      if (cachedJson != null) {
        final List<dynamic> decoded = json.decode(cachedJson);
        return decoded.map((item) => CreationItem.fromMap(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error loading cached creations: $e');
    }
    return [];
  }

  Future<void> _cacheCreations(List<CreationItem> creations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(creations.map((c) => c.toMap()).toList());
      await prefs.setString(_cacheKey, encoded);
    } catch (e) {
      print('Error caching creations: $e');
    }
  }

  /// Clear local cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
