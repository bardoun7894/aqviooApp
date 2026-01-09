import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Toggle this to switch between Mock and Firebase
const bool useMockAuth = false;

abstract class AuthRepository {
  Stream<bool> get authStateChanges;
  bool get isAnonymous;
  User? get currentUser;
  Future<void> signInAnonymously();
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  });
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  });
  Future<void> signInWithCredential(PhoneAuthCredential credential);
  Future<void> signInWithMockPhone(String phoneNumber);
  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  final _authStateController = StreamController<bool>.broadcast();
  bool _isLoggedIn = false;
  bool _isAnonymous = false;

  MockAuthRepository() {
    // Emit initial state immediately to avoid stuck splash screen
    _authStateController.add(_isLoggedIn);
  }

  @override
  Stream<bool> get authStateChanges async* {
    yield _isLoggedIn;
    yield* _authStateController.stream;
  }

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  User? get currentUser => null;

  @override
  Future<void> signInAnonymously() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isAnonymous = true;
    _authStateController.add(true);
  }

  @override
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isAnonymous = false;
    _authStateController.add(true);
    // Return a mock UserCredential - this won't be used in mock mode
    throw UnimplementedError('Mock auth does not return UserCredential');
  }

  @override
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isAnonymous = false;
    _authStateController.add(true);
    // Return a mock UserCredential - this won't be used in mock mode
    throw UnimplementedError('Mock auth does not return UserCredential');
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate code sent
    codeSent('mock_verification_id', 123);
  }

  @override
  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isAnonymous = false;
    _authStateController.add(true);
  }

  @override
  Future<void> signInWithMockPhone(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isAnonymous = false;
    _authStateController.add(true);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    _isAnonymous = false;
    _authStateController.add(false);
  }
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  Stream<bool> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user != null);

  @override
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? false;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    // Save anonymous user to Firestore
    if (userCredential.user != null) {
      await _saveUserToFirestore(userCredential.user!, isAnonymous: true);
    }
  }

  @override
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update display name
    await userCredential.user?.updateDisplayName(name);

    // Save user to Firestore
    if (userCredential.user != null) {
      await _saveUserToFirestore(
        userCredential.user!,
        displayName: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    }

    return userCredential;
  }

  /// Save user profile to Firestore users collection
  Future<void> _saveUserToFirestore(
    User user, {
    String? displayName,
    String? email,
    String? phoneNumber,
    bool isAnonymous = false,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      String? finalPhone = phoneNumber ?? user.phoneNumber;
      String? finalEmail = email ?? user.email;

      // Extract phone from dummy email if needed
      if (finalPhone == null &&
          finalEmail != null &&
          finalEmail.endsWith('@phone.aqvioo.com')) {
        finalPhone = finalEmail.split('@').first;
      }

      // Use set with merge: true to avoid the preliminary get() call
      // which is prone to "client is offline" errors.
      await userDoc.set({
        'displayName': displayName ?? user.displayName ?? 'Anonymous',
        'email': finalEmail,
        'phoneNumber': finalPhone,
        'photoURL': user.photoURL,
        'isAnonymous': isAnonymous,
        'status': 'active',
        'lastLoginAt': FieldValue.serverTimestamp(),
        // Only set createdAt if it doesn't exist
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Check if credits exist separately - wrapped in a quiet try-catch
      try {
        final creditsDoc = userDoc.collection('data').doc('credits');
        // Use a 2-second timeout and prefer cache to avoid blocking on unstable networks
        final creditsSnap = await creditsDoc
            .get(const GetOptions(source: Source.serverAndCache))
            .timeout(const Duration(seconds: 2));

        if (!creditsSnap.exists) {
          await creditsDoc.set({
            'balance': 100.0,
            'hasGeneratedFirst': false,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // Log but don't crash - credits can be initialized later if needed
        print('ℹ️ Note: Credits check skipped due to network: $e');
      }

      print('✅ User profile synced to Firestore: ${user.uid}');
    } catch (e) {
      print('⚠️ Non-critical Error syncing user to Firestore: $e');
      // We don't rethrow because the user IS authenticated.
      // Firestore will sync the write when it comes back online.
    }
  }

  @override
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Ensure user exists in Firestore (for existing auth users)
    if (userCredential.user != null) {
      await _saveUserToFirestore(
        userCredential.user!,
        email: email,
      );
    }

    return userCredential;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    // Save phone user to Firestore
    if (userCredential.user != null) {
      await _saveUserToFirestore(userCredential.user!);
    }
  }

  @override
  Future<void> signInWithMockPhone(String phoneNumber) async {
    // 1. Sign in anonymously first to get a valid Firebase UID
    final userCredential = await _firebaseAuth.signInAnonymously();

    // 2. Save user to Firestore, but pretending they have a phone number
    if (userCredential.user != null) {
      final user = userCredential.user!;
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Create/Overwrite with phone data
      await userDoc.set({
        'displayName': 'Test User',
        'phoneNumber': phoneNumber, // Save the magic number
        'isAnonymous': false, // Pretend it's not anonymous
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Initialize credits subcollection
      await userDoc.collection('data').doc('credits').set({
        'balance': 100.0, // Give some test credits
        'hasGeneratedFirst': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMockAuth) {
    return MockAuthRepository();
  } else {
    return FirebaseAuthRepository(FirebaseAuth.instance);
  }
});

final authStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
