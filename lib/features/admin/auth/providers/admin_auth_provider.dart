import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_user.dart';

class AdminAuthState {
  final AdminUser? adminUser;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AdminAuthState({
    this.adminUser,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AdminAuthState copyWith({
    AdminUser? adminUser,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AdminAuthState(
      adminUser: adminUser ?? this.adminUser,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }
}

class AdminAuthController extends StateNotifier<AdminAuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _cacheAdminIdKey = 'cached_admin_id';

  AdminAuthController() : super(const AdminAuthState()) {
    _checkAuthState();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = const AdminAuthState(isLoading: false);
        return;
      }

      // Check if user is admin in Firestore
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (!adminDoc.exists) {
        // Not an admin, sign out
        await _auth.signOut();
        state = const AdminAuthState(isLoading: false);
        return;
      }

      // Load admin data
      final adminUser = AdminUser.fromMap({
        'id': user.uid,
        ...adminDoc.data()!,
      });

      // Update last login
      await _firestore.collection('admins').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Cache admin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheAdminIdKey, user.uid);

      state = AdminAuthState(
        adminUser: adminUser,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = AdminAuthState(
        isLoading: false,
        errorMessage: 'Failed to check authentication: $e',
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      // Verify user is an admin
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (!adminDoc.exists) {
        // Not an admin, sign out
        await _auth.signOut();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Access denied. Admin privileges required.',
        );
        return;
      }

      // Load admin data
      final adminUser = AdminUser.fromMap({
        'id': user.uid,
        ...adminDoc.data()!,
      });

      // Update last login
      await _firestore.collection('admins').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // Cache admin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheAdminIdKey, user.uid);

      state = AdminAuthState(
        adminUser: adminUser,
        isAuthenticated: true,
        isLoading: false,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _auth.signOut();

      // Clear cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheAdminIdKey);

      state = const AdminAuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sign out failed: $e',
      );
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send reset email: ${e.message}',
      );
    }
  }
}

final adminAuthControllerProvider =
    StateNotifierProvider<AdminAuthController, AdminAuthState>((ref) {
  return AdminAuthController();
});
