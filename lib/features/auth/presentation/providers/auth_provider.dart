import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInAnonymously(),
    );
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUpWithEmailPassword(
            email: email,
            password: password,
            name: name,
            phoneNumber: phoneNumber,
          ),
    );
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmailPassword(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> signInWithMockPhone(String phoneNumber) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithMockPhone(phoneNumber),
    );
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String, int?) codeSent,
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await authRepository.signInWithCredential(credential);
        state = const AsyncValue.data(null);
      },
      verificationFailed: (e) {
        state = AsyncValue.error(e, StackTrace.current);
      },
      codeSent: (verificationId, resendToken) {
        state = const AsyncValue.data(null);
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  Future<void> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AsyncValue.loading();
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithCredential(credential),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
