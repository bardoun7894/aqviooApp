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
      );
    }

    return userCredential;
  }

  /// Save user profile to Firestore users collection
  Future<void> _saveUserToFirestore(
    User user, {
    String? displayName,
    String? email,
    bool isAnonymous = false,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      // Check if user document already exists
      final existingDoc = await userDoc.get();

      if (!existingDoc.exists) {
        // Create new user document
        await userDoc.set({
          'displayName': displayName ?? user.displayName ?? 'Anonymous',
          'email': email ?? user.email,
          'phoneNumber': user.phoneNumber,
          'photoURL': user.photoURL,
          'isAnonymous': isAnonymous,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Initialize credits subcollection
        await userDoc.collection('data').doc('credits').set({
          'balance': 10.0, // Initial free balance in SAR
          'hasGeneratedFirst': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print('✅ New user saved to Firestore: ${user.uid}');
      } else {
        // Update last login time
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print('✅ Existing user login updated: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error saving user to Firestore: $e');
      // Don't rethrow - we don't want to block auth if Firestore save fails
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
