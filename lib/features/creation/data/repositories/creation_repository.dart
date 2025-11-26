import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/creation_item.dart';

class CreationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<List<CreationItem>> getCreations() async {
    final uid = _userId;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CreationItem.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading creations from Firestore: $e');
      return [];
    }
  }

  Future<void> saveCreation(CreationItem creation) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .doc(creation.id)
          .set(creation.toMap());
    } catch (e) {
      print('Error saving creation to Firestore: $e');
    }
  }

  Future<void> deleteCreation(String id) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('creations')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting creation from Firestore: $e');
    }
  }
}
