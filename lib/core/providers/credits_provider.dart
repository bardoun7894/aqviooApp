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
      try {
        if (_lastLoadedUserId != user.uid) {
          print(
              '💰 Credits: New user detected, setting up cache for ${user.uid}');
          await CacheManager.setCurrentUser(user.uid);
          // Start real-time listener for this user
          _startCreditsListener();
        }
        await _loadBalance();
      } catch (e) {
        print('⚠️ Credits: Error during auth change handler: $e');
        // Ensure we exit loading state even on error to prevent stuck UI
        if (state.isLoading) {
          state = state.copyWith(isLoading: false);
        }
      }
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
    final userId = _userId;
    if (userId == null) {
      state = const CreditsState(
        balance: 0,
        hasGeneratedFirst: false,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      print('💰 Credits: Loading balance for user: $userId');

      // Try local cache first to show something immediately
      final cachedBalance = CacheManager.getCachedBalance(userId);
      final cachedHasGeneratedFirst =
          CacheManager.getCachedHasGeneratedFirst(userId);
      if (cachedBalance != null) {
        state = CreditsState(
          balance: cachedBalance,
          hasGeneratedFirst: cachedHasGeneratedFirst ?? false,
          isLoading: true, // Still loading in BG
        );
      }

      // Fetch from Firestore with a timeout
      print('💰 Credits: Fetching from Firestore...');
      final doc = await _userCreditsDoc
          ?.get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('💰 Credits: Firestore data: $data');

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
          balance = balanceVal > creditsVal ? balanceVal : creditsVal;
        }

        final hasGeneratedFirst = data['hasGeneratedFirst'] as bool? ??
            data['hasGeneratedFirstVideo'] as bool? ??
            false;

        // Update cache
        await CacheManager.setCachedBalance(userId, balance);
        await CacheManager.setCachedHasGeneratedFirst(
            userId, hasGeneratedFirst);
        _lastLoadedUserId = userId;

        state = CreditsState(
          balance: balance,
          hasGeneratedFirst: hasGeneratedFirst,
          isLoading: false,
        );
      } else if (doc != null && !doc.exists) {
        // Doc definitely doesn't exist on server
        print('💰 Credits: No credits document found, creating new one');
        final isAnonymous = _auth.currentUser?.isAnonymous ?? false;
        final initialBalance = isAnonymous ? 4.0 : Pricing.initialBalance;

        try {
          await _userCreditsDoc?.set({
            'balance': initialBalance,
            'hasGeneratedFirst': false,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('💰 Credits: Background creation failed (ignoring): $e');
        }

        state = CreditsState(
          balance: initialBalance,
          hasGeneratedFirst: false,
          isLoading: false,
        );
      }
    } catch (e) {
      print('ℹ️ Credits: Could not fetch from server (offline/timeout): $e');

      // If we already have a cached state from up above, just mark as not loading anymore
      if (state.balance > 0 || state.hasGeneratedFirst) {
        state = state.copyWith(isLoading: false);
      } else {
        // Final fallback to cache if we didn't do it at start
        final cachedBalance = CacheManager.getCachedBalance(userId);
        if (cachedBalance != null) {
          state = CreditsState(
            balance: cachedBalance,
            hasGeneratedFirst:
                CacheManager.getCachedHasGeneratedFirst(userId) ?? false,
            isLoading: false,
          );
        } else {
          // No cache, no server - use guest default as last resort
          final isAnonymous = _auth.currentUser?.isAnonymous ?? false;
          state = CreditsState(
            balance: isAnonymous ? 4.0 : Pricing.initialBalance,
            hasGeneratedFirst: false,
            isLoading: false,
          );
        }
      }
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
      final docRef = _userCreditsDoc;
      if (docRef == null) throw Exception('Credits document not available');

      late final double newBalance;
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() as Map<String, dynamic>?;

        final balanceVal = (data?['balance'] as num?)?.toDouble() ?? 0.0;
        final creditsVal = (data?['credits'] as num?)?.toDouble() ?? 0.0;
        final currentBalance = (data == null ||
                (!data.containsKey('balance') && !data.containsKey('credits')))
            ? Pricing.initialBalance
            : (balanceVal > creditsVal ? balanceVal : creditsVal);

        newBalance = currentBalance - cost;
        if (newBalance < 0) {
          throw Exception('Insufficient balance');
        }

        transaction.set(
          docRef,
          {
            'balance': newBalance,
            'credits': newBalance.floor(),
            'hasGeneratedFirst': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
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

      final docRef = _userCreditsDoc;
      if (docRef == null) throw Exception('Credits document not available');

      late final double newBalance;
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() as Map<String, dynamic>?;

        final balanceVal = (data?['balance'] as num?)?.toDouble() ?? 0.0;
        final creditsVal = (data?['credits'] as num?)?.toDouble() ?? 0.0;
        final currentBalance = (data == null ||
                (!data.containsKey('balance') && !data.containsKey('credits')))
            ? Pricing.initialBalance
            : (balanceVal > creditsVal ? balanceVal : creditsVal);

        newBalance = currentBalance + amount;

        transaction.set(
          docRef,
          {
            'balance': newBalance,
            'credits': newBalance.floor(),
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
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
