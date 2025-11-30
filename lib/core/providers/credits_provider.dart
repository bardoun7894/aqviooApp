import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/creation/domain/models/creation_config.dart';

class CreditsState {
  final int credits;
  final bool hasGeneratedFirstVideo;
  final bool isLoading;

  const CreditsState({
    required this.credits,
    required this.hasGeneratedFirstVideo,
    this.isLoading = false,
  });

  CreditsState copyWith({
    int? credits,
    bool? hasGeneratedFirstVideo,
    bool? isLoading,
  }) {
    return CreditsState(
      credits: credits ?? this.credits,
      hasGeneratedFirstVideo: hasGeneratedFirstVideo ?? this.hasGeneratedFirstVideo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CreditsController extends StateNotifier<CreditsState> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cacheCreditsKey = 'cached_user_credits';
  static const String _cacheFirstVideoKey = 'cached_has_generated_first_video';
  static const int _initialCredits = 10;
  static const int _creditCostPerVideo = 10;
  static const int _creditCostPerImage = 5;

  CreditsController(this.ref)
      : super(const CreditsState(
          credits: _initialCredits,
          hasGeneratedFirstVideo: false,
        )) {
    _loadCredits();
  }

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference? get _userCreditsDoc {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('data').doc('credits');
  }

  Future<void> _loadCredits() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = _userId;

      if (userId == null) {
        // Not logged in, use default
        state = CreditsState(
          credits: _initialCredits,
          hasGeneratedFirstVideo: false,
          isLoading: false,
        );
        return;
      }

      // Try to load from cache first for instant UI
      final prefs = await SharedPreferences.getInstance();
      final cachedCredits = prefs.getInt(_cacheCreditsKey);
      final cachedFirstVideo = prefs.getBool(_cacheFirstVideoKey);

      if (cachedCredits != null) {
        state = state.copyWith(
          credits: cachedCredits,
          hasGeneratedFirstVideo: cachedFirstVideo ?? false,
        );
      }

      // Then load from Firebase (source of truth)
      final doc = await _userCreditsDoc?.get();

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final credits = data['credits'] as int? ?? _initialCredits;
        final hasGeneratedFirstVideo = data['hasGeneratedFirstVideo'] as bool? ?? false;

        // Update cache
        await prefs.setInt(_cacheCreditsKey, credits);
        await prefs.setBool(_cacheFirstVideoKey, hasGeneratedFirstVideo);

        state = CreditsState(
          credits: credits,
          hasGeneratedFirstVideo: hasGeneratedFirstVideo,
          isLoading: false,
        );
      } else {
        // First time user - initialize in Firestore
        await _userCreditsDoc?.set({
          'credits': _initialCredits,
          'hasGeneratedFirstVideo': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Update cache
        await prefs.setInt(_cacheCreditsKey, _initialCredits);
        await prefs.setBool(_cacheFirstVideoKey, false);

        state = CreditsState(
          credits: _initialCredits,
          hasGeneratedFirstVideo: false,
          isLoading: false,
        );
      }
    } catch (e) {
      // On error, keep current state or use cached values
      print('Error loading credits: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  int getCreditCost(OutputType outputType) {
    return outputType == OutputType.video
        ? _creditCostPerVideo
        : _creditCostPerImage;
  }

  Future<bool> canGenerate(OutputType outputType) async {
    // Check if user has enough credits based on output type
    final cost = getCreditCost(outputType);
    return state.credits >= cost;
  }

  Future<void> deductCreditsForGeneration(OutputType outputType) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final cost = getCreditCost(outputType);
      final newCredits = state.credits - cost;

      // Update Firestore first (source of truth)
      await _userCreditsDoc?.update({
        'credits': newCredits,
        'hasGeneratedFirstVideo': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheCreditsKey, newCredits);
      await prefs.setBool(_cacheFirstVideoKey, true);

      // Update state
      state = state.copyWith(
        credits: newCredits,
        hasGeneratedFirstVideo: true,
      );
    } catch (e) {
      print('Error deducting credits: $e');
      rethrow;
    }
  }

  Future<void> addCredits(int amount) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final newCredits = state.credits + amount;

      // Update Firestore first (source of truth)
      await _userCreditsDoc?.update({
        'credits': newCredits,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheCreditsKey, newCredits);

      // Update state
      state = state.copyWith(credits: newCredits);
    } catch (e) {
      print('Error adding credits: $e');
      rethrow;
    }
  }

  int get creditCost => _creditCostPerVideo;
}

final creditsControllerProvider =
    StateNotifierProvider<CreditsController, CreditsState>((ref) {
  return CreditsController(ref);
});
