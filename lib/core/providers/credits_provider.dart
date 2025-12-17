import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/creation/domain/models/creation_config.dart';
import '../services/cache_manager.dart';

/// Pricing in SAR (Saudi Riyal)
class Pricing {
  static const double videoCost = 2.99; // SAR per video
  static const double imageCost = 1.99; // SAR per image
  static const double initialBalance = 10.0; // SAR for new users
  static const String currency = '﷼'; // Saudi Riyal symbol
  static const String currencyCode = 'SAR';
}

class CreditsState {
  final double balance; // Balance in SAR
  final bool hasGeneratedFirst;
  final bool isLoading;

  const CreditsState({
    required this.balance,
    required this.hasGeneratedFirst,
    this.isLoading = false,
  });

  /// For backward compatibility - returns balance as int credits
  int get credits => balance.floor();

  CreditsState copyWith({
    double? balance,
    bool? hasGeneratedFirst,
    bool? isLoading,
  }) {
    return CreditsState(
      balance: balance ?? this.balance,
      hasGeneratedFirst: hasGeneratedFirst ?? this.hasGeneratedFirst,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CreditsController extends StateNotifier<CreditsState> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _creditsSubscription;
  String? _lastLoadedUserId;

  CreditsController(this.ref)
      : super(const CreditsState(
          balance: 0,
          hasGeneratedFirst: false,
          isLoading: true,
        )) {
    _init();
  }

  void _init() {
    // Listen to auth state changes and reload balance when user changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      print('🔄 Credits: Auth state changed, user: ${user?.uid}');
      _handleAuthChange(user);
    });
  }

  Future<void> _handleAuthChange(User? user) async {
    if (user == null) {
      // User logged out - clear cache and stop listener
      print('💰 Credits: User logged out, clearing cache');
      _creditsSubscription?.cancel();
      _creditsSubscription = null;
      await CacheManager.clearUserCache();
      _lastLoadedUserId = null;
      state = const CreditsState(
        balance: 0,
        hasGeneratedFirst: false,
        isLoading: false,
      );
    } else {
      // User logged in or changed
      if (_lastLoadedUserId != user.uid) {
        print(
            '💰 Credits: New user detected, setting up cache for ${user.uid}');
        await CacheManager.setCurrentUser(user.uid);
        // Start real-time listener for this user
        _startCreditsListener();
      }
      await _loadBalance();
    }
  }

  /// Start real-time listener for credits document changes
  void _startCreditsListener() {
    // Cancel existing subscription
    _creditsSubscription?.cancel();

    final docRef = _userCreditsDoc;
    if (docRef == null) {
      print('💰 Credits: Cannot start listener - no user');
      return;
    }

    print('💰 Credits: Starting real-time listener');
    _creditsSubscription = docRef.snapshots().listen(
      (snapshot) {
        if (!snapshot.exists) {
          print('💰 Credits: Document deleted or not found');
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        print('💰 Credits: Real-time update received: $data');

        // Parse balance (support both 'balance' and 'credits' fields)
        double balanceVal = 0.0;
        double creditsVal = 0.0;

        if (data.containsKey('balance')) {
          balanceVal = (data['balance'] as num).toDouble();
        }

        if (data.containsKey('credits')) {
          creditsVal = (data['credits'] as num).toDouble();
        }

        double balance;
        if (!data.containsKey('balance') && !data.containsKey('credits')) {
          balance = Pricing.initialBalance;
        } else {
          // Take the maximum to ensure user doesn't lose credits
          balance = balanceVal > creditsVal ? balanceVal : creditsVal;
        }

        final hasGeneratedFirst = data['hasGeneratedFirst'] as bool? ??
            data['hasGeneratedFirstVideo'] as bool? ??
            false;

        // Only update if different from current state
        if (state.balance != balance ||
            state.hasGeneratedFirst != hasGeneratedFirst) {
          print(
              '💰 Credits: Updating state - balance: $balance, hasGeneratedFirst: $hasGeneratedFirst');

          // Update cache
          final userId = _userId;
          if (userId != null) {
            CacheManager.setCachedBalance(userId, balance);
            CacheManager.setCachedHasGeneratedFirst(userId, hasGeneratedFirst);
          }

          state = CreditsState(
            balance: balance,
            hasGeneratedFirst: hasGeneratedFirst,
            isLoading: false,
          );
        }
      },
      onError: (error) {
        print('❌ Credits: Real-time listener error: $error');
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _creditsSubscription?.cancel();
    super.dispose();
  }

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference? get _userCreditsDoc {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('data')
        .doc('credits');
  }

  Future<void> _loadBalance() async {
    state = state.copyWith(isLoading: true);

    try {
      final userId = _userId;
      print('💰 Credits: Loading balance for user: $userId');

      if (userId == null) {
        print('💰 Credits: No user logged in');
        state = const CreditsState(
          balance: 0,
          hasGeneratedFirst: false,
          isLoading: false,
        );
        return;
      }

      // Always fetch from Firebase (source of truth)
      print('💰 Credits: Fetching from Firestore...');
      final doc = await _userCreditsDoc?.get();

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('💰 Credits: Firestore data: $data');

        // Support both old 'credits' (int) and new 'balance' (double) fields
        // Use the greater value to handle cases where one field was updated but not the other
        // (e.g. admin top-up updated credits, legacy spend updated balance)
        double balanceVal = 0.0;
        double creditsVal = 0.0;

        if (data.containsKey('balance')) {
          balanceVal = (data['balance'] as num).toDouble();
        }

        if (data.containsKey('credits')) {
          creditsVal = (data['credits'] as num).toDouble();
        }

        double balance;
        // Use initial balance if both are missing/zero logic
        if (!data.containsKey('balance') && !data.containsKey('credits')) {
          balance = Pricing.initialBalance;
        } else {
          // Take the maximum to ensure user doesn't lose credits from sync issues
          balance = balanceVal > creditsVal ? balanceVal : creditsVal;
        }

        print(
            '💰 Credits: Resolved balance: $balance (balance field: $balanceVal, credits field: $creditsVal)');

        final hasGeneratedFirst = data['hasGeneratedFirst'] as bool? ??
            data['hasGeneratedFirstVideo'] as bool? ??
            false;

        // Update cache with Firebase data
        await CacheManager.setCachedBalance(userId, balance);
        await CacheManager.setCachedHasGeneratedFirst(
            userId, hasGeneratedFirst);
        _lastLoadedUserId = userId;

        state = CreditsState(
          balance: balance,
          hasGeneratedFirst: hasGeneratedFirst,
          isLoading: false,
        );
        print('💰 Credits: Final balance from Firebase: $balance');
      } else {
        // First time user - create credits document
        print('💰 Credits: No credits document found, creating new one');
        try {
          // Determine initial balance based on user type
          // Guest: 4.0 SAR (1 video or 2 images)
          // Registered: 10.0 SAR (Welcome bonus)
          final isAnonymous = _auth.currentUser?.isAnonymous ?? false;
          final initialBalance = isAnonymous ? 4.0 : Pricing.initialBalance;

          await _userCreditsDoc?.set({
            'balance': initialBalance,
            'hasGeneratedFirst': false,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('💰 Credits: Created new credits doc');
        } catch (e) {
          print('💰 Credits: Failed to create credits doc: $e');
        }

        // Use same logic for cache
        final isAnonymous = _auth.currentUser?.isAnonymous ?? false;
        final initialBalance = isAnonymous ? 4.0 : Pricing.initialBalance;

        await CacheManager.setCachedBalance(userId, initialBalance);
        await CacheManager.setCachedHasGeneratedFirst(userId, false);
        _lastLoadedUserId = userId;

        state = CreditsState(
          balance: initialBalance,
          hasGeneratedFirst: false,
          isLoading: false,
        );
        print('💰 Credits: Set initial balance: $initialBalance');
      }
    } catch (e) {
      print('❌ Credits: Error loading balance from Firebase: $e');

      // Fallback to cache only if Firebase fails AND cache is for same user
      final userId = _userId;
      if (userId != null) {
        final cachedBalance = CacheManager.getCachedBalance(userId);
        if (cachedBalance != null) {
          print('💰 Credits: Using cached balance as fallback: $cachedBalance');
          state = CreditsState(
            balance: cachedBalance,
            hasGeneratedFirst:
                CacheManager.getCachedHasGeneratedFirst(userId) ?? false,
            isLoading: false,
          );
          return;
        }
      }
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get cost in SAR for output type
  double getCost(OutputType outputType) {
    return outputType == OutputType.video
        ? Pricing.videoCost
        : Pricing.imageCost;
  }

  /// For backward compatibility
  int getCreditCost(OutputType outputType) {
    return getCost(outputType).ceil();
  }

  /// Check if user can afford generation
  Future<bool> canGenerate(OutputType outputType) async {
    final cost = getCost(outputType);
    return state.balance >= cost;
  }

  /// Deduct cost for generation
  Future<void> deductCreditsForGeneration(OutputType outputType) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final cost = getCost(outputType);
      final newBalance = state.balance - cost;

      if (newBalance < 0) throw Exception('Insufficient balance');

      // Update Firestore - write both fields to keep in sync
      await _userCreditsDoc?.update({
        'balance': newBalance,
        'credits': newBalance.floor(), // Legacy field
        'hasGeneratedFirst': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update cache
      await CacheManager.setCachedBalance(userId, newBalance);
      await CacheManager.setCachedHasGeneratedFirst(userId, true);

      // Update state
      state = state.copyWith(
        balance: newBalance,
        hasGeneratedFirst: true,
      );
    } catch (e) {
      print('Error deducting balance: $e');
      rethrow;
    }
  }

  /// Add balance (from payment) - amount in SAR
  Future<void> addBalance(double amount) async {
    try {
      final userId = _userId;
      if (userId == null) throw Exception('User not logged in');

      final newBalance = state.balance + amount;

      // Update Firestore - write both fields
      await _userCreditsDoc?.update({
        'balance': newBalance,
        'credits': newBalance.floor(), // Legacy field
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update cache
      await CacheManager.setCachedBalance(userId, newBalance);

      // Update state
      state = state.copyWith(balance: newBalance);
    } catch (e) {
      print('Error adding balance: $e');
      rethrow;
    }
  }

  /// For backward compatibility - add credits as SAR
  Future<void> addCredits(int amount) async {
    await addBalance(amount.toDouble());
  }

  /// Reload balance from server
  Future<void> refreshBalance() async {
    await _loadBalance();
  }
}

final creditsControllerProvider =
    StateNotifierProvider<CreditsController, CreditsState>((ref) {
  return CreditsController(ref);
});
