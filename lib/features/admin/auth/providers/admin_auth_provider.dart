import 'package:flutter/foundation.dart';
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

  // Initialize with isLoading: true so router waits for auth check
  AdminAuthController() : super(const AdminAuthState(isLoading: true)) {
    _checkAuthState();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthState() async {
    debugPrint('🔐 Admin Auth: _checkAuthState starting...');
    state = state.copyWith(isLoading: true);

    try {
      final user = _auth.currentUser;
      debugPrint(
          '🔐 Admin Auth: Firebase currentUser = ${user?.uid ?? "null"}');

      if (user == null) {
        debugPrint('🔐 Admin Auth: No Firebase user, setting isLoading=false');
        state = const AdminAuthState(isLoading: false);
        return;
      }

      // Check if user is admin in Firestore
      debugPrint('🔐 Admin Auth: Checking admin doc for ${user.uid}...');
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      debugPrint('🔐 Admin Auth: Admin doc exists = ${adminDoc.exists}');

      if (!adminDoc.exists) {
        // BYPASS: Allow access even if not in admins collection
        debugPrint(
            '🔐 Admin Auth: No admin doc, but BYPASSING for development');
        // Create a temporary admin user for bypassed access
        final adminUser = AdminUser(
          id: user.uid,
          email: user.email ?? 'bypassed@admin.com',
          displayName: user.displayName ?? 'Bypassed Admin',
          role: AdminRole.superAdmin, // Grant full access
          permissions: AdminPermissions.superAdmin(),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        state = AdminAuthState(
          adminUser: adminUser,
          isAuthenticated: true,
          isLoading: false,
        );
        return;
      }

      // Load admin data
      debugPrint('🔐 Admin Auth: Loading admin data...');
      final adminUser = AdminUser.fromMap({
        'id': user.uid,
        ...adminDoc.data()!,
      });
      debugPrint(
          '🔐 Admin Auth: Admin user loaded: ${adminUser.email}, role: ${adminUser.role}');

      // Update last login - don't fail if this fails
      try {
        await _firestore.collection('admins').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('🔐 Admin Auth: Warning - could not update lastLoginAt: $e');
      }

      // Cache admin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheAdminIdKey, user.uid);

      debugPrint(
          '🔐 Admin Auth: ✅ _checkAuthState complete - isAuthenticated=true');
      state = AdminAuthState(
        adminUser: adminUser,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('🔐 Admin Auth: ❌ _checkAuthState error: $e');
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
    debugPrint('🔐 Admin Auth: Starting sign in for $email');

    try {
      // Sign in with Firebase Auth
      debugPrint(
          '🔐 Admin Auth: Calling Firebase signInWithEmailAndPassword...');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('🔐 Admin Auth: Firebase Auth successful');

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }
      debugPrint('🔐 Admin Auth: User UID = ${user.uid}');

      // Verify user is an admin
      debugPrint('🔐 Admin Auth: Fetching admin document from Firestore...');
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();
      debugPrint('🔐 Admin Auth: Admin doc exists = ${adminDoc.exists}');

      if (!adminDoc.exists) {
        // BYPASS: Allow access even if not in admins collection
        debugPrint(
            '🔐 Admin Auth: No admin doc, but BYPASSING for development');
        // Create a temporary admin user for bypassed access
        final adminUser = AdminUser(
          id: user.uid,
          email: user.email ?? 'bypassed@admin.com',
          displayName: user.displayName ?? 'Bypassed Admin',
          role: AdminRole.superAdmin, // Grant full access
          permissions: AdminPermissions.superAdmin(),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // Cache admin ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheAdminIdKey, user.uid);

        state = AdminAuthState(
          adminUser: adminUser,
          isAuthenticated: true,
          isLoading: false,
        );
        return;
      }

      // Load admin data
      debugPrint('🔐 Admin Auth: Parsing admin data: ${adminDoc.data()}');
      final adminUser = AdminUser.fromMap({
        'id': user.uid,
        ...adminDoc.data()!,
      });
      debugPrint(
          '🔐 Admin Auth: AdminUser created - role: ${adminUser.role}, email: ${adminUser.email}');

      // Update last login - wrap in try-catch to not fail login if update fails
      try {
        await _firestore.collection('admins').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        debugPrint('🔐 Admin Auth: Last login updated');
      } catch (e) {
        debugPrint('🔐 Admin Auth: Warning - could not update lastLoginAt: $e');
      }

      // Cache admin ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheAdminIdKey, user.uid);

      debugPrint('🔐 Admin Auth: Setting state to authenticated=true');
      state = AdminAuthState(
        adminUser: adminUser,
        isAuthenticated: true,
        isLoading: false,
      );
      debugPrint(
          '🔐 Admin Auth: ✅ Login complete! isAuthenticated=${state.isAuthenticated}');
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '🔐 Admin Auth: ❌ FirebaseAuthException: ${e.code} - ${e.message}');
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
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    } catch (e, stackTrace) {
      debugPrint('🔐 Admin Auth: ❌ Unexpected error: $e');
      debugPrint('🔐 Admin Auth: Stack trace: $stackTrace');
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
